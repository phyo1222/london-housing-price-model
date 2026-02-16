# 03_modelling.R
# London housing price regression (baseline vs location model)
set.seed(111)

library(tidyverse)
library(here)
library(caret)

df <- read.csv(here("data_clean", "london_model_data.csv"))


# -------------------------
# Formatting
# -------------------------
df <- df %>%
  mutate(
    date = as.Date(date),
    property_type = factor(property_type),
    new_build     = factor(new_build),
    tenure        = factor(tenure),
    district      = factor(district),
    year          = factor(year),
    month         = factor(month)
  )


# -------------------------
# Sanity checks
# -------------------------
stopifnot(
  sum(is.na(df$price)) == 0,
  sum(df$price <= 0) == 0,
  sum(is.na(df$log_price)) == 0,
  all(is.finite(df$log_price)),
  all(df$ppd_category == "A"),
  all(df$record_status == "A")
)


# -------------------------
# Train / Test split
# -------------------------
trs <- createDataPartition(df$log_price, p = 0.8, list = FALSE)
train <- df[trs, ]
test  <- df[-trs, ]

#Setting train/test at the same set of levels
test <- test %>%
  mutate(
    property_type = factor(property_type, levels = levels(train$property_type)),
    new_build     = factor(new_build,     levels = levels(train$new_build)),
    tenure        = factor(tenure,        levels = levels(train$tenure)),
    year          = factor(year,          levels = levels(train$year)),
    month         = factor(month,         levels = levels(train$month)),
    district      = factor(district,      levels = levels(train$district))
  )

# If any NAs appear after alignment, you have unseen categories in test
stopifnot(
  sum(is.na(test$property_type)) == 0,
  sum(is.na(test$new_build)) == 0,
  sum(is.na(test$tenure)) == 0,
  sum(is.na(test$year)) == 0,
  sum(is.na(test$month)) == 0,
  sum(is.na(test$district)) == 0
)


# -------------------------
# Outlier trimming (TRAIN ONLY)
# -------------------------
low  <- quantile(train$price, 0.01, na.rm = TRUE)
high <- quantile(train$price, 0.99, na.rm = TRUE)

train_t <- train %>% filter(price >= low & price <= high)
test_t  <- test   #For honest evaluation

write_csv(
  tibble(low = low, high = high),
  here("outputs", "tables", "trim_thresholds.csv")
)


# -------------------------
# Models
# -------------------------
model_base <- lm(
  log_price ~ property_type + new_build + tenure + year + month,
  data = train_t
)

#Model adding location
model_loc <- lm(
  log_price ~ property_type + new_build + tenure + year + month + district,
  data = train_t
)

saveRDS(model_base, here("outputs","models","model_base.rds"))
saveRDS(model_loc, here("outputs","models","model_loc.rds"))


# -------------------------
# Metrics
# -------------------------
rmse <- function(actual, pred) {
  sqrt(mean((actual - pred)^2, na.rm = TRUE))
}

r2 <- function(actual, pred) {
  ok <- is.finite(actual) & is.finite(pred)
  actual <- actual[ok]; pred <- pred[ok]
  1 - sum((actual - pred)^2) / sum((actual - mean(actual))^2)
}

# Predictions on FULL test set
pred_base <- predict(model_base, newdata = test_t)
pred_loc  <- predict(model_loc, newdata = test_t)

rmse_base <- rmse(test_t$log_price, pred_base)
rmse_loc  <- rmse(test_t$log_price, pred_loc)

r2_base <- r2(test_t$log_price, pred_base)
r2_loc  <- r2(test_t$log_price, pred_loc)

res_loc <- test_t$log_price - pred_loc


# -------------------------
# Residuals + district mispricing
# -------------------------
test_t <- test_t %>%
  mutate(
    pred_loc = pred_loc,
    residual = log_price - pred_loc
  )

district_mispricing <- test_t %>%
  group_by(district) %>%
  summarise(
    mean_residual = mean(residual, na.rm = TRUE),
    mispricing_pct = (exp(mean_residual) - 1) * 100,
    n = n(),
    .groups = "drop"
  ) %>%
  arrange(desc(mean_residual))

write_csv(district_mispricing, here("outputs", "tables", "district_mispricing.csv"))


# -------------------------
# Diagnostics plots (saved to files)
# -------------------------
# Histogram
png(here("outputs","plots","residual_hist_location.png"), width = 900, height = 600)
hist(test_t$residual, breaks = 60,
     main = "Residuals (Location Model) — Full Range",
     xlab = "log_price residual (actual - predicted)",
     xlim = c(-5, 5))
dev.off()

# Residuals vs Fitted
png(here("outputs","plots","resid_vs_fitted_location.png"), width = 900, height = 600)
plot(test_t$pred_loc, test_t$residual,
     xlab = "Fitted values (log price)",
     ylab = "Residuals",
     main = "Residuals vs Fitted (Test Set) — Location Model",
     pch = 16, col = rgb(0,0,0,0.3))
abline(h = 0, col = "red", lwd = 2)
dev.off()

# QQ plot
png(here("outputs","plots","qqplot_residuals_location.png"), width = 900, height = 600)
qqnorm(test_t$residual, main = "QQ Plot of Residuals — Location Model")
qqline(test_t$residual, col = "red", lwd = 2)
dev.off()

# Residual tail summary (useful to explain why histogram axis can stretch)
tail_q <- quantile(test_t$residual, c(0, 0.001, 0.01, 0.99, 0.999, 1), na.rm = TRUE)
print(tail_q)

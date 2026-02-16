library(dplyr)

pp.2025 <- read.csv(here("data_raw", "pp-2025.txt"))
pp.2024 <- read.csv(here("data_raw", "pp-2024.txt"))
pp.2023 <- read.csv(here("data_raw", "pp-2023.txt"))


# -------------------------
# Standardise Column Names 
# -------------------------
colnames(pp.2025) <- c(
  "transaction_id",
  "price",
  "date",
  "postcode",
  "property_type",
  "new_build",
  "tenure",
  "paon",
  "saon",
  "street",
  "locality",
  "town_city",
  "district",
  "county",
  "ppd_category",
  "record_status"
)
colnames(pp.2024) <- c(
  "transaction_id",
  "price",
  "date",
  "postcode",
  "property_type",
  "new_build",
  "tenure",
  "paon",
  "saon",
  "street",
  "locality",
  "town_city",
  "district",
  "county",
  "ppd_category",
  "record_status"
)
colnames(pp.2023) <- c(
  "transaction_id",
  "price",
  "date",
  "postcode",
  "property_type",
  "new_build",
  "tenure",
  "paon",
  "saon",
  "street",
  "locality",
  "town_city",
  "district",
  "county",
  "ppd_category",
  "record_status"
)


# -------------------------
# Data Types & Formatting 
# -------------------------
pp.2025$price <- as.numeric(pp.2025$price)
pp.2025$date <- as.Date(pp.2025$date)
pp.2025$date <- as.Date(pp.2025$date, format = "%Y-%m-%d")
pp.2025$property_type <- factor(pp.2025$property_type)
pp.2025$new_build <- factor(pp.2025$new_build)
pp.2025$tenure <- factor(pp.2025$tenure)

pp.2024$price <- as.numeric(pp.2024$price)
pp.2024$date <- as.Date(pp.2024$date)
pp.2024$date <- as.Date(pp.2024$date, format = "%Y-%m-%d")
pp.2024$property_type <- factor(pp.2024$property_type)
pp.2024$new_build <- factor(pp.2024$new_build)
pp.2024$tenure <- factor(pp.2024$tenure)

pp.2023$price <- as.numeric(pp.2023$price)
pp.2023$date <- as.Date(pp.2023$date)
pp.2023$date <- as.Date(pp.2023$date, format = "%Y-%m-%d")
pp.2023$property_type <- factor(pp.2023$property_type)
pp.2023$new_build <- factor(pp.2023$new_build)
pp.2023$tenure <- factor(pp.2023$tenure)

#Merging the three dataset
pp.all <- dplyr::bind_rows(
  pp.2023,
  pp.2024,
  pp.2025
)


# -------------------------
# Restricting dataset
# -------------------------
pp.london.all <- pp.all |>
  dplyr::filter(county == "GREATER LONDON")

pp.london.all <- pp.london.all |>
  dplyr::filter(ppd_category == "A")


# -------------------------
# Feature Construction
# -------------------------
pp.london.all$year  <- as.numeric(format(pp.london.all$date, "%Y"))
pp.london.all$month <- as.numeric(format(pp.london.all$date, "%m"))

pp.london.all$log_price <- log(pp.london.all$price)


# -------------------------
# Final factor formatting
# -------------------------
pp.london.all$district <- factor(pp.london.all$district)
pp.london.all$month <- factor(pp.london.all$month)
pp.london.all$year <- factor(pp.london.all$year)


# -------------------------
# Save Clean Dataset
# -------------------------
write.csv(
  pp.london.all,
  here("data_clean", "london_model_data.csv"),
  row.names = FALSE
)
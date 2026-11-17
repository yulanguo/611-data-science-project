# North Carolina fisheries: import, clean, and create five graphs.
# Run this script and select FOSS_landings.csv when prompted.
# Outputs are saved in a graphs folder under your current working directory.

packages <- c("tidyverse", "scales")
missing_packages <- packages[!vapply(packages, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing_packages)) install.packages(missing_packages)
library(tidyverse)
library(scales)

fish <- read_csv(file.choose(), skip = 1,
                 col_types = cols(.default = col_character())) |>
  rename(year = Year, species = `NMFS Name`, pounds = Pounds,
         dollars = Dollars, collection = Collection) |>
  mutate(year = as.integer(year), pounds = parse_number(pounds),
         dollars = parse_number(dollars)) |>
  filter(Confidentiality == "Public")

sum_reported <- function(x) {
  if (all(is.na(x))) NA_real_ else sum(x, na.rm = TRUE)
}
ranking_year <- 2024
output_dir <- file.path(getwd(), "graphs")
dir.create(output_dir, showWarnings = FALSE)
theme_set(theme_minimal(base_size = 13))
colors <- c(Commercial = "#267C99", Recreational = "#D47932")
caption <- "Publicly reported values; missing and confidential values are not counted as zero."

# Graph 1: total reported landings over time
annual <- fish |>
  group_by(year, collection) |>
  summarise(pounds = sum_reported(pounds), .groups = "drop")
p1 <- ggplot(annual, aes(year, pounds / 1e6, color = collection)) +
  geom_line(linewidth = 1) + geom_point(size = 1.5) +
  scale_color_manual(values = colors) +
  labs(title = "North Carolina Reported Fisheries Landings",
       x = "Year", y = "Landings (million pounds)", color = "Collection",
       caption = caption) + theme(legend.position = "bottom")

# Graph 2: top 10 species by combined commercial and recreational weight
# Source species categories may include grouped taxa.
top_weight <- fish |>
  filter(year == ranking_year) |>
  group_by(species) |>
  summarise(pounds = sum_reported(pounds), .groups = "drop") |>
  filter(!is.na(pounds)) |>
  slice_max(pounds, n = 10, with_ties = FALSE)
p2 <- ggplot(top_weight, aes(pounds / 1e6, reorder(species, pounds))) +
  geom_col(fill = colors[["Commercial"]]) +
  labs(title = paste("Top 10 Species by Reported Landings,", ranking_year),
       subtitle = "Commercial and recreational combined; source species categories",
       x = "Landings (million pounds)", y = NULL, caption = caption)

# Graph 3: top 10 commercial species by nominal dollar value
top_value <- fish |>
  filter(year == ranking_year, collection == "Commercial") |>
  group_by(species) |>
  summarise(dollars = sum_reported(dollars), .groups = "drop") |>
  filter(!is.na(dollars)) |>
  slice_max(dollars, n = 10, with_ties = FALSE)
p3 <- ggplot(top_value, aes(dollars / 1e6, reorder(species, dollars))) +
  geom_col(fill = "#258477") +
  scale_x_continuous(labels = label_dollar(suffix = "M")) +
  labs(title = paste("Top 10 Commercial Species by Reported Value,", ranking_year),
       x = "Commercial value (nominal dollars)", y = NULL, caption = caption)

# Graph 4: trends for the six highest-weight species in the ranking year
selected_species <- top_weight |>
  slice_max(pounds, n = 6, with_ties = FALSE) |> pull(species)
trends <- fish |>
  filter(species %in% selected_species) |>
  group_by(year, species, collection) |>
  summarise(pounds = sum_reported(pounds), .groups = "drop") |>
  complete(year = full_seq(fish$year, 1), species, collection)
p4 <- ggplot(trends, aes(year, pounds / 1e6, color = collection)) +
  geom_line(linewidth = 0.8) +
  facet_wrap(~ species, scales = "free_y", ncol = 2) +
  scale_color_manual(values = colors) +
  labs(title = "Reported Landings Trends for Selected Species",
       subtitle = paste("Six highest-weight species in", ranking_year,
                        "— panels use different y-axis scales"),
       x = "Year", y = "Landings (million pounds)", color = "Collection",
       caption = caption) + theme(legend.position = "bottom")

# Graph 5: top 10 recreational species by reported weight
top_recreational <- fish |>
  filter(year == ranking_year, collection == "Recreational") |>
  group_by(species) |>
  summarise(pounds = sum_reported(pounds), .groups = "drop") |>
  filter(!is.na(pounds)) |>
  slice_max(pounds, n = 10, with_ties = FALSE)
p5 <- ggplot(top_recreational,
             aes(pounds / 1e6, reorder(species, pounds))) +
  geom_col(fill = colors[["Recreational"]]) +
  labs(title = paste("Top 10 Recreational Species by Reported Landings,", ranking_year),
       x = "Recreational landings (million pounds)", y = NULL,
       caption = caption)

plots <- list(p1, p2, p3, p4, p5)
filenames <- c("01_landings_over_time.png", "02_top_species_weight.png",
               "03_top_species_value.png", "04_species_trends.png",
               "05_top_recreational_species.png")
for (i in seq_along(plots)) {
  print(plots[[i]])
  ggsave(file.path(output_dir, filenames[i]), plot = plots[[i]],
         width = 12, height = if (i == 4) 10 else 7,
         dpi = 300, bg = "white")
}

# Also save all five graphs together in a single PDF.
pdf(file.path(output_dir, "FOSS_all_five_graphs.pdf"), width = 12, height = 9)
for (p in plots) print(p)
dev.off()
message("Saved five PNGs and a combined PDF in: ", output_dir)

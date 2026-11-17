NOAA Fisheries Data Analysis 
===========================
This project explores North Carolina’s reported commercial and recreational fisheries landings from 2000–2025 using NOAA Fisheries landings data.

## Questions

- How have commercial and recreational landings changed over time?
- Which species had the greatest reported landed weight in 2024?
- Which species generated the greatest commercial value?
- How have landings changed for major species?
- Which species led recreational landings in 2024?

## Files

| File | Description |
|---|---|
| `FOSS_landings.csv` | Dataset used in the analysis |
| `FOSS_four_graphs.Rmd` | R Markdown report with code, five graphs, and interpretation |
| `FOSS_four_graphs.html` | Rendered HTML report |
| `FOSS_four_graphs.R` | Standalone script that generates and saves the five graphs |
| `graphs/` | Saved figures and combined PDF |
| `Dockerfile` | Configuration for the project’s container environment |
| `start.sh` | Container startup script |

The analysis files retain their original “four graphs” filenames but now contain five graphs.

## Run the analysis

Keep the CSV and R Markdown file in the same folder.

Open `FOSS_four_graphs.Rmd` in RStudio and click **Knit**, or run:

```r
rmarkdown::render("FOSS_four_graphs.Rmd")
```

To generate separate PNG figures and a combined PDF, run `FOSS_four_graphs.R` and select the CSV when prompted.

## Main findings

- Reported commercial landings were substantially lower in 2024 than in 2000.
- Blue crab led combined reported landed weight and commercial value in 2024.
- Spanish mackerel led reported recreational landed weight in 2024.

## Limitations

The analysis uses publicly reported records. Missing and confidential values are excluded from totals and are not treated as zero. Some categories include groups of species.

Landings do not directly measure fish population size. Reporting coverage, fishing activity, and other factors may affect trends. Commercial dollar values represent nominal landings value, not profit or total economic impact.

## Author

Yulan Guo

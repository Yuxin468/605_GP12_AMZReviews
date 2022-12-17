rm(list = ls())

if (require("syuzhet")) {
    print("Loaded package tidyverse.")
} else {
    print("Failed to load package tidyverse.")
}

if (require("tidytext")) {
    print("Loaded package tidyverse.")
} else {
    print("Failed to load package tidyverse.")
}

if (require("dplyr")) {
    print("Loaded package tidyverse.")
} else {
    print("Failed to load package tidyverse.")
}

args = (commandArgs(trailingOnly=TRUE))
if(length(args) == 2){
    input_file = args[1]
    outfile = args[2]
} else {
    cat('usage: Rscript myscript.R <process> <output tfile>\n', file=stderr())
    stop()
}

sink(file=outfile)

apparel = read.delim(input_file, header=TRUE, allowEscapes=FALSE, sep="\t", quote="", na.strings="", comment.char="")
#df = apparel[sample(nrow(apparel), 10000),]
df = apparel[c("review_date","star_rating", "review_headline", "review_body")]
df$headline_sentiment = get_sentiment(df$review_headline)
df$body_sentiment = get_sentiment(df$review_body)
df$Month_Yr <- format(as.Date(df$review_date), "%Y-%m")
data_bybusiness = df %>% group_by(Month_Yr) %>%
    summarise(mean_star = mean(star_rating),
              mean_senti_headline = mean(headline_sentiment),
              mean_senti_body = mean(body_sentiment),
              .groups = 'drop') %>%
    as.data.frame()


lm_headline = lm(mean_star~mean_senti_headline, data=data_bybusiness)
print(summary(lm_headline))

lm_body = lm(mean_star~mean_senti_body, data=data_bybusiness)
print(summary(lm_body))
sink()


#plot(data_bybusiness$mean_senti,data_bybusiness$mean_star, xlab = "Average sentiment score", ylab = "Average Star")
#abline(lm_headline)

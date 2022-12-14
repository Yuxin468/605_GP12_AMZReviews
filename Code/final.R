rm(list = ls())

if (require("syuzhet")) {
    print("Loaded package syuzhet.")
} else {
    print("Failed to load package syuzhet.")
}

if (require("tidytext")) {
    print("Loaded package tidytext.")
} else {
    print("Failed to load package tidytext.")
}

if (require("dplyr")) {
    print("Loaded package dplyr.")
} else {
    print("Failed to load package dplyr.")
}

if (require("data.table")) {
    print("Loaded package data.table.")
} else {
    print("Failed to load package data.table.")
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

#apparel = read.delim(input_file, header=TRUE,sep="\t")
#df = apparel[sample(nrow(apparel), 10000),]
#df = apparel[c("review_date","star_rating", "review_headline", "review_body")]
#colnames(df) <- c("review_date","star_rating","review_headline","review_body")

df = fread(input_file, header=TRUE, sep=",",fill = TRUE)

df$headline_sentiment = get_sentiment(df$review_headline)
df$body_sentiment = get_sentiment(df$review_body)
df$Month_Yr <- format(as.Date(df$review_date), "%Y-%m")
data_bybusiness = df %>% group_by(Month_Yr) %>%
    mutate(mean_star = mean(star_rating,na.rm =TRUE),
              mean_senti_headline = mean(headline_sentiment),
              mean_senti_body = mean(body_sentiment),
              .groups = 'drop') %>%
    as.data.frame()
data_bybusiness =na.omit(data_bybusiness)

lm_headline = lm(mean_star~mean_senti_headline, data=data_bybusiness)
print(summary(lm_headline))

lm_body = lm(mean_star~mean_senti_body, data=data_bybusiness)
print(summary(lm_body))
sink()

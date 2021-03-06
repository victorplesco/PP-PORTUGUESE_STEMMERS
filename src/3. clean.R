#################################################################################################################################################################################################################################################################################
## Setup Environment ############################################################################################################################################################################################################################################################
#################################################################################################################################################################################################################################################################################

require(tm); require(tidyverse);

#################################################################################################################################################################################################################################################################################
## Support Functions ############################################################################################################################################################################################################################################################
#################################################################################################################################################################################################################################################################################

text.clean <- function(x) {
  x = tolower(x);
  x = removeWords(x, stopwords("portuguese"));
  x = removeNumbers(x);
  x = gsub("[[:punct:]]", " ", x);
  x = stripWhitespace(x);
  x = x[-c(which(nchar(x) == 0), which(nchar(x) == 1), which(nchar(x) == 2), which(nchar(x) >= 50))];
  x = gsub(" ", "", x, fixed = TRUE);
  x = unique(x);
  x
};

#################################################################################################################################################################################################################################################################################
## Data #########################################################################################################################################################################################################################################################################
#################################################################################################################################################################################################################################################################################

# Used text material was taken from news websites (typically on a daily basis via RSS feeds);
news_words <- read.table(file = "~/DS20-21/Information Retrieval/Project/corpus/2. unzipped/por_news_2020_10K/por_news_2020_10K-words.txt", 
                        header = FALSE,
                        fill = NA);

# Used text material was taken from randomly chosen Web sites;
web_words <- read.table(file = "~/DS20-21/Information Retrieval/Project/corpus/2. unzipped/por-lu_web_2020_10K/por-lu_web_2020_10K-words.txt", 
                        header = FALSE,
                        fill = NA);

# Used text material was taken from Wikipedia;
wiki_words <- read.table(file = "~/DS20-21/Information Retrieval/Project/corpus/2. unzipped/por_wikipedia_2021_10K/por_wikipedia_2021_10K-words.txt", 
                         header = FALSE,
                         fill = NA);

#################################################################################################################################################################################################################################################################################
## Save #########################################################################################################################################################################################################################################################################
#################################################################################################################################################################################################################################################################################

write.csv(data.frame(news_words = text.clean(as.vector(news_words[, 2]))),
          "~/DS20-21/Information Retrieval/Project/corpus/3. cleaned/news_words.csv", row.names = FALSE);
write.csv(data.frame(web_words = text.clean(as.vector(web_words[, 2]))),
          "~/DS20-21/Information Retrieval/Project/corpus/3. cleaned/web_words.csv", row.names = FALSE);
write.csv(data.frame(wiki_words = text.clean(as.vector(wiki_words[, 2]))),
          "~/DS20-21/Information Retrieval/Project/corpus/3. cleaned/wiki_words.csv", row.names = FALSE);
rm(news_words, web_words, wiki_words, text.clean);
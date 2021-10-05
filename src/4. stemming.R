#################################################################################################################################################################################################################################################################################
## Setup Environment ############################################################################################################################################################################################################################################################
#################################################################################################################################################################################################################################################################################

require(ptstem);

#################################################################################################################################################################################################################################################################################
## Data #########################################################################################################################################################################################################################################################################
#################################################################################################################################################################################################################################################################################

# Used text material was taken from news websites (typically on a daily basis via RSS feeds);
news_words <- read.csv("~/DS20-21/Information Retrieval/Project/corpus/3. cleaned/news_words.csv");

# Used text material was taken from randomly chosen Web sites;
web_words <- read.csv("~/DS20-21/Information Retrieval/Project/corpus/3. cleaned/web_words.csv");

# Used text material was taken from Wikipedia;
wiki_words <- read.csv("~/DS20-21/Information Retrieval/Project/corpus/3. cleaned/wiki_words.csv");

#################################################################################################################################################################################################################################################################################
## Hunspell - The Ground Truth ##################################################################################################################################################################################################################################################
#################################################################################################################################################################################################################################################################################

{
  start_time <- Sys.time();
  for(i in 1:nrow(news_words)) {
    cat("news_words ", i, "\n");
    
    res = try(ptstem(news_words[i, 1], algorithm = "hunspell", complete = FALSE));
    if(inherits(res, "try-error")) {news_words[i, 1] = NA; next;};
    news_words$hunspell_stem[i] <- ptstem(news_words[i, 1], algorithm = "hunspell", complete = FALSE);
    news_words$hunspell_time[i] <- as.numeric(Sys.time() - start_time);
  }; rm(i, start_time, end_time, res);
  
  start_time <- Sys.time();
  for(i in 1:nrow(web_words)) {
    cat("web_words ", i, "\n");
    
    res = try(ptstem(web_words[i, 1], algorithm = "hunspell", complete = FALSE));
    if(inherits(res, "try-error")) {web_words[i, 1] = NA; next;};
    web_words$hunspell_stem[i] <- ptstem(web_words[i, 1], algorithm = "hunspell", complete = FALSE);
    web_words$hunspell_time[i] <- as.numeric(Sys.time() - start_time);
  }; rm(i, start_time, end_time, res);
  
  start_time <- Sys.time();
  for(i in 1:nrow(wiki_words)) {
    cat("wiki_words ", i, "\n");
    
    res = try(ptstem(wiki_words[i, 1], algorithm = "hunspell", complete = FALSE));
    if(inherits(res, "try-error")) {wiki_words[i, 1] = NA; next;};
    wiki_words$hunspell_stem[i] <- ptstem(wiki_words[i, 1], algorithm = "hunspell", complete = FALSE);
    wiki_words$hunspell_time[i] <- as.numeric(Sys.time() - start_time);
  }; rm(i, start_time, end_time, res);
};

#################################################################################################################################################################################################################################################################################
## Porter's Algorithm - Snowball Implementation #################################################################################################################################################################################################################################
#################################################################################################################################################################################################################################################################################

{
  start_time <- Sys.time();
  for(i in 1:nrow(news_words)) {
    cat("news_words ", i, "\n");
    
    res = try(ptstem(news_words[i, 1], algorithm = "porter", complete = FALSE));
    if(inherits(res, "try-error")) {news_words[i, 1] = NA; next;};
    news_words$porter_stem[i] <- ptstem(news_words[i, 1], algorithm = "porter", complete = FALSE);
    news_words$porter_time[i] <- as.numeric(Sys.time() - start_time);
  }; rm(i, start_time, end_time, res);
  
  start_time <- Sys.time();
  for(i in 1:nrow(web_words)) {
    cat("web_words ", i, "\n");
    
    res = try(ptstem(web_words[i, 1], algorithm = "porter", complete = FALSE));
    if(inherits(res, "try-error")) {web_words[i, 1] = NA; next;};
    web_words$porter_stem[i] <- ptstem(web_words[i, 1], algorithm = "porter", complete = FALSE);
    web_words$porter_time[i] <- as.numeric(Sys.time() - start_time);
  }; rm(i, start_time, end_time, res);
  
  start_time <- Sys.time();
  for(i in 1:nrow(wiki_words)) {
    cat("wiki_words ", i, "\n");
    
    res = try(ptstem(wiki_words[i, 1], algorithm = "porter", complete = FALSE));
    if(inherits(res, "try-error")) {wiki_words[i, 1] = NA; next;};
    wiki_words$porter_stem[i] <- ptstem(wiki_words[i, 1], algorithm = "porter", complete = FALSE);
    wiki_words$porter_time[i] <- as.numeric(Sys.time() - start_time);
  }; rm(i, start_time, end_time, res);
};

#################################################################################################################################################################################################################################################################################
## RSLP - Removedor de Sufixos da Língua Portuguesa #############################################################################################################################################################################################################################
#################################################################################################################################################################################################################################################################################

{
  start_time <- Sys.time();
  for(i in 1:nrow(news_words)) {
    cat("news_words ", i, "\n");
    
    res = try(ptstem(news_words[i, 1], algorithm = "rslp", complete = FALSE));
    if(inherits(res, "try-error")) {news_words[i, 1] = NA; next;};
    news_words$rslp_stem[i] <- ptstem(news_words[i, 1], algorithm = "rslp", complete = FALSE);
    news_words$rslp_time[i] <- as.numeric(Sys.time() - start_time);
  }; rm(i, start_time, end_time, res);
  
  start_time <- Sys.time();
  for(i in 1:nrow(web_words)) {
    cat("web_words ", i, "\n");
    
    res = try(ptstem(web_words[i, 1], algorithm = "rslp", complete = FALSE));
    if(inherits(res, "try-error")) {web_words[i, 1] = NA; next;};
    web_words$rslp_stem[i] <- ptstem(web_words[i, 1], algorithm = "rslp", complete = FALSE);
    web_words$rslp_time[i] <- as.numeric(Sys.time() - start_time);
  }; rm(i, start_time, end_time, res);
  
  start_time <- Sys.time();
  for(i in 1:nrow(wiki_words)) {
    cat("wiki_words ", i, "\n");
    
    res = try(ptstem(wiki_words[i, 1], algorithm = "rslp", complete = FALSE));
    if(inherits(res, "try-error")) {wiki_words[i, 1] = NA; next;};
    wiki_words$rslp_stem[i] <- ptstem(wiki_words[i, 1], algorithm = "rslp", complete = FALSE);
    wiki_words$rslp_time[i] <- as.numeric(Sys.time() - start_time);
  }; rm(i, start_time, end_time, res);
};

#################################################################################################################################################################################################################################################################################
## Length Truncation ############################################################################################################################################################################################################################################################
#################################################################################################################################################################################################################################################################################

news_words$truncation_3 = substring(news_words$news_words, 1, 3);
news_words$truncation_4 = substring(news_words$news_words, 1, 4);
news_words$truncation_5 = substring(news_words$news_words, 1, 5);
news_words$truncation_6 = substring(news_words$news_words, 1, 6);
news_words$truncation_7 = substring(news_words$news_words, 1, 7);
news_words$truncation_8 = substring(news_words$news_words, 1, 8);

web_words$truncation_3 = substring(web_words$web_words, 1, 3);
web_words$truncation_4 = substring(web_words$web_words, 1, 4);
web_words$truncation_5 = substring(web_words$web_words, 1, 5);
web_words$truncation_6 = substring(web_words$web_words, 1, 6);
web_words$truncation_7 = substring(web_words$web_words, 1, 7);
web_words$truncation_8 = substring(web_words$web_words, 1, 8);

wiki_words$truncation_3 = substring(wiki_words$wiki_words, 1, 3);
wiki_words$truncation_4 = substring(wiki_words$wiki_words, 1, 4);
wiki_words$truncation_5 = substring(wiki_words$wiki_words, 1, 5);
wiki_words$truncation_6 = substring(wiki_words$wiki_words, 1, 6);
wiki_words$truncation_7 = substring(wiki_words$wiki_words, 1, 7);
wiki_words$truncation_8 = substring(wiki_words$wiki_words, 1, 8);

#################################################################################################################################################################################################################################################################################
## Save #########################################################################################################################################################################################################################################################################
#################################################################################################################################################################################################################################################################################

write.csv(news_words, "~/DS20-21/Information Retrieval/Project/corpus/4. stemmed/news_words.csv", row.names = FALSE); rm(news_words);
write.csv(web_words, "~/DS20-21/Information Retrieval/Project/corpus/4. stemmed/web_words.csv", row.names = FALSE); rm(web_words);
write.csv(wiki_words, "~/DS20-21/Information Retrieval/Project/corpus/4. stemmed/wiki_words.csv", row.names = FALSE); rm(wiki_words); 

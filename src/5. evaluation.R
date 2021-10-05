#################################################################################################################################################################################################################################################################################
## Setup Environment ############################################################################################################################################################################################################################################################
#################################################################################################################################################################################################################################################################################

require(dplyr); require(ggplot2);

#################################################################################################################################################################################################################################################################################
## Support Functions ############################################################################################################################################################################################################################################################
#################################################################################################################################################################################################################################################################################

understemming_index <- function(words, control_stems, test_stems){
  
  aux = data.frame(`words`         = words,
                   `control_stems` = control_stems,
                   `test_stems`    = test_stems) %>%
    dplyr::group_by(control_stems, test_stems) %>%
    dplyr::summarise(n_word_stem = dplyr::n()) %>%
    dplyr::ungroup() %>%
    dplyr::group_by(control_stems) %>%
    dplyr::filter(dplyr::row_number(dplyr::desc(n_word_stem)) > 1) %>%
    dplyr::summarise(misclassified = sum(n_word_stem)) %>%
    ungroup();
  
  return(sum(aux$misclassified)/length(words))
};

overstemming_index <- function(words, control_stems, test_stems){
  
  aux = data.frame(`words`         = words,
                   `control_stems` = control_stems,
                   `test_stems`    = test_stems) %>%
    dplyr::group_by(test_stems, control_stems) %>%
    dplyr::summarise(n_group_stem = dplyr::n()) %>%
    dplyr::ungroup() %>%
    dplyr::group_by(test_stems) %>%
    dplyr::filter(dplyr::row_number(dplyr::desc(n_group_stem)) > 1) %>%
    dplyr::summarise(misclassified = sum(n_group_stem)) %>%
    ungroup();
  
  return(sum(aux$misclassified)/length(words))
};

distance_two_points <- function(x_1, x_2, y_1, y_2) {
  return(sqrt((x_2 - x_1)^2 + (y_2 - y_1)^2));
};

plot_paice_errt <- function(indexes, x_1, x_2, y_1, y_2, FUN_Porter, FUN_RSLP, test = FALSE, label.truncation = TRUE, label.intersection = TRUE) {
  ggplot() +
    geom_line(aes(x = indexes$UI[3:8], y = indexes$OI[3:8])) +
    geom_point(aes(x = indexes$UI[3:8], y = indexes$OI[3:8])) +
    
    {if(label.truncation) {geom_label(aes(x = indexes$UI[3:8], y = indexes$OI[3:8], label = c(3:8)))}} +
    
    geom_line(aes(x = seq(0, ifelse(test, 0.4, x_1), len = 5), y = FUN_Porter(seq(0, ifelse(test, 0.4, x_1), len = 5)))) +
    
    {if(label.intersection) {geom_point(aes(x = x_1, y = y_1), col = "dodgerblue3", size = 5)}} +
    {if(label.intersection) {geom_text(aes(x = x_1, y = y_1, label = "T"), col = "white")}} +
  
    geom_line(aes(x = seq(0, ifelse(test, 0.4, x_2), len = 5), y = FUN_RSLP(seq(0, ifelse(test, 0.4, x_2), len = 5)))) +
    
    {if(label.intersection) {geom_point(aes(x = x_2, y = y_2), col = "tomato3", size = 5)}} +
    {if(label.intersection) {geom_text(aes(x = x_2, y = y_2, label = "T"), col = "white")}} +
    
    geom_point(aes(x = indexes$UI[1], y = indexes$OI[1]), col = "dodgerblue3", size = 5) +
    geom_text(aes(x = indexes$UI[1], y = indexes$OI[1], label = "P"), col = "white") +
    geom_text(aes(x = indexes$UI[1] + 0.1 * indexes$UI[1], y = indexes$OI[1] - 0.1 * indexes$OI[1], label = "Porter"), col = "black") +
    
    geom_point(aes(x = indexes$UI[2], y = indexes$OI[2]), col = "tomato3", size = 5) +
    geom_text(aes(x = indexes$UI[2], y = indexes$OI[2], label = "P"), col = "white") +
    geom_text(aes(x = indexes$UI[2] + 0.1 * indexes$UI[2], y = indexes$OI[2] - 0.1 * indexes$OI[2], label = "RSLP"), col = "black") +
    
    # Custom Labels;
    labs(subtitle = "Computation of ERRT Value",
         x = "Understemming Index",
         y = "Overstemming Index") +
    theme_bw(base_size = 15, base_family = "Times");
};

#################################################################################################################################################################################################################################################################################
## Data #########################################################################################################################################################################################################################################################################
#################################################################################################################################################################################################################################################################################

news_words      <- read.csv("~/DS20-21/Information Retrieval/Project/corpus/4. stemmed/news_words.csv") %>% 
  filter(complete.cases(.));
news_words = news_words[, c("news_words", "hunspell_stem", "hunspell_time", "porter_stem", "porter_time", "rslp_stem", "rslp_time",
                            "truncation_3", "truncation_4", "truncation_5", "truncation_6", "truncation_7", "truncation_8")];
web_words       <- read.csv("~/DS20-21/Information Retrieval/Project/corpus/4. stemmed/web_words.csv") %>% 
  filter(complete.cases(.));
web_words = web_words[, c("web_words", "hunspell_stem", "hunspell_time", "porter_stem", "porter_time", "rslp_stem", "rslp_time",
                          "truncation_3", "truncation_4", "truncation_5", "truncation_6", "truncation_7", "truncation_8")];
wiki_words      <- read.csv("~/DS20-21/Information Retrieval/Project/corpus/4. stemmed/wiki_words.csv") %>% 
  filter(complete.cases(.));
wiki_words = wiki_words[, c("wiki_words", "hunspell_stem", "hunspell_time", "porter_stem", "porter_time", "rslp_stem", "rslp_time",
                            "truncation_3", "truncation_4", "truncation_5", "truncation_6", "truncation_7", "truncation_8")];

all_corpus <- cbind(`words` = c(as.vector(news_words$news_words), as.vector(web_words$web_words), as.vector(wiki_words$wiki_words)), 
                    rbind(news_words[, c(2:13)], web_words[, c(2:13)], wiki_words[, c(2:13)])); all_corpus <- all_corpus[!duplicated(all_corpus$words),];
                          
#################################################################################################################################################################################################################################################################################
## Understemming (UI) & Overstemming Indexes (OI), and Stemming Weights (SW) ####################################################################################################################################################################################################
#################################################################################################################################################################################################################################################################################

paice_indexes_news <- data.frame(`UI` = rep(NA, 8), `OI` = rep(NA, 8), `SW` = rep(NA, 8), `ERRT` = rep(NA, 8)); 
rownames(paice_indexes_news) <- c("Porter", "RSLP", "trunc(3)", "trunc(4)", "trunc(5)", "trunc(6)", "trunc(7)", "trunc(8)")

paice_indexes_web  <- data.frame(`UI` = rep(NA, 8), `OI` = rep(NA, 8), `SW` = rep(NA, 8), `ERRT` = rep(NA, 8));
rownames(paice_indexes_web) <- c("Porter", "RSLP", "trunc(3)", "trunc(4)", "trunc(5)", "trunc(6)", "trunc(7)", "trunc(8)")

paice_indexes_wiki <- data.frame(`UI` = rep(NA, 8), `OI` = rep(NA, 8), `SW` = rep(NA, 8), `ERRT` = rep(NA, 8));
rownames(paice_indexes_wiki) <- c("Porter", "RSLP", "trunc(3)", "trunc(4)", "trunc(5)", "trunc(6)", "trunc(7)", "trunc(8)")

paice_indexes_all <- data.frame(`UI` = rep(NA, 8), `OI` = rep(NA, 8), `SW` = rep(NA, 8), `ERRT` = rep(NA, 8));
rownames(paice_indexes_all) <- c("Porter", "RSLP", "trunc(3)", "trunc(4)", "trunc(5)", "trunc(6)", "trunc(7)", "trunc(8)")

# Understemming Index;
for(i in 1:length(c(4, 6, 8:13))) {col = c(4, 6, 8:13);
  paice_indexes_news$UI[i] = understemming_index(news_words$news_words, news_words$hunspell_stem, news_words[, col[i]]);
  paice_indexes_web$UI[i]  = understemming_index(web_words$web_words, web_words$hunspell_stem, web_words[, col[i]]);
  paice_indexes_wiki$UI[i] = understemming_index(wiki_words$wiki_words, wiki_words$hunspell_stem, wiki_words[, col[i]]);
  paice_indexes_all$UI[i]  = understemming_index(all_corpus$words, all_corpus$hunspell_stem, all_corpus[, col[i]]);
}; rm(i, col);

# Overstemming Index;
for(i in 1:length(c(4, 6, 8:13))) {col = c(4, 6, 8:13);
  paice_indexes_news$OI[i] = overstemming_index(news_words$news_words, news_words$hunspell_stem, news_words[, col[i]]);
  paice_indexes_web$OI[i]  = overstemming_index(web_words$web_words, web_words$hunspell_stem, web_words[, col[i]]);
  paice_indexes_wiki$OI[i] = overstemming_index(wiki_words$wiki_words, wiki_words$hunspell_stem, wiki_words[, col[i]]);
  paice_indexes_all$OI[i]  = overstemming_index(all_corpus$words, all_corpus$hunspell_stem, all_corpus[, col[i]]);
}; rm(i, col);

# Stemming Weight;
paice_indexes_news$SW = paice_indexes_news$OI/paice_indexes_news$UI; 
paice_indexes_web$SW  = paice_indexes_web$OI/paice_indexes_web$UI; 
paice_indexes_wiki$SW = paice_indexes_wiki$OI/paice_indexes_wiki$UI; 
paice_indexes_all$SW  = paice_indexes_all$OI/paice_indexes_all$UI; 

#################################################################################################################################################################################################################################################################################
## Error Rate Relative to Trunaction (ERRT) #####################################################################################################################################################################################################################################
#################################################################################################################################################################################################################################################################################

# news_words;
porter_news_words <- function(x) {0.622 * x};
porter_intersection_news_words <- function(x) {-1.444 * x + 0.449}; # x = 0.217, y = 0.134974;
paice_indexes_news$ERRT[1] <- distance_two_points(0, paice_indexes_news$UI[1], 0, paice_indexes_news$OI[1])/distance_two_points(paice_indexes_news$UI[1], 0.217, paice_indexes_news$OI[1], 0.134974);
rm(porter_intersection_news_words);

rslp_news_words   <- function(x) {1.514 * x};
rslp_intersection_news_words   <- function(x) {-1.444 * x + 0.449}; # x = 0.152, y = 0.230128;
paice_indexes_news$ERRT[2] <- distance_two_points(0, paice_indexes_news$UI[2], 0, paice_indexes_news$OI[2])/distance_two_points(paice_indexes_news$UI[2], 0.152, paice_indexes_news$OI[2], 0.230128);
rm(rslp_intersection_news_words);

plot_paice_errt(paice_indexes_news, 0.217, 0.152, 0.134974, 0.230128, porter_news_words, rslp_news_words, 
                test = FALSE, label.truncation = TRUE, label.intersection = TRUE); rm(porter_news_words, rslp_news_words);
# ggsave("~/DS20-21/Information Retrieval/Project/plots/paice_plot_news.png", width = 14, height = 10);

# web_words;
porter_web_words <- function(x) {0.649 * x};
porter_intersection_web_words <- function(x) {-1.442 * x + 0.438}; # x = 0.209, y = 0.135641;
paice_indexes_web$ERRT[1] <- distance_two_points(0, paice_indexes_web$UI[1], 0,  paice_indexes_web$OI[1])/distance_two_points(paice_indexes_web$UI[1], 0.209, paice_indexes_web$OI[1], 0.135641);
rm(porter_intersection_web_words);

rslp_web_words   <- function(x) {1.497 * x};
rslp_intersection_web_words   <- function(x) {-1.442 * x + 0.438}; # x = 0.149, y = 0.223053;
paice_indexes_web$ERRT[2] <- distance_two_points(0, paice_indexes_web$UI[2], 0, paice_indexes_web$OI[2])/distance_two_points(paice_indexes_web$UI[2], 0.149, paice_indexes_web$OI[2], 0.223053);
rm(rslp_intersection_web_words);

plot_paice_errt(paice_indexes_web, 0.209, 0.149, 0.135641, 0.223053, porter_web_words, rslp_web_words, 
                test = FALSE, label.truncation = TRUE, label.intersection = TRUE); rm(porter_web_words, rslp_web_words);
# ggsave("~/DS20-21/Information Retrieval/Project/plots/paice_plot_web.png", width = 14, height = 10);

# wiki_words;
porter_wiki_words <- function(x) {0.721 * x};
porter_intersection_wiki_words <- function(x) {-1.602 * x + 0.463}; # x = 0.199, y = 0.143479;
paice_indexes_wiki$ERRT[1] <- distance_two_points(0, paice_indexes_wiki$UI[1], 0, paice_indexes_wiki$OI[1])/distance_two_points(paice_indexes_wiki$UI[1], 0.199, paice_indexes_wiki$OI[1], 0.143479);
rm(porter_intersection_wiki_words);

rslp_wiki_words   <- function(x) {1.776 * x};
rslp_intersection_wiki_words   <- function(x) {-1.602 * x + 0.463}; # x = 0.137, y = 0.243312;
paice_indexes_wiki$ERRT[2] <- distance_two_points(0, paice_indexes_wiki$UI[2], 0, paice_indexes_wiki$OI[2])/distance_two_points(paice_indexes_wiki$UI[2], 0.137, paice_indexes_wiki$OI[2], 0.243312);
rm(rslp_intersection_wiki_words);

plot_paice_errt(paice_indexes_wiki, 0.199, 0.137, 0.143479, 0.243312, porter_wiki_words, rslp_wiki_words, 
                test = FALSE, label.truncation = TRUE, label.intersection = TRUE); rm(porter_wiki_words, rslp_wiki_words);
# ggsave("~/DS20-21/Information Retrieval/Project/plots/paice_plot_wiki.png", width = 14, height = 10);

# all;
porter_all_words <- function(x) {0.628 * x};
porter_intersection_all_words <- function(x) {-0.781 * x + 0.319}; # x = 0.226, y = 0.141928;
paice_indexes_all$ERRT[1] <- distance_two_points(0, paice_indexes_all$UI[1], 0, paice_indexes_all$OI[1])/distance_two_points(paice_indexes_all$UI[1], 0.226, paice_indexes_all$OI[1], 0.141928);
rm(porter_intersection_all_words);

rslp_all_words   <- function(x) {1.476 * x};
rslp_intersection_all_words   <- function(x) {-1.688 * x + 0.524}; # x = 0.166, y = 0.245016;
paice_indexes_all$ERRT[2] <- distance_two_points(0, paice_indexes_all$UI[2], 0, paice_indexes_all$OI[2])/distance_two_points(paice_indexes_all$UI[2], 0.166, paice_indexes_all$OI[2], 0.245016);
rm(rslp_intersection_all_words);

plot_paice_errt(paice_indexes_all, 0.226, 0.166, 0.141928, 0.245016, porter_all_words, rslp_all_words, 
                test = FALSE, label.truncation = TRUE, label.intersection = TRUE); rm(porter_all_words, rslp_all_words);
# ggsave("~/DS20-21/Information Retrieval/Project/plots/paice_plot_all.png", width = 14, height = 10);

#################################################################################################################################################################################################################################################################################
## Save #########################################################################################################################################################################################################################################################################
#################################################################################################################################################################################################################################################################################

write.csv(paice_indexes_news, "~/DS20-21/Information Retrieval/Project/corpus/5. evaluated/paice_news_words.csv"); rm(paice_indexes_news, news_words);
write.csv(paice_indexes_web, "~/DS20-21/Information Retrieval/Project/corpus/5. evaluated/paice_web_words.csv"); rm(paice_indexes_web, web_words);
write.csv(paice_indexes_wiki, "~/DS20-21/Information Retrieval/Project/corpus/5. evaluated/paice_wiki_words.csv"); rm(paice_indexes_wiki, wiki_words);
write.csv(paice_indexes_all, "~/DS20-21/Information Retrieval/Project/corpus/5. evaluated/paice_all_words.csv"); rm(paice_indexes_all, all_corpus);
rm(distance_two_points, overstemming_index, plot_paice_errt, understemming_index);
# required packages
library(twitteR)
library(sentiment)
library(ggplot2)


api_key <- "YOUR_KEY"

api_secret <- "YOUR_SECRET_KEY"

access_token <- "YOUR_TOKEN"

access_token_secret <- "YOUR_SECRET_TOKEN"

twitteR:::setup_twitter_oauth(api_key,api_secret,access_token,access_token_secret)

analyse <- function(person, num) {
  some_tweets = twitteR:::searchTwitter(person, n=num, lang="en")
  some_txt = sapply(some_tweets, function(x) x$getText())
  
  # remove retweet entities
  some_txt = gsub("(RT|via)((?:\\b\\W*@\\w+)+)", "", some_txt)
  # remove at people
  some_txt = gsub("@\\w+", "", some_txt)
  # remove punctuation
  some_txt = gsub("[[:punct:]]", "", some_txt)
  # remove numbers
  some_txt = gsub("[[:digit:]]", "", some_txt)
  # remove html links
  some_txt = gsub("http\\w+", "", some_txt)
  # remove unnecessary spaces
  some_txt = gsub("[ \t]{2,}", "", some_txt)
  some_txt = gsub("^\\s+|\\s+$", "", some_txt)
  
  # define "tolower error handling" function 
  try.error = function(x)
  {
    # create missing value
    y = NA
    # tryCatch error
    try_error = tryCatch(tolower(x), error=function(e) e)
    # if not an error
    if (!inherits(try_error, "error"))
      y = tolower(x)
    # result
    return(y)
  }
  # lower case using try.error with sapply 
  some_txt = sapply(some_txt, try.error)
  
  # remove NAs in some_txt
  some_txt = some_txt[!is.na(some_txt)]
  names(some_txt) = NULL
  
  
  # METHOD
  
  # classify emotion
  class_emo = classify_emotion(some_txt, algorithm="bayes", prior=1.0)
  # get emotion best fit
  emotion = class_emo[,7]
  # substitute NA's by "unknown"
  emotion[is.na(emotion)] = "unknown"
  
  # classify polarity
  class_pol = classify_polarity(some_txt, algorithm="bayes")
  # get polarity best fit
  polarity = class_pol[,4]
  
  # data frame with results
  sent_df = data.frame(text=some_txt, emotion=emotion,
                       polarity=polarity, stringsAsFactors=FALSE)
  
  # sort data frame
  sent_df = within(sent_df,
                   emotion <- factor(emotion, levels=names(sort(table(emotion), decreasing=TRUE))))
  
  
  # RUN ONLY ONCE
  analysis <- c()
  for (i in unique(sent_df$emotion)) {
    if (i != "unknown")
      analysis <- rbind(analysis, c(i, sum(sent_df$emotion == i)))
  }
  analysis <- as.data.frame(analysis)
  analysis$V2  <- as.numeric(as.character(analysis$V2))
  #   disgust <- sum(sent_df$emotion == "disgust")
  #   fear <- sum(sent_df$emotion == "fear")
  #   anger <- sum(sent_df$emotion == "anger")
  #   joy <- sum(sent_df$emotion == "joy")
  #   sadness <- sum(sent_df$emotion == "sadness")
  #   surprise <- sum(sent_df$emotion == "surprise")
  names(analysis) <- c("Emotion", "DegreeOfEmotion")
  
  ggplot(analysis, mapping = aes(Emotion, DegreeOfEmotion)) + geom_density() + ggtitle(paste(person, as.character(num))) + theme(plot.title = element_text(size=22))
  
}


# TO USE:
analyse("bestbuy", 200)










######## TESTING --- IGNORE ############

some_tweets = twitteR:::searchTwitter("donald trump", n=500, lang="en")
some_txt = sapply(some_tweets, function(x) x$getText())

# remove retweet entities
some_txt = gsub("(RT|via)((?:\\b\\W*@\\w+)+)", "", some_txt)
# remove at people
some_txt = gsub("@\\w+", "", some_txt)
# remove punctuation
some_txt = gsub("[[:punct:]]", "", some_txt)
# remove numbers
some_txt = gsub("[[:digit:]]", "", some_txt)
# remove html links
some_txt = gsub("http\\w+", "", some_txt)
# remove unnecessary spaces
some_txt = gsub("[ \t]{2,}", "", some_txt)
some_txt = gsub("^\\s+|\\s+$", "", some_txt)

# define "tolower error handling" function 
try.error = function(x)
{
  # create missing value
  y = NA
  # tryCatch error
  try_error = tryCatch(tolower(x), error=function(e) e)
  # if not an error
  if (!inherits(try_error, "error"))
    y = tolower(x)
  # result
  return(y)
}
# lower case using try.error with sapply 
some_txt = sapply(some_txt, try.error)

# remove NAs in some_txt
some_txt = some_txt[!is.na(some_txt)]
names(some_txt) = NULL


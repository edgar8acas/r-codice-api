#! /usr/bin/Rscript
suppressPackageStartupMessages(library(tm))
suppressPackageStartupMessages(library(jsonlite))
suppressPackageStartupMessages(library(quanteda))
suppressPackageStartupMessages(library(dplyr))
suppressPackageStartupMessages(library(tibble))

#Reads and converts the input file
#TODO: pass filename as argument

create_corpus <- function(input) {
  #Create tmCorpus
  tm::Corpus(tm::DataframeSource(input), readerControl = list(language =
                                                                "es"))
}

apply_transformations <- function(tmCorpus) {
  tmCorpus <- tm_map(tmCorpus, removePunctuation)
  tmCorpus <- tm_map(tmCorpus, stripWhitespace)
  tmCorpus <- tm_map(tmCorpus, removeNumbers)
  tmCorpus <- tm_map(tmCorpus, content_transformer(tolower))
  return(tmCorpus)
}

get_transposed_dfm <- function (tmCorpus) {
  qCorpus <- quanteda::corpus(tmCorpus)

  dfm <- quanteda::dfm(qCorpus)

  #tf_idf ?

  #transpose and convert to data frame
  as.data.frame(t(as.matrix(dfm)))
}

get_luhn_lib <- function(dfm) {
  term_freq <- get_term_freq_in_collection(dfm)
  col_total_words <-
    summarise_at(term_freq, c('sum'), sum)[1, 1]
  stopwords <- tm::stopwords("es")
  diff_words <- get_diff_words(dfm)

  col_total_words / (length(diff_words) - length(stopwords))
}

get_luhn_col <- function(dfm) {
  term_freq <- get_term_freq_in_collection(dfm)
  col_total_words <-
    summarise_at(term_freq, c('sum'), sum)[1, 1]
  stopwords <- tm::stopwords("es")
  diff_words <- get_diff_words(dfm)
  col_stopwords <- diff_words[diff_words %in% stopwords]

  col_total_words / (length(diff_words) - length(col_stopwords))
}

get_diff_words <- function (dfm) {
  rownames(dfm)
}

#obtain the sum of each word in the whole collection
get_term_freq_in_collection <- function (dfm) {
  columns <- ncol(dfm) + 1
  collection_freq <-
    dfm %>%
    rownames_to_column('words') %>%
    mutate(sum = rowSums(.[2:columns])) %>%
    column_to_rownames('words')
  return(collection_freq)
}


get_collection_term_frequency_luhn_lib <-
  function(term_freq, luhn_lib) {
    col_term_frequency <-
      term_freq %>%
      rownames_to_column('words') %>%
      filter(sum > luhn_lib) %>%
      column_to_rownames('words')
    return(col_term_frequency)
  }

get_collection_term_frequency_luhn <-
  function(term_freq, luhn_col) {
    col_term_frequency <-
      term_freq %>%
      rownames_to_column('words') %>%
      filter(sum > luhn_col)
    return(col_term_frequency)
  }

# MATRIZ FINAL, a partir de esta matriz, aquellas palabras con frecuencia mayor a cero
# en cada columna, son las que se exportarán como palabras esenciales por texto



get_collection_without_stopwords <-
  function(collection_term_frequency) {
    stopwords <- tm::stopwords("es")
    col_freq_luhn <-
      collection_term_frequency %>%
      filter(!words %in% stopwords)
    return(col_freq_luhn)
  }

#* @post /essential
get_essential_words <- function (texts_collection) {
  output <- list()

  dfm <- get_transposed_dfm(apply_transformations((
    create_corpus(texts_collection)
  )))

  collection_term_frequency <-
    get_collection_term_frequency_luhn(get_term_freq_in_collection(dfm), get_luhn_col(dfm))

  collection <-
    get_collection_without_stopwords(collection_term_frequency)

  for (doc_id in  texts_collection$doc_id) {
    output[[doc_id]] <-
      collection %>%
      filter(!!rlang::sym(doc_id) > 0) %>%
      pull(words)
  }

  return(output)
}





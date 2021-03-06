setup({
  sc <- testthat_spark_connection()
  text_tbl <- testthat_tbl("test_text")

  # These lines should set a pipeline that will ultimately create the columns needed for testing the annotator
  assembler <- nlp_document_assembler(sc, input_col = "text", output_col = "document")
  sentdetect <- nlp_sentence_detector(sc, input_cols = c("document"), output_col = "sentence")
  # TODO: put other annotators here as needed

  pipeline <- ml_pipeline(assembler, sentdetect)
  test_data <- ml_fit_and_transform(pipeline, text_tbl)

  assign("sc", sc, envir = parent.frame())
  assign("pipeline", pipeline, envir = parent.frame())
  assign("test_data", test_data, envir = parent.frame())
})

teardown({
  rm(sc, envir = .GlobalEnv)
  rm(pipeline, envir = .GlobalEnv)
  rm(test_data, envir = .GlobalEnv)
})

# There are no "getter" methods in the RecursiveTokenizer class so this test will fail
# test_that("recursive_tokenizer param setting", {
#   test_args <- list(
#     input_cols = c("string1"),
#     output_col = "string1",
#     infixes = c("string1", "string2"),
#     prefixes = c("string1", "string2"),
#     suffixes = c("string1", "string2"),
#     white_list = c("string1", "string2")
#   )
# 
#   test_param_setting(sc, nlp_recursive_tokenizer, test_args)
# })

test_that("nlp_recursive_tokenizer spark_connection", {
  test_annotator <- nlp_recursive_tokenizer(sc, input_cols = c("document"), output_col = "token")
  transformed_data <- ml_fit_and_transform(test_annotator, test_data)
  expect_true("token" %in% colnames(transformed_data))
})

test_that("nlp_recursive_tokenizer ml_pipeline", {
  test_annotator <- nlp_recursive_tokenizer(pipeline, input_cols = c("document"), output_col = "token")
  transformed_data <- ml_fit_and_transform(test_annotator, test_data)
  expect_true("token" %in% colnames(transformed_data))
})

test_that("nlp_recursive_tokenizer tbl_spark", {
  transformed_data <- nlp_recursive_tokenizer(test_data, input_cols = c("document"), output_col = "token")
  expect_true("token" %in% colnames(transformed_data))
})


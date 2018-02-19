#' Get data from a thermopic project
#' 
#' @param data Character (or factor) containing a path to a CSV, or a data frame
#' @param path Thermopic project root path
#' @param in_or_out Either DataIn or DataOut
#' @export
#' @importFrom utils read.csv
get_thermopic_data = function(data, path = NULL, in_or_out = c('DataIn', 'DataOut')) {
  
  in_or_out = in_or_out[1]
  if(!any(in_or_out == c('DataIn', 'DataOut'))) {
    stop('in_or_out must be either DataIn or DataOut')
  }

  if(is.factor(data)) data = as.character(data)

  if(is.character(data)) {
    if(is.null(path)) stop('Must specify project path if data is a filename')
    path = file.path(path)
    path = file.path(path, in_or_out, data)
    if(!file.exists(path)) stop('Data not found in specified thermopic project')
    data = read.csv(path, header = TRUE)
  }
  
  if(!is.data.frame(data)) {
    stop('data must be either a string to a path containing a csv, or a data frame')
  }
  
  return(data)
}

#' Print directory tree
#' 
#' @param root directory to depict visually
#' @importFrom data.tree as.Node
#' @importFrom plyr rbind.fill
#' @export
print_directory_tree = function(root) {
  path = list.files(root, recursive = TRUE, full.names = FALSE, include.dirs = TRUE)
  path = file.path(rev(strsplit(root, '/')[[1]])[1], path)
  x <- lapply(strsplit(path, "/"), function(z) as.data.frame(t(z)))
  x <- rbind.fill(x)
  x$pathString <- apply(x, 1, function(x) paste(trimws(na.omit(x)), collapse="/"))
  x = as.Node(x)
  cat(noquote(as.data.frame(x)$levelName), sep = '\n')
  invisible(x)
}

#' Temporary thermopic directory
#' 
#' @export
temporary_thermopic_directory = function() {
  return(file.path(gsub('\\\\', '/', tempdir()), 'thermopic_project'))
}

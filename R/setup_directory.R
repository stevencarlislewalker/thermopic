#' Setup Thermopic Directory
#' 
#' Setup a directory to be used with the thermopic software
#' 
#' @param path Filesystem location for running thermopic analyses.
#' If the path already exists, throw an error unless overwrite is TRUE.
#' @param UserOptions Path to csv file containing user options.
#' If missing a default file is used (TODO: describe format)
#' @param Lake Path to csv file containing lake data
#' If missing a default file is used (TODO: describe format)
#' @param Climate Path to csv file containing climate data
#' If missing a default file is used (TODO: describe format)
#' @param DataDictionary Path to csv file containing the thermopic data dictionary
#' @param overwrite Should an existing directory at the specified path be overwritten?
#' @param overwrite_output Should any existing output be overwritten? 
#' If overwrite_output is TRUE, than overwrite is ignored.
#' @export
setup_directory = function(
  path, 
  UserOptions, 
  Lake,
  Climate,
  DataDictionary,
  overwrite = FALSE,
  overwrite_output = FALSE
  ) {
 
  if (missing(UserOptions))
    UserOptions = system.file('extdata/0_User_Options.csv',
                              package = 'thermopic')
  
  if (missing(Lake))
    Lake = system.file('extdata/1_Lake.csv', 
                       package = 'thermopic')
  
  if (missing(Climate))
    Climate = system.file('extdata/2_Climate.csv', 
                          package = 'thermopic')
  
  if (missing(DataDictionary))
    DataDictionary = system.file('extdata/ThermoPic_Dictionary.csv', 
                                 package = 'thermopic')
  
  path = file.path(path) # remove terminal slash
  DataIn = file.path(path, 'DataIn')
  DataOut = file.path(path, 'DataOut')
  ThermoPics = file.path(path, 'DataOut', 'ThermoPics')
  Guide = system.file('doc/ThermoPic_Guide.pdf', package = 'thermopic')
  TechReport = system.file('doc/ThermoPic_TechReport.pdf', package = 'thermopic')
  
  create_structure = function() {
    unlink(path, recursive = TRUE) # remove any existing directory
    dir.create(path)
    dir.create(DataIn)
    dir.create(DataOut)
    dir.create(ThermoPics)
    file.copy(DataDictionary, path)
    file.copy(UserOptions, DataIn)
    file.copy(Lake, DataIn)
    file.copy(Climate, DataIn)
    file.copy(Guide, path)
    file.copy(TechReport, path)
  }
  
  overwrite_output_structure = function() {
    unlink(DataOut, recursive = TRUE)
    dir.create(DataOut)
    dir.create(ThermoPics)
  }
  
  if(dir.exists(path)) {
    if(overwrite_output) {
      overwrite_output_structure()      
    } else if(overwrite) {
      create_structure()
    } else {
      stop(
        'Thermopic directory exists.\n',
        '  To avoid this error, one may',
        '  choose a new directory,\n',
        '  set overwrite to TRUE,\n',
        '  or set overwrite_output to TRUE.'
      )
    }
  } else {
    create_structure()
  }
  invisible(path)
}

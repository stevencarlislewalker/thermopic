# thermopic 0.0.1.0000

* Changed the argument naming schemes in `thermopic_model` and `thermopic_report` to be more descriptive
* Fixed the tutorial

# thermopic 0.0.0.9000

* Changed to semantic versioning scheme, in order to follow recommended practice. Thus previous thermopic versions 1, 2, and 3 are followed by `0.0.0.9000`. The first, second, and third zeros are the major, minor, and patch version numbers, and the final 9000 number is the development version.
* Can now be installed using standard package installation tools, in preparation for the first major release to be published in a repository.
* Wrapped `ThermoPic_P1_Model.R` and `ThermoPic_P2_Report.R` scripts into two functions thermopic_model and thermopic_report. As a result the package has slightly different usage pattern relative to previous versions. This change was required to produce a standard `R` package, which are typically a collection of `R` functions.
* Added `setup_directory` function that automatically constructs the directory structure required for a thermopic project.
* Progress bar for monitoring the rate at which thermopics are contructed.

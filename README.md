# Fenton Lab Ovation .dat and analysis importer

## Purpose
The purpose of this package is to automate import of .dat data and analysis results into the [Ovation Scientific Data Management System](http://ovation.io).

## Structure

This package provides two entry functions:

- `batch_dat_import`

	Imports a collection of .dat files from a "design file" (in Excel XLSX format) summary

- `batch_analysis_import`

	Imports the results of an analysis described in a .tbl file (in Excel XLXS format)

## Usage

This package assumes a standard "Design File" and "Tbl File" format. Examples of these files are 
shown in `test/fixtures/OnedayProtocolLogSheet.xlsx` (design file) and `test/fixtures/batch/fmr1.xlsx` (tbl file). Both files must be in Excel XML (`xlsx`) format.

The output of `batch_dat_import` is a dictionary of Ovation `Epochs`, keyed by the .dat file(s) they reference. The `batch_analysis_import` uses this dictionary of Epochs to find the correct Epoch for attaching a new `AnalysisRecord` containing the summary statistics and PostScript file(s).

The `example_import.m` script file shows usage of the `batch_dat_import` and `batch_analysis_import` for the test fixture contained with the project.

## License

This package is provided under the terms of the [GPLv2](http://www.gnu.org/licenses/gpl-2.0.html) license. See the file `LICENSE` in the package root folder for license terms.


This package was originally developed by Physion in consultation with the Fenton Lab. It is now maintained by the Fenton Lab.



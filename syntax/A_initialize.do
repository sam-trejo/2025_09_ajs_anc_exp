******************************************************************************** 
* Main Do File 

* Title: Policing the boundaries of Blackness: How Black and White Americans evaluate racial self-identifications
* Authors: Thompson, Trejo, Alvero, & Martschenko 
* ReadMe file: _readme.txt
* 
* Initialized: February 2023
* Finalized: August 2025
********************************************************************************

********************************************************************************
* NOTES
********************************************************************************

* Inputs: 
*  	ancestry_exp_study_1_post.dta // Study 1 
*   ancestry_exp_study_2_post.dta // Study 2 


********************************************************************************
*** SETUP
********************************************************************************

version 17

clear all
set more off
set matsize 5000
pause on

set scheme burd
graph set window fontface "Calibri-Light" 

***set seeds
set seed 19103
set sortseed 19103

********************************************************************************
*** SET DIRECTORY GLOBALS
********************************************************************************

**** Set home folder //** USERS MAY NEED TO REPLACE **// 

pwd
global dir .. 


***set files path globals
global data "${dir}/data"
global syntax "${dir}/syntax" 
global table "${dir}/tables"
global figure "${dir}/figures"

**** Create a folder for temporary files 

capture mkdir "${figure}/temp"


***set color globals for figures
global color1 ebblue
global color2 maroon
global color3 midgreen*1.35
global color4 lavender*1.5

**** Install necessary packages 
local packages estout desctable coefplot khb

foreach package in `packages' {
	capture : which `package'
	if (_rc) {
		display as result in smcl `"Please install `package' in order to run this syntax"'
		exit 199
	}
}

*** Returns YYYY_MM_DD as global $date
quietly {
	global date=c(current_date)

	***day
	if substr("$date",1,1)==" " {
		local val=substr("$date",2,1)
		global day=string(`val',"%02.0f")
	}
	else {
		global day=substr("$date",1,2)
	}

	***month
	if substr("$date",4,3)=="Jan" {
		global month="01"
	}
	if substr("$date",4,3)=="Feb" {
		global month="02"
	}
	if substr("$date",4,3)=="Mar" {
		global month="03"
	}
	if substr("$date",4,3)=="Apr" {
		global month="04"
	}
	if substr("$date",4,3)=="May" {
		global month="05"
	}
	if substr("$date",4,3)=="Jun" {
		global month="06"
	}
	if substr("$date",4,3)=="Jul" {
		global month="07"
	}
	if substr("$date",4,3)=="Aug" {
		global month="08"
	}
	if substr("$date",4,3)=="Sep" {
		global month="09"
	}
	if substr("$date",4,3)=="Oct" {
		global month="10"
	}
	if substr("$date",4,3)=="Nov" {
		global month="11"
	}
	if substr("$date",4,3)=="Dec" {
		global month="12"
	}

	***year
	global year=substr("$date",8,4)

	global date="$year"+"_"+"$month"+"_"+"$day"
}

dis "$date"


***set variable globals

global covs "i.image i.name_num i.survey_device i.state i.educ i.hispanic i.female_respondent i.missing_income i.party i.immigrant age ln_income " // Study 1 Covariates

global covs_study2 "i.image_num i.name_num i.state i.education i.sex_num i.missing_income i.political_party age ln_income" // Study 2 Covariates


********************************************************************************
*** DO FILES - RUNS ALL ANALYSIS 
********************************************************************************

do "${syntax}/B_study_1_analysis.do"

do "${syntax}/C_study_2_analysis.do"

do "${syntax}/D_combined_analysis.do" 










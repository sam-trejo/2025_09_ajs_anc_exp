
********************************************************************************
*** STUDY 1 FIGURES/TABLES 
********************************************************************************

use "${data}/ancestry_exp_study_1_post.dta", clear 

******************************
* Table 1 - Respondent Descriptives 
******************************

	* Note that this creates both an average and a weighted average
	* Table 1 includes weighted average using weights provided by You Gov
	cd "${table}/"

	svyset [pweight=weight] 

	foreach var in age female_respondent income_1000 {
		svy: mean `var'
		estat sd
	}

	desctable age i.female_respondent i.educ income_1000 i.immigrant i.party ///
			  , stats(mean sd svymean) ///
			  filename("table_1_$date") ///
			  title(" ") ///
			  notesize(11)
			  
	svyset, clear		   

******************************
* Table 3 - Mediation Results 
******************************

	* Note that this generates three separate tables to combine into Table 3

use "${data}/ancestry_exp_study_1_post.dta", clear 

eststo clear 
estimates clear 

gen scholarship = context 
gen census = abs(scholarship-1) 

gen black = prior_identity 
gen non_black = abs(black - 1) 

rename discrimination disc // khb command has a maximum number of characters
rename cultural_experience cult


** Begin with ancestry 

estpost sum id
esttab using "${table}/table_3_ancestry_$date.csv", replace noobs postfoot(" ")  
	 
		   
foreach var in  guess_race_black initial_reaction other_race_black {

estimates clear
matrix drop _all

	khb reg `var' ancestry ///
			|| index disc cult [pw=weight] ///
			, disentangle summary vce(robust) ///
			concomitant(${covs} prior_identity census) 
						
	matrix med = e(disentangle)	   
	forvalues row = 1/3 {
		display med[`row', 2]^2
		mat temp = nullmat(temp) \ med[`row', 1], med[`row', 2]^2, med[`row', 4]/100
		mat temp2 = nullmat(temp2) \ med[`row', 1], med[`row', 2], med[`row', 4]/100
	}

	matrix tot = J(1, rowsof(temp), 1) * temp		   
	matrix temp2 = temp2 \ tot[1, 1], (tot[1, 2]^.5), tot[1, 3]
	forvalues row = 1/4 {
		matrix out = nullmat(out) \ temp2[`row', 1], temp2[`row', 2], temp2[`row', 3], (temp2[`row', 2]*e(b)[1,1]/temp2[`row', 1])
	}

	matrix rownames out = "`: variable label index'" "`: variable label disc'" "`: variable label cult'" "Total"
	matrix colnames out = "Mediator Effect" "SE1" "Fraction of Total Effect" "SE2"
	estadd matrix out = out

	esttab using "${table}/table_3_ancestry_$date.csv" ///
		   , append plain noobs ///
		   cells("out[Mediator Effect](t fmt(%8.2g)) out[SE1](t fmt(%8.2g)) out[Fraction of Total Effect](t fmt(%8.2g)) out[SE2](t fmt(%8.2g))") ///	
		   mtitle("`: variable label `var''") ///
		   postfoot(" ") 
}


** Context 

eststo clear 
estimates clear 

estpost sum id
esttab using "${table}/table_3_census_$date.csv", replace noobs postfoot(" ")  
 
	foreach var in  guess_race_black initial_reaction other_race_black {

		estimates clear
		matrix drop _all

			khb reg `var' census ///
					|| index disc cult [pw=weight] ///
					, disentangle summary vce(robust) ///
					concomitant(${covs} prior_identity ancestry) 
								
			matrix med = e(disentangle)	   
			forvalues row = 1/3 {
				display med[`row', 2]^2
				mat temp = nullmat(temp) \ med[`row', 1], med[`row', 2]^2, med[`row', 4]/100
				mat temp2 = nullmat(temp2) \ med[`row', 1], med[`row', 2], med[`row', 4]/100
			}

			matrix tot = J(1, rowsof(temp), 1) * temp		   
			matrix temp2 = temp2 \ tot[1, 1], (tot[1, 2]^.5), tot[1, 3]
			forvalues row = 1/4 {
				matrix out = nullmat(out) \ temp2[`row', 1], temp2[`row', 2], temp2[`row', 3], (temp2[`row', 2]*e(b)[1,1]/temp2[`row', 1])
			}

			matrix rownames out = "`: variable label index'" "`: variable label disc'" "`: variable label cult'" "Total"
			matrix colnames out = "Mediator Effect" "SE1" "Fraction of Total Effect" "SE2"
			estadd matrix out = out

			esttab using "${table}/table_3_census_$date.csv" ///
				   , append plain noobs ///
				   cells("out[Mediator Effect](t fmt(%8.2g)) out[SE1](t fmt(%8.2g)) out[Fraction of Total Effect](t fmt(%8.2g)) out[SE2](t fmt(%8.2g))") ///	
				   mtitle("`: variable label `var''") ///
				   postfoot(" ") 
		}

		
eststo clear 
estimates clear 

** Prior Identification 

estpost sum id
esttab using "${table}/table_3_prior_identification_$date.csv", replace noobs postfoot(" ")  
 
	foreach var in  guess_race_black initial_reaction other_race_black {

		estimates clear
		matrix drop _all

			khb reg `var' prior_identity ///
					|| index disc cult [pw=weight] ///
					, disentangle summary vce(robust) ///
					concomitant(${covs} ancestry census) 
								
			matrix med = e(disentangle)	   
			forvalues row = 1/3 {
				display med[`row', 2]^2
				mat temp = nullmat(temp) \ med[`row', 1], med[`row', 2]^2, med[`row', 4]/100
				mat temp2 = nullmat(temp2) \ med[`row', 1], med[`row', 2], med[`row', 4]/100
			}

			matrix tot = J(1, rowsof(temp), 1) * temp		   
			matrix temp2 = temp2 \ tot[1, 1], (tot[1, 2]^.5), tot[1, 3]
			forvalues row = 1/4 {
				matrix out = nullmat(out) \ temp2[`row', 1], temp2[`row', 2], temp2[`row', 3], (temp2[`row', 2]*e(b)[1,1]/temp2[`row', 1])
			}

			matrix rownames out = "`: variable label index'" "`: variable label disc'" "`: variable label cult'" "Total"
			matrix colnames out = "Mediator Effect" "SE1" "Fraction of Total Effect" "SE2"
			estadd matrix out = out

			esttab using "${table}/table_3_prior_identification_$date.csv" ///
				   , append plain noobs ///
				   cells("out[Mediator Effect](t fmt(%8.2g)) out[SE1](t fmt(%8.2g)) out[Fraction of Total Effect](t fmt(%8.2g)) out[SE2](t fmt(%8.2g))") ///	
				   mtitle("`: variable label `var''") ///
				   postfoot(" ") 
		}



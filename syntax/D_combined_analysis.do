
********************************************************************************
*** COMBINED FIGURES/TABLES 
********************************************************************************

** Generate Study 1 and Study 2 Appended Data 

use "${data}/ancestry_exp_study_1_post.dta", clear 

	gen study = 1

	gen census = 0 
	replace census = 1 if context == 0 
	
	
	gen ancestry_num = . 
	replace ancestry_num  = 1 if ancestry==0 & study == 1
	replace ancestry_num  = 2 if ancestry==1 & study == 1

	append using "${data}/ancestry_exp_study_2_post.dta", force 

	replace study = 2 if study==. 
	
	label define ancestry_lbl2 ///
		0 "0% SSA" ///
		1 "4% SSA" ///
		2 "36% SSA"
	label values ancestry_num ancestry_lbl2 
	label variable ancestry_num "Ancestry (Treatment)" 

	label var census "Census"
	label define census_lbl2 0 "Scholarship" 1 "Census"
	label values census census_lbl2

	// also create indicators for study 1, study 2 (black), and study 2 (white) 	
	gen group =. 
	replace group = 0 if study ==1 
	replace group = 1 if study == 2 & ethnicitysimplified == "Black"
	replace group = 2 if study == 2 & ethnicitysimplified == "White"
			
	tab group 

	
******************************
* Figure 1 - Treatment Effects 
******************************


tabulate ancestry_num, gen(ancestry_coef_)
label var ancestry_coef_1 "0% SSA"
label var ancestry_coef_2 "4% SSA"
label var ancestry_coef_3 "36% SSA"

		su likert 
		di `r(mean)'
		di `r(sd)'
		gen black_likert_std= (black_likert - `r(mean)')/`r(sd)'
		su black_likert_std 

		su likert 
		di `r(mean)'
		di `r(sd)'
		gen white_likert_std= (white_likert - `r(mean)')/`r(sd)'
		su white_likert_std 

	* collapse study 1 and study 2 measures 
	gen other_race_black_2 = . 
	replace other_race_black_2 = other_race_black if study==1 
	replace other_race_black_2 = black_guess_race_forced_black if ethnicitysimplified == "Black" & study==2 
	replace other_race_black_2 = white_guess_race_forced_black if ethnicitysimplified == "White" & study==2 


	gen other_likert = black_likert_std if ethnicitysimplified == "Black"
	replace other_likert = white_likert_std if ethnicitysimplified == "White"
	


preserve 
	estimates clear 
	eststo clear 
	
				eststo m1: reg initial_reaction ancestry_coef_3 i.census i.prior_identity ///
				${covs} if study == 1 
				
				eststo m2: reg initial_reaction ancestry_coef_1 ancestry_coef_3 i.census i.prior_identity ///
				${covs_study2} if ethnicitysimplified=="Black" & study ==2 
				
				eststo m3: reg initial_reaction ancestry_coef_1 ancestry_coef_3 i.census i.prior_identity ///
				${covs_study2}  if ethnicitysimplified=="White"  & study ==2 

			*** 	

				eststo m2a: reg black_likert_std ancestry_coef_1 ancestry_coef_3 i.census i.prior_identity ///
				${covs_study2}  if ethnicitysimplified=="Black" & study ==2 
				
				eststo m3a: reg white_likert_std ancestry_coef_1 ancestry_coef_3 i.census i.prior_identity ///
				${covs_study2}  if ethnicitysimplified=="White"  & study ==2 
			
			*** 
				eststo m4: reg guess_race_black ancestry_coef_3 i.census i.prior_identity ///
				${covs} if study == 1 
				
				eststo m5: reg guess_race_black ancestry_coef_1 ancestry_coef_3 i.census i.prior_identity ///
				${covs_study2}  if ethnicitysimplified=="Black" & study ==2 
				
				eststo m6: reg guess_race_black ancestry_coef_1 ancestry_coef_3 i.census i.prior_identity ///
				${covs_study2}  if ethnicitysimplified=="White"  & study ==2 
				
			*** 
			
				eststo m7: reg other_race_black_2 ancestry_coef_3 i.census i.prior_identity ///
				${covs} if study == 1 
				
				eststo m8: reg black_guess_race_forced_black ancestry_coef_1 ancestry_coef_3 i.census i.prior_identity ///
				${covs_study2}  if ethnicitysimplified=="Black" & study ==2 
				
				eststo m9: reg white_guess_race_forced_black  ancestry_coef_1 ancestry_coef_3 i.census i.prior_identity ///
				${covs_study2}  if ethnicitysimplified=="White"  & study ==2 

	
		set scheme stcolor 
	
		* Coefficient Plot 
		coefplot (m4, label(Black Respondents (Study 1)) msymbol(Dh)  mcolor(${color1}) ciopts(lcolor(${color1})) ) ///
				 (m5, label(Black Respondents (Study 2))  msymbol(circle)  mcolor(${color1}) ciopts(lcolor(${color1}))) ///
				 (m6, label(White Respondents (Study 2))  msymbol(circle)  mcolor(${color2}) ciopts(lcolor(${color2}))), ///
				 keep(ancestry_coef_1 ancestry_coef_3  1.census 1.prior_identity) bylabel(Respondent Classification) msize(small) legend(size(vsmall) cols(3) pos(6))  ///
			     || m1 m2 m3, keep(ancestry_coef_1 ancestry_coef_3  1.census 1.prior_identity) bylabel(Respondent Approval) msize(small) ///
				 || m7 m8 m9, keep(ancestry_coef_1 ancestry_coef_3  1.census 1.prior_identity) bylabel(2nd Order Classification) msize(small)  ///
			     || (m1, drop(*)) m2a m3a, keep(ancestry_coef_1 ancestry_coef_3  1.census 1.prior_identity) bylabel(2nd Order Approval)  msize(small) ///
		         orderby(1:3) byopts(cols(2) xrescale legend(size(vsmall) cols(3) pos(6)))  headings(ancestry_coef_1= "{bf:Ancestry:}" 1.census= "{bf:Context:}" ///
				 1.prior_identity= "{bf:Prior Identification:}", labsize(medsmall)) ///
				 xline(0, lcolor(black%30)) saving("${figure}/temp/coefplot_study1_study2_v_04_${date}.gph", replace)  graphregion(color(white)) ///
				 ylabel(,labsize(small)) xlabel(,labsize(small)) subtitle(, size(medsmall)) ysize(4) xsize(5) 
		
	** NOTE ** coefplot doesn't have the option to rescale range via code, must be done manually --> change axes for classification -.2 to .2 and approval -.5 to .5 so everything is standardized
	
	graph export "${figure}/figure_1_${date}.png", replace width(8500)
	graph export "${figure}/figure_1_${date}.tif", replace width(8500)
	
	
restore	

set scheme burd

******************************
* Figure 2 - Baseline Classification Outcomes 
******************************

preserve 


	keep group guess_race_black white_guess_race_forced_black black_guess_race_forced_black ancestry_num ethnicitysimplified responseid study other_race_black
	
	gen guess_self = guess_race_black 
	gen guess_other = . 
	replace guess_other = black_guess_race_forced_black if group==1 
	replace guess_other = white_guess_race_forced_black if group==2
	replace guess_other = other_race_black if group== 0 
	
	drop if group==. 


	drop black_guess_race_forced_black white_guess_race_forced_black guess_race_black
	
	collapse (mean) mn_guess_self=guess_self ///
	     (mean) mn_guess_other=guess_other ///
		(sd) sd_guess_self=guess_self ///
		(sd) sd_guess_other=guess_other ///
		(count) n_guess_self=guess_self ///
		(count) n_guess_other=guess_other , ///
		by(group)
	
	
	* Generate confidence intervals 
	foreach var in guess_self guess_other { 
	
	generate hi_`var' = mn_`var' + invttail(n_`var' -1,0.025)*(sd_`var' / sqrt(n_`var'))
	generate lo_`var' = mn_`var' - invttail(n_`var'-1,0.025)*(sd_`var' / sqrt(n_`var'))
	}
	
	reshape long mn hi lo, i(group) j(var, string)

	** back to graphing with CIs
	
	gen barcat = 1 if  group == 0 & var=="_guess_self"
	replace barcat = 2 if group == 0 & var=="_guess_other" 
	replace barcat = 4 if  group == 1 & var=="_guess_self"
	replace barcat = 5 if group == 1 & var=="_guess_other" 
	replace barcat = 7 if  group == 2 & var=="_guess_self"
	replace barcat = 8 if group == 2 & var=="_guess_other" 
	
	***produce bar graph	
	twoway bar mn barcat if var=="_guess_self" ///
			   , ///
			   lcolor(black) lwidth(.25) fcolor(white) ///
			   barwidth(.9) xlabel("") ylabel(, labsize(small))  ///
			|| ///
		   bar mn barcat if var=="_guess_other" ///
			   , ///
			   lcolor(black) lwidth(.25)  fcolor(grey%40) ///
			   barwidth(.9) ///
			|| ///
		   rcap hi lo barcat ///
				, ///
				lcolor(black%50)  ///
				msize(small) ///
				ytitle("" ///
					   , size(small)) ///
				yline(0, lpattern(dash) lcolor(grey%32)) ///
				xtitle("") ytitle("Fraction Classifying Vignette Individual as Black", size(medsmall)) legend(order(1 "1st Order Classification" 2 "2nd Order Classification") size(small) symy(4) symx(4) position(11) cols(3)) saving("${figure}/temp/compare_classification_simple2_$date.gph", replace) yscale(range(0(.2).8)) ylabel(0(.2).8) xlabel(1.5 "Black Respondents (Study 1)" 4.5 "Black Respondents (Study 2)" 7.5 "White Respondents (Study 2)", labsize(small))


	graph export "${figure}/figure_2_$date.png" ///
				 , replace width(10000) 
	graph export "${figure}/figure_2_$date.tif" ///
				 , replace width(10000) 
	
restore 


******************************
* Table 4 - Approval and Integrity Perceptions 
******************************

preserve 

	
	replace eth_num = 1 if study==1 // all respondents in study 1 self-identify as Black 
	
	estimates clear 
	eststo clear 

	tab guess_race_black other_race_black_2 

			*** regression table 

			reg initial_reaction i.guess_race_black##i.other_race_black_2 ///
									i.ancestry_num i.census i.prior_identity i.eth_num i.study, robust 

			eststo, title("Approval"): margins, at(guess_race_black=(0 1) ancestry_num=2 census=1 prior_identity=1 other_race_black_2=(0 1)) pwcompare(effects group) post 

				
			reg index i.guess_race_black##i.other_race_black_2 ///
									i.ancestry_num i.census i.prior_identity i.eth_num i.study , robust 
			
			eststo, title("Integrity Index"): margins, at(guess_race_black=(0 1) ancestry_num=2 census=1 prior_identity=1 other_race_black_2=(0 1)) pwcompare(effects group) post 


			
			esttab * using "${table}/table_4_$date.csv", ///
						obslast se nogaps nonumbers mtitles label replace ///
						 b(%9.2f) ///
						 star(* 0.05 ** 0.01 *** 0.001) ///
						 coeflabels(1._at "1st Order Classification = Not Black & 2nd Order Classification = Not Black" ///
						 2._at "1st Order Classification = Not Black & 2nd Order Classification = Black" ///
						 3._at "1st Order Classification = Black & 2nd Order Classification = Not Black" ///
						 4._at "1st Order Classification = Black & 2nd Order Classification = Black")
	
restore 

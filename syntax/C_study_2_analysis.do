

********************************************************************************
*** STUDY 2 FIGURES/TABLES 
********************************************************************************

use "${data}/ancestry_exp_study_2_post.dta", clear

******************************
* Table 2 - Respondent Descriptives 
******************************

desctable i.respondent_black age i.sex_num i.education income_1000 i.political_party ///
		  , stats(mean sd n) ///
		  filename("${table}/table_2_$date") ///
		  title(" ") ///
		  notesize(11) 
		  
******************************
* Figure 3 - Comparing in- and out-group 
******************************

preserve
 	
	keep guess_race_black black_guess_race_forced_black white_guess_race_forced_black ethnicitysimplified 
	drop if ethnicitysimplified=="" 
	
	gen id = _n


	** Will reshape - generate relevant measures for Black and White respondents  
	su guess_race_black if ethnicitysimplified=="Black"
	su guess_race_black if ethnicitysimplified=="White" 
	su white_guess_race_forced_black if ethnicitysimplified=="Black"
	su white_guess_race_forced_black if ethnicitysimplified=="White"
	su black_guess_race_forced_black if ethnicitysimplified=="Black"
	su black_guess_race_forced_black if ethnicitysimplified=="White"
	
	gen guess_0 = guess_race_black if ethnicitysimplified=="White" //what white respondents actually say 
	gen guess_1 = white_guess_race_forced_black if ethnicitysimplified=="Black" //what black respondents think they will 
	gen guess_2 = white_guess_race_forced_black if ethnicitysimplified=="White" //what white respondents think they will 
	
	
	gen guess_3 = guess_race_black if ethnicitysimplified=="Black" //what black respondents actually say 
	gen guess_4 = black_guess_race_forced_black if ethnicitysimplified=="White"  //what white respondents think they will 
	gen guess_5 = black_guess_race_forced_black if ethnicitysimplified=="Black"  //what black respondents think they will 
	
	su guess_0 // Check values
	su guess_3 

	
	** Reshape so that the guess varriables are aligned 
	
	reshape long guess_, i(id ethnicitysimplified) j(cat)
	
	rename guess_ guess 
	
	collapse (mean) mn_guess=guess ///
		(sd) sd_guess=guess ///
		(count) n_guess=guess, ///
		by(ethnicitysimplified cat)
			
	*** generate confidence interval variables
	generate hi_mn_guess = mn_guess + invttail(n-1,0.025)*(sd_guess / sqrt(n_guess))
	generate lo_mn_guess = mn_guess - invttail(n-1,0.025)*(sd_guess / sqrt(n_guess))
	
	
	egen treatment_cat = group(ethnicitysimplified cat)

	
	gen barcat = . 
	gen barcat1 = .


	replace barcat =1 if  cat == 1 // cat = 1 = what black respondents think white respondents will say
	replace barcat =2 if  cat == 2 // cat = 1 = what white respondents think white respondents will say
	
	replace barcat1 =2 if  cat == 4 // cat = 4 = what white respondents think black respondents will say 
	replace barcat1 =1 if  cat == 5 // cat = 5 = what black respondents think black respondents will say 


	*** produce bar graphs (2 side by side)
	twoway bar mn_guess barcat if  cat ==1, ///
			   lcolor(${color1}) fcolor(${color1}%20) lwidth(.3) ///
			   barwidth(.9) xlabel( ///
			   1 "Black Respondents' Perceptions"  ///
			   2 "White Respondents' Perceptions" ///
				,  labsize(2.6) ) ///
				ylabel(, labsize(small)) yscale(range(0(.2).6)) ///
			|| ///
		   bar mn_guess barcat if  cat ==2 , ///
			   lcolor(${color2}) fcolor(${color2}%20)  lwidth(.3)  ///
			   barwidth(.9) ///
		   || rcap hi_mn_guess lo_mn_guess barcat , ///
				lcolor(black%50)  ///
				msize(small) ///
				ytitle("" ///
					   , size(small)) ///
				yline(.244, lpattern(dash) lcolor(grey)) title("Perceptions of White Americans' Responses", size(medsmall)) ///
				xtitle("") legend(off) yscale(range(0(.2).6)) ylabel(0 0.2 0.4 0.6) saving("${figure}/temp/temp2.gph", replace)
				
		twoway bar mn_guess barcat1 if  cat ==4, ///
			   lcolor(${color2}) fcolor(${color2}%20) lwidth(.3) ///
			   barwidth(.9) xlabel( ///
			   1 "Black Respondents' Perceptions" ///
			   2 "White Respondents' Perceptions" ///
				,  labsize(2.6) ) ///
				ylabel(, labsize(small)) yscale(range(0(.2).6)) ///
			|| ///
		   bar mn_guess barcat1 if  cat ==5 , ///
			   lcolor(${color1}) fcolor(${color1}%20)  lwidth(.3)  ///
			   barwidth(.9) ///
		   || rcap hi_mn_guess lo_mn_guess barcat1 , ///
				lcolor(black%50)  ///
				msize(small) ///
				ytitle("" ///
					   , size(small)) ///
				yline(.345, lpattern(dash) lcolor(grey)) title("Perceptions of Black Americans' Responses", size(medsmall)) ///
				xtitle("") legend(off) yscale(range(0(.2).6)) ylabel(0 0.2 0.4 0.6) saving("${figure}/temp/temp1.gph", replace)
				
		graph combine "${figure}/temp/temp1.gph" "${figure}/temp/temp2.gph", ycommon l2title("Fraction Classifying Vignette Individual as Black", size(small)) saving("${figure}/temp/temp4.gph", replace)
	

	graph export "${figure}/figure_3_$date.png" , width(10000) replace
	graph export "${figure}/figure_3_$date.tif" , width(10000) replace

				 			 	
			
restore 

	
******************************
* Figure 4 - Differences in approval, integrity, discrimination, culture 
******************************
		
		
preserve

		drop if ethnicitysimplified == ""
		
		
* standardize perceptions to the first-order distributions 
		
		su likert 
		di `r(mean)'
		di `r(sd)'
		gen black_likert_std= (black_likert - `r(mean)')/`r(sd)'
		su black_likert_std 

		drop black_likert 
		rename black_likert_std black_likert 

		su likert 
		di `r(mean)'
		di `r(sd)'
		gen white_likert_std= (white_likert - `r(mean)')/`r(sd)'
		su white_likert_std 

		drop white_likert 
		rename white_likert_std white_likert 

			
		su discrimination 
		di `r(mean)'
		di `r(sd)'
		gen black_discrimination_std= (black_discrimination - `r(mean)')/`r(sd)'
		su black_discrimination_std 

		drop black_discrimination 
		rename black_discrimination_std black_discrimination 

		su discrimination 
		di `r(mean)'
		di `r(sd)'
		gen white_discrimination_std= (white_discrimination - `r(mean)')/`r(sd)'
		su white_discrimination_std 

		drop white_discrimination  
		rename white_discrimination_std white_discrimination 

		su cultural_experience 
		di `r(mean)'
		di `r(sd)'
		gen black_cultural_experience_std= (black_cultural_experience - `r(mean)')/`r(sd)'
		su black_cultural_experience_std 

		drop black_cultural_experience 
		rename black_cultural_experience_std black_cultural_experience 

		su cultural_experience 
		di `r(mean)'
		di `r(sd)'
		gen white_cultural_experience_std= (white_cultural_experience - `r(mean)')/`r(sd)'
		su white_cultural_experience_std 

		drop white_cultural_experience 
		rename white_cultural_experience_std white_cultural_experience 

		egen discrimination_std = std(discrimination) 
		drop discrimination
		rename discrimination_std discrimination
		egen cultural_experience_std = std(cultural_experience) 
		drop cultural_experience 
		rename cultural_experience_std cultural_experience


	
			 collapse (mean) reaction=initial_reaction white_likert black_likert black_index black_discrimination black_cultural_experience ///
			 white_index white_discrimination white_cultural_experience ///
			 index discrimination cultural_experience ///
			 (sd) sd_reaction = initial_reaction sd_black_reaction=black_likert sd_white_reaction=white_likert sd_black_index = black_index sd_black_discrimination = black_discrimination sd_black_cultural = black_cultural_experience sd_white_index = white_index sd_white_discrimination = white_discrimination sd_white_cultural = white_cultural_experience ///
			 sd_index = index sd_discrimination = discrimination sd_cultural= cultural_experience ///
			 (count) n_black_index = black_index n_black_discrimination = black_discrimination n_black_cultural = black_cultural_experience n_white_index = white_index n_white_discrimination = white_discrimination n_white_cultural = white_cultural_experience ///
			 n_index = index n_discrimination = discrimination n_cultural= cultural_experience n_reaction = initial_reaction n_black_reaction=black_likert n_white_reaction=white_likert ///
			 , by(ethnicitysimplified)
			 
			rename white_likert white_reaction 
			rename black_likert black_reaction 
			
			* Rename some of the variables for reshaping 
			 
			gen other_index = black_index if ethnicitysimplified == "Black"
			replace other_index = white_index if ethnicitysimplified == "White"
			gen other_cultural = black_cultural_experience if ethnicitysimplified == "Black"
			replace other_cultural = white_cultural_experience if ethnicitysimplified == "White"
			gen other_discrimination = black_discrimination if ethnicitysimplified == "Black"
			replace other_discrimination = white_discrimination if ethnicitysimplified == "White"
			gen other_reaction = black_reaction if ethnicitysimplified == "Black"
			replace other_reaction = white_reaction if ethnicitysimplified == "White"
			
			gen sd_other_index = sd_black_index if ethnicitysimplified == "Black"
			replace sd_other_index = sd_white_index if ethnicitysimplified == "White"
			gen n_other_index = n_black_index if ethnicitysimplified == "Black"
			replace n_other_index = n_white_index if ethnicitysimplified == "White"

			gen sd_other_cultural = sd_black_cultural if ethnicitysimplified == "Black"
			replace sd_other_cultural = sd_white_cultural if ethnicitysimplified == "White"
			gen n_other_cultural = n_black_cultural if ethnicitysimplified == "Black"
			replace n_other_cultural = n_white_cultural if ethnicitysimplified == "White"
			
			gen sd_other_discrimination = sd_black_discrimination if ethnicitysimplified == "Black"
			replace sd_other_discrimination = sd_white_discrimination if ethnicitysimplified == "White"
			gen n_other_discrimination = n_black_discrimination if ethnicitysimplified == "Black"
			replace n_other_discrimination = n_white_discrimination if ethnicitysimplified == "White"
			
			gen sd_other_reaction = sd_black_reaction if ethnicitysimplified == "Black"
			replace sd_other_reaction = sd_white_reaction if ethnicitysimplified == "White"
			gen n_other_reaction = n_black_reaction if ethnicitysimplified == "Black"
			replace n_other_reaction = n_white_reaction if ethnicitysimplified == "White"
				 
			rename cultural_experience cultural 
			
			foreach var in index cultural discrimination reaction { 
				
			* Generate the difference variable
				generate diff_`var' = `var' - other_`var'

				* Calculate the standard deviation of the difference 
				generate sd_diff_`var' = sqrt(sd_`var'^2 + sd_other_`var'^2)

				* Calculate the sample size
				generate n_diff_`var' = min(n_`var', n_other_`var') 
				
				* Calculate the standard error of the difference
				generate se_diff_`var' = sd_diff_`var' / sqrt(n_diff_`var')

				* Generate the confidence interval variables
				generate hi_diff_`var' = diff_`var' + invttail(n_diff_`var'-1, 0.025) * se_diff_`var'
				generate lo_diff_`var' = diff_`var' - invttail(n_diff_`var'-1, 0.025) * se_diff_`var'
			}

			keep diff_* hi_* lo_* ethnicitysimplified
			
			rename diff_index mn_diff_index 
			rename diff_discrimination mn_diff_discrimination
			rename diff_cultural mn_diff_cultural 
			rename diff_reaction mn_diff_reaction
			
			reshape long mn_ hi_ lo_, j(var, string) i(ethnicitysimplified)
			
			gen barcat = . 
			replace barcat = 1 if (var == "diff_reaction") & ethnicitysimplified == "Black"
			replace barcat = 2 if  (var == "diff_reaction") & ethnicitysimplified == "White"
			replace barcat = 4 if (var == "diff_index") & ethnicitysimplified == "Black"
			replace barcat = 5 if  (var == "diff_index") & ethnicitysimplified == "White"
			replace barcat = 7 if  (var == "diff_discrimination") & ethnicitysimplified == "Black"
			replace barcat = 8 if  (var == "diff_discrimination") & ethnicitysimplified == "White"
			replace barcat = 10 if  (var == "diff_cultural") & ethnicitysimplified == "Black"
			replace barcat = 11 if  (var == "diff_cultural") & ethnicitysimplified == "White"
			
			
			twoway bar mn barcat if ethnicitysimplified=="Black",  lcolor(${color1}%63) fcolor(${color1}%32) || /// 
			 bar mn barcat if ethnicitysimplified=="White",  lcolor(${color2}%63) fcolor(${color2}%32) /// 
			|| rcap hi lo barcat, lcolor(black%50) /// 
			, yline(0) ytitle("Difference 1st and 2nd Order Response") xlabel( ///
				   10.5 "Shared Culture" ///
					   7.5 "Discrimination" /// 
					   4.5 "Integrity" /// 
					   1.5 "Approval" /// 
						,  labsize(medsmall) notick) xlabel(, labsize(medsmall)) xtitle("") legend(on order(1 "Black Respondents" 2 "White Respondents") size(small) symy(4) symx(4) position(12)) saving("${figure}/temp/compiled_comparison_integrity_$date.gph", replace)
						
			graph export "${figure}/figure_4_$date.png", width(10000) replace
			graph export "${figure}/figure_4_$date.tif", width(10000) replace

restore
	
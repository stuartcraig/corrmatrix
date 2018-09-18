
cd D:\Dropbox\codesnippets
adopath + `c(pwd)'

cap mkdir corrmatrix
cd corrmatrix

sysuse auto, clear

label var price "Price"
label var mpg "MPG"
label var headroom "Headroom"
label var trunk "Trunk Space"
label var length "Length"

loc c1=0
foreach v1 of varlist price mpg headroom trunk length {
loc ++c1
loc c2=0
foreach v2 of varlist price mpg headroom trunk length {
loc ++c2

	// On the diagonal--create the titles
	if `c1'==`c2' {
		cap drop temp1
		cap drop temp2
		qui gen temp1 = .
		qui gen temp2 = .
		loc ttext: var label `v1'
		loc wc = wordcount("`ttext'")
		forval i=1/4 {
			loc w`i' = word("`ttext'",`i')
		}
		if `wc'==1 {
		tw scatter temp1 temp2, ysc(off) xsc(off) ytitle("") xtitle("") ///
				title("{bf:`w1'}", ring(0) pos(0) size(vhuge)) ///
				saving(hppc_`c1'`c2', replace)
		}
		if `wc'==2 {
		tw scatter temp1 temp2, ysc(off) xsc(off) ytitle("") xtitle("") ///
				title("{bf:`w1'}" "{bf:`w2'}", ring(0) pos(0) size(vhuge)) ///
				saving(hppc_`c1'`c2', replace)
		}
		
	}

	// On the upper triangle--create correlation #s
	if `c2'>`c1' {
		qui corr `v1' `v2'
		return list
		loc ttext: di %3.2f `r(rho)'
		tw scatter temp1 temp2, ysc(off) xsc(off) ytitle("") xtitle("") ///
			title("`ttext'", ring(0) pos(0) size(vhuge)) ///
			saving(hppc_`c1'`c2', replace)
	}
	
	
	// On the lower triangle--create the scatter
	if `c1'>`c2' {
		tw scatter `v1' `v2', ///
			ms(O) xlab(,nolab) ylab(,nolab nogrid) xtitle("") ytitle("") ///
			saving(hppc_`c1'`c2', replace)
	}

}
}

loc fl ""
forval k1=1/`c1' {
forval k2=1/`c2' {
	loc fl "`fl' hppc_`k1'`k2'.gph"
}
}

graph combine `fl'	
graph export corrmatrix_example.png, replace width(3000)
	
	
	

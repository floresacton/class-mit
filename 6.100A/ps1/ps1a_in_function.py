def part_a(annual_salary, percent_saved, total_cost_of_home):
	#########################################################################
	percent_down_payment = 0.12
	down_payment = percent_down_payment*total_cost_of_home
	r = 0.06
	monthly_return = r/12
	monthly_salary = annual_salary/12
	amount_saved = 0
	months = 0
	
	###############################################################################################
	## Determine how many months it would take to get the down payment for your dream home below ## 
	###############################################################################################
	while amount_saved < down_payment:
	    amount_saved += amount_saved*monthly_return
	    amount_saved += monthly_salary*percent_saved
	    months += 1
	return months
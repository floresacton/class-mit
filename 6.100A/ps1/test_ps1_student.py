import put_in_function as pif

student_a, student_b, student_c = 0 , 0 , 0

pif.put_in_functions_a()
import ps1a_in_function as student_a
pif.put_in_functions_b()
import ps1b_in_function as student_b
pif.put_in_functions_c()
import ps1c_in_function as student_c

total_number_of_tests = 9
tests_passed = 0
a_tests = 0
b_tests = 0
c_tests = 0

if student_a:
    print('----PART A Test 1----')
    print('RUNNING with annual_salary: 112000, percent_saved: .17, total_cost_of_home: 750000')
    annual_salary = 112000
    percent_saved = .17
    total_cost_of_home = 750000
    actual = 51
    student = student_a.part_a(annual_salary, percent_saved, total_cost_of_home)
    if actual != student: 
        print('FAILED')
        print("Part A test 1 failed. Correct answer:", actual, "Your answer:", student)
    else: 
        print('PASSED')
        tests_passed += 1
        a_tests +=1
        
    print('----PART A Test 2----')
    print('RUNNING with annual_salary: 65000, percent_saved: .20, total_cost_of_home: 400000')
    annual_salary = 65000
    percent_saved = .20
    total_cost_of_home = 400000
    actual = 41
    student = student_a.part_a(annual_salary, percent_saved, total_cost_of_home)
    if actual != student: 
        print("FAILED")
        print("Part A test 2 failed. Correct answer:", actual, "Your answer:", student) 
    else: 
        print("PASSED")
        tests_passed += 1
        a_tests +=1

    print('----PART A Test 3----')
    print('RUNNING with annual_salary: 350000, percent_saved: .3, total_cost_of_home: 10000000')
    annual_salary = 350000
    percent_saved = .3
    total_cost_of_home = 10000000
    actual = 105
    student = student_a.part_a(annual_salary, percent_saved, total_cost_of_home)
    if actual != student:
        print("FAILED") 
        print("Part A test 3 failed. Correct answer:", actual, "Your answer:", student)

    else:
        print("PASSED") 
        tests_passed += 1
        a_tests += 1

if student_b:
	print('----PART B Test 1----')
	print('RUNNING with annual_salary: 110000, percent_saved: .15, total_cost_of_home: 750000, semi_annual_raise: .03')
	annual_salary = 110000
	percent_saved = .15
	total_cost_of_home = 750000
	semi_annual_raise = .03
	actual = 52
	student = student_b.part_b(annual_salary, percent_saved, total_cost_of_home, semi_annual_raise)
	if actual != student:
		print("FAILED") 
		print("Part B test 1 failed. Correct answer:", actual, "Your answer:", student)
	else: 
		print("PASSED")
		tests_passed += 1
		b_tests +=1



	print('----PART B Test 2----')
	print('RUNNING with annual_salary: 350000, percent_saved: .3, total_cost_of_home: 10000000, semi_annual_raise: .05')
	annual_salary = 350000
	percent_saved = .3
	total_cost_of_home = 10000000
	semi_annual_raise = .05
	actual = 83
	student = student_b.part_b(annual_salary, percent_saved, total_cost_of_home, semi_annual_raise)
	if actual != student: 
		print("FAILED")
		print("Part B test 2 failed. Correct answer:", actual, "Your answer:", student)

	else: 
		print("PASSED")
		tests_passed += 1
		b_tests += 1


if student_c:
	months = 36
	total_cost_of_home = 800000
	percent_down_payment = 0.12
	total_down_payment = total_cost_of_home * percent_down_payment
	print('----PART C Test 1----')
	print('RUNNING with initial_deposit: 65000')
	initial_deposit = 65000
	actual_r = 0.130859375
	actual_steps = 9
	student_r, student_steps = student_c.part_c(initial_deposit)
	student_savings = initial_deposit * (1 + student_r / 12) ** months
	if type(student_r) == str or (abs(student_savings - total_down_payment) >= 100 or abs(student_steps - actual_steps) > 2):
		print("FAILED")
		print("Part C Test 1 failed. Either your r value", student_r, "does not produce the correct savings, or your algorithm takes too few or too many steps. Expected answer:", actual_r, "in", actual_steps, "steps")

	else: 
		print("PASSED")
		tests_passed += 1
		c_tests += 1



	print('----PART C Test 2----')
	print('RUNNING with initial_deposit: 187401')
	initial_deposit = 27150
	actual_r = 0.4287109375
	actual_steps = 10
	student_r, student_steps = student_c.part_c(initial_deposit)
	student_savings = initial_deposit * (1 + student_r / 12) ** months
	if type(student_r) == str or (abs(student_savings - total_down_payment) >= 100 or abs(student_steps - actual_steps) > 2):
		print("FAILED")
		print("Part C Test 2 failed. Either your r value", student_r, "does not produce the correct savings, or your algorithm takes too few or too many steps. Expected answer:", actual_r, "in", actual_steps, "steps")

	else: 
		print("PASSED")
		tests_passed += 1
		c_tests += 1


	print('----PART C Test 3----')
	print('RUNNING with initial_deposit: 500')
	initial_deposit = 500
	actual_r = None
	student_r, student_steps = student_c.part_c(initial_deposit)
	if not student_r == actual_r:
		print("FAILED")
		print("Part C test 3 failed. Correct answer:", actual_r, "your_answer", student_r)

	else: 
		print("PASSED")
		tests_passed += 1
		c_tests += 1

	print('----PART C Test 4----')
	print('RUNNING with initial_deposit: 300000')
	initial_deposit = 300000
	actual_r = 0
	student_r, student_steps = student_c.part_c(initial_deposit)
	if not student_r == actual_r:
		print("FAILED")
		print("Part C test 4 failed. Correct answer:", actual_r, "your_answer", student_r)

	else: 
		print("PASSED")
		tests_passed += 1
		c_tests += 1

print("END OF TEST SUITE")
print("You have passed", tests_passed, "out of ", total_number_of_tests, "tests.")
print("PART A", a_tests, " out of 3")
print("PART B", b_tests, " out of 2")
print("PART C", c_tests, " out of 4")

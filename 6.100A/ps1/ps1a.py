## 6.100A Pset 1: Part a 
## Name: Miguel Flores-Acton
## Time Spent: 0:30
## Collaborators:

##################################################################################
## Get user input for annual_salary, percent_saved and total_cost_of_home below ##
##################################################################################
annual_salary = float(input("Enter your annual salary: "))
percent_saved = float(input("Enter the percent of your salary to save, as a decimal: "))
total_cost_of_home = float(input("Enter the cost of your dream home: "))

#########################################################################
## Initialize other variables you need (if any) for your program below ##
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
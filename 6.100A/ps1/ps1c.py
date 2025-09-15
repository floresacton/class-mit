## 6.100A Pset 1: Part c
## Name: Miguel Flores-Acton
## Time Spent: 0:20
## Collaborators:

##############################################
## Get user input for initial_deposit below ##
##############################################
initial_deposit = float(input("Enter the initial deposit: "))

#########################################################################
## Initialize other variables you need (if any) for your program below ##
#########################################################################
months = 36
house_cost = 800000
down_payment_percentage = 0.12
down_payment_cost = house_cost * down_payment_percentage
#variables for bisection search
search_min = 0
search_max = 1
steps = 0
r = None

##################################################################################################
## Determine the lowest rate of return needed to get the down payment for your dream home below ##
##################################################################################################
if initial_deposit >= down_payment_cost:
    r = 0
elif down_payment_cost <= initial_deposit*pow(1+1/12,months):
    while True:
        steps+=1
        r = (search_min+search_max)/2
        amount_saved = initial_deposit*pow(1+r/12,months)
        if amount_saved < down_payment_cost-100:
            search_min = r
        elif amount_saved > down_payment_cost+100:
            search_max = r
        else:
            break

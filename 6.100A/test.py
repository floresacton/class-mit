# def divisors(n):
#     """ n is an int greater than 1
#     Returns a list, in ascending order, of the divisors of n, including 1 and n. 
#     (a divisor is a number that divides into another without a remainder)
#     """
#     return [i+1 for i in range(n) if n%(i+1)==0]
        

# # For example:
# print(divisors(2))   # prints [1, 2]
# print(divisors(4))   # prints [1, 2, 4]
# print(divisors(15))  # prints [1, 3, 5, 15]

# def is_prime(x):
#     return not sum([x%i==0 for i in range(2, int(x**0.5)+1)])

# def sum_on_prime_f(L, f):
#     """ L is a non-empty list containing ints greater than 1
#         f is a function that takes in 2 ints and returns a number

#     Applies f to all pairs of elements of L at indices i and j, where:
#       * i and j range over all valid indices of L
#       * i != j
#       * elements at i and j are both prime numbers 
#     Return the sum of the outputs of f applied to all such pairs, or 0 if 
#      there are no such pairs. """
#     return (lambda prime:sum([sum([f(L[i], L[j]) for j in range(len(L)) if prime(L[j]) and i!=j]) for i in range(len(L)) if prime(L[i])]))(lambda x:not sum([x%i==0 for i in range(2, int(x**0.5)+1)]))
    # return sum([sum([f(L[i], L[j]) for j in range(len(L)) if prime(L[j]) and i!=j]) for i in range(len(L)) if prime(L[i])])

# # For example:
# print(sum_on_prime_f([3], lambda x,y:x-y))       
#                 # prints 0 (doesn't count element with itself)
# print(sum_on_prime_f([4,8], lambda x,y:x-y))     
#                 # prints 0 (no elements are primes)
# print(sum_on_prime_f([4,5], lambda x,y:x*y))     
#                 # prints 0 (doesn't count one prime element with itself) 
# print(sum_on_prime_f([2,3,4], lambda x,y:x*y))   
#                 # prints 12 (sums 2*3 + 3*2)
# print(sum_on_prime_f([5,7,7], lambda x,y:x*y)) 
                # prints 238 (5*7 + 5*7 + 7*5 + 7*7 + 7*5 + 7*7)
# def how_many_odds(L):
#     """ L is a special kind of list whose elements can be ints or 
#         this special type of list

#     Returns how many of the ints in L are odd and, recursively,
#     in all inner-lists of L.  """
#     if type(L) is int:
#         return L%2==1
    
#     return sum([how_many_odds(x) for x in L])

# # For example
# L = [3]
# print(how_many_odds(L))   # prints 1

# L = [5,3,8]
# print(how_many_odds(L))   # prints 2

# L = [[5]]
# print(how_many_odds(L))   # prints 1

# L = [5,[3,8],[[[7,12],3]]]
# print(how_many_odds(L))   # prints 4

# def invert_dict(d):
#     """ d is a dict where the keys and values are of type int

#     Returns a new dict. The keys of the returned dict are the
#     unique values in d. A value of the returned dict is a 
#     list, SORTED in DESCENDING order, containing all keys in d 
#     that have the same value in d.  """
#     dict = {}
#     for x in d.keys():
#         if d[x] in dict.keys():
#             dict[d[x]].append(x)
#         else:
#             dict[d[x]] = [x]

#     return dict

# # For example:
# print(invert_dict({}))             # prints {}
# print(invert_dict({1:2, 3:4}))     # prints {2: [1], 4: [3]}
# print(invert_dict({1:2, 3:2}))     # prints {2: [3, 1]}

# class WordLengths(object):
#     """ Objects of this class store a set of UNIQUE words. Users can 
#         retrieve words by the number of characters in the word. """
    
#     def __init__(self, words):
#         """ words is a list of lowercase str elements """
#         self.words = sorted(set(words))

#     def get_all_words(self):
#         """ Returns a copy of the list containing all the unique words 
#             stored in self, sorted in ascending alphabetical order. """
#         return self.words[:]

#     def get_words_with_length(self, length):
#         """ Asserts that length is an int > 0

#             Returns a list of words that have the given length.
#             The list should be sorted in ascending alphabetical order.
#             Returns an empty list if there are no words of that given length. """
#         assert(type(length) == int and length > 0)
#         assert(length > 0)
#         return [wd for wd in self.words if len(wd)==length]

#     def get_all_word_lengths(self):
#         """ Returns a list of all the unique lengths that words in self have. 
#             The list should be sorted in ascending order. """
#         return sorted(set([len(w) for w in self.words]))

#     def __add__(self, other):
#         """ Asserts that other is a WordLengths object

#             Returns a new WordLengths object that contains all of the words 
#             from self and other. """
#         assert(type(other) == WordLengths)
#         return WordLengths(self.get_all_words() + other.get_all_words())
        
# # For example:
# a = WordLengths(['abc', 'def', 'x', 'hijk', 'def'])
# print(a.get_all_words())            # prints ['abc', 'def', 'hijk', 'x']
# print(a.get_words_with_length(3))   # prints ['abc', 'def']
# print(a.get_words_with_length(2))   # prints []
# # print(a.get_words_with_length(-1))  # uncomment to see it raise an AssertionError

# print(a.get_all_word_lengths())     # prints [1,3,4]

# a = WordLengths(['abc', 'def', 'x', 'hijk', 'def'])
# b = WordLengths(['xkcd', 'x', 'smbc', 'me'])
# c = a+b
# print(c.get_words_with_length(4))   # prints ['hijk', 'smbc', 'xkcd']
# print(c.get_words_with_length(1))   # prints ['x']
# print(c.get_all_word_lengths())     # prints [1,2,3,4]
# #d = a + 'garfield'                # uncomment to see it raise an AssertionError

# for i in range(0, 6100-6101, -1):
#     print (i)

vout = 10
r_p = 4700.0 #4500 or greater

r_h = r_p/((4.0/(vout-8))-1.0)
r_y = 3.0/(1.0/r_h+2.0/(r_h+r_p))
r_x = 2.0/(1.0/r_y+1.0/r_h)

print(F"R_h {r_h}")
print(F"R_y {r_y}")
print(F"R_x {r_x}")

print()

r_y = 6800.0
r_x = 4700.0

v_l = 12.0/((r_x*(1.0/r_y+1.0/r_h))+1.0)
v_h = 12.0/(1.0/(r_y*(1.0/r_x+1.0/(r_h+r_p)))+1)

print(F"V_h {v_h}")
print(F"V_l {v_l}")
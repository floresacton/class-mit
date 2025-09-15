# Problem Set 2, wordle.py
# Name: Miguel Flores-Acton
# Collaborators:
# Time spent: 1:10

# Wordle Game
# -----------------------------------
# Helper code
# You don't need to understand this helper code,
# but you will have to know how to use the functions
# (so be sure to read the docstrings!)
import random
import string

WORDLIST_FILENAME = "words.txt"


def load_words():
    """
    Returns a list of valid words. Words are strings of lowercase letters.
    
    Depending on the size of the word list, this function may
    take a while to finish.
    """
    print("Loading word list from file...")
    # inFile: file
    inFile = open(WORDLIST_FILENAME, 'r')
    # line: string
    line = inFile.readline()
    # wordlist: list of strings
    wordlist = line.split()
    print("  ", len(wordlist), "words loaded.")
    return wordlist

def choose_word(wordlist):
    """
    wordlist (list): list of words (strings)
    Returns a word from wordlist at random
    """

    return random.choice(wordlist)

# end of helper code

# -----------------------------------

# Load the list of words into the variable wordlist
# so that it can be accessed from anywhere in the program
wordlist = load_words()

def check_user_input(secret_word, user_guess):
    """
    :param secret_word: a string, the word to be guessed
    :param user_guess: a string, the users guess
    :return: False if user_guess does not satisfy at least
	     one of the below conditions, True otherwise.
    1. must consist of only letters (uppercase or lowercase)
    2. must be the same length as secret_word
    3. must be a word found in words.txt
    """
    if len(secret_word) != len(user_guess):#if lengths are not equal
        print('Oops! That word length is not correct.')
        return False
    if not user_guess.isalpha():#if word is not alphabetical
        print('Oops! That is not a valid word.')
        return False
    if user_guess.lower() not in wordlist:#if word is not in the list
        print('Oops! That is not a real word.')
        return False
    return True

def get_guessed_feedback(secret_word, user_guess):
    """
    :param secret_word: a string, the word to be guessed
    :param user_guess: a string, a valid user guess
    :return: a string with uppercase and lowercase letters and 
	     underscores, each separated by a space (e.g. 'B _ _ S u')
    """
    
    output = ''
    length = len(secret_word)
    for i in range(length):
        if user_guess.lower()[i] == secret_word[i]:
            output += secret_word[i].upper()
        elif user_guess.lower()[i] in secret_word:
            output += user_guess.lower()[i];
        else:
            output += '_'

        if i != length-1:
            output += ' '

    return output

def get_alphabet_hint(secret_word, all_guesses):
    """
    takes in the secret word and a list of all previous guesses and returns a string of hint text
    :param secret_word: a string, the word to be guessed
    :param all_guesses: a list of all the previous valid guesses the user inputed
    :return: a string which replaces letters that were incorrect guesses with underscores and puts
	     semi-correct guesses (correct letter, incorrect place) in /x/
    """
    # we have coded this for you
    alphabet = "abcdefghijklmnopqrstuvwxyz"
    out_list = []
    for char in alphabet:
        out_list.append(" "+char+" ")

    for guess in all_guesses:
        for i, char in enumerate(list(guess)):
            if char not in secret_word:
                out_list[alphabet.find(char)]=" _ "
            elif char != secret_word[i]:
                out_list[alphabet.find(char)] = "/"+char+"/"
            elif char == secret_word[i]:
                if secret_word.count(char) > guess.count(char):
                    out_list[alphabet.find(char)] = "/" + char + "/"
                else:
                    out_list[alphabet.find(char)] = "|" + char.upper() + "|"
    return "".join(out_list)

def wordle(secret_word):
    '''
    secret_word: string, the secret word to guess.
    
    Starts up an interactive game of Wordle.
    
    * At the start of the game, let the user know how many letters the 
      secret_word contains and how many guesses and warnings they start with.
      
    * The user should start with 6 guesses and 3 warnings

    * Before each round, you should display to the user how many guesses
      they have left.
    
    * Ask the user to supply one guess per round. Remember to make
      sure that the user puts in a valid word!
    
    * The user should receive feedback immediately after each guess about 
      whether their guess is valid, how closely it matches the secret_word,
      and the alphabet hint.

    * After each guess, you should display to the user the progression of 
      their partially guessed words so far.
    
    Follows the other limitations detailed in the problem write-up.
    '''

    responses = [] #list of past and present responses from program
    all_guesses = [] #store past words guessed
    warnings = 3
    guesses = 6

    #initial text
    print('Welcome to the game Wordle!')
    print('I am thinking of a word that is '+str(len(secret_word))+' letters long.')
    print('You have '+str(warnings)+' warnings remaining.')

    #game loop
    while guesses > 0:
        print('You have '+str(guesses)+' guesses left.')
        user_guess = input("Please guess a word: ")
        if check_user_input(secret_word, user_guess):
            #if guess is valid
            all_guesses.append(user_guess)
            guesses -= 1
            if user_guess == secret_word:
                #if won
                print('Congratulations, you won!')
                print('You guessed the correct word in '+str(6-guesses)+' tries!')
                #len(set(secret_word)) is number of unique characters
                print('Your total score is '+str(len(set(secret_word))*guesses)+'.')
                return #finish game
            else:
                #give responses
                print('WORDLE response:')
                responses.append(get_guessed_feedback(secret_word, user_guess))
                for response in responses:
                    print(response)
                #give hint
                print('Alphabet HINT:')
                print(get_alphabet_hint(secret_word, all_guesses))
            if guesses == 0:#skip ------ if no guesses left
                break
        else:
            if warnings == 0:#only subtract guess if out of warnings
                guesses -= 1
            else:
                warnings -= 1
            if guesses == 0:#leave game if no guesses
                break
            print('You have '+str(warnings)+' warnings remaining.')


        print('----------')
    #if ran out of guesses
    print('Sorry, you ran out of guesses. The word was '+secret_word+'.')


if __name__ == "__main__":
    # To test, comment out the `pass` line above and uncomment:
    # - either of the `secret_word = ...` lines below, depending on how you want to set the secret_word
    # - the `wordle(secret_word)` line to run the game

    # uncomment and change the line below to a specific word for testing
    # secret_word = "rink"

    # uncomment the line below for a randomly generated word
    secret_word = choose_word(wordlist)

    wordle(secret_word)
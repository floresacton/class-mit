# for running unit tests on 6.100A/B/L student code

import sys
import unittest
import os
import string
from unittest.mock import patch
from unittest import TestCase
import re
import random
#pulled from http://stackoverflow.com/questions/20567497/overwrite-built-in-function
outputstr=""
class MyStream(object):
    def __init__(self, target):
        self.target = target

    def write(self, s):
        global outputstr
        outputstr+=s
        return s
    def flush(self):
        pass

HIDDEN = "_"

store = sys.stdout
sys.stdout = MyStream(sys.stdout)

def Dprint(*args):
    """
    Prints output to sys.__stdout__ then reverts the output of print to
    wherever it was before debugging. Useful for adding print statements in the
    testers to see if your game is printing the lines you think it should be.
    """
    global store
    sys.stdout = store
    print(*args)
    sys.stdout = MyStream(sys.stdout)


input_string = (word for word in ["cranky", "alcove", "octave"])
def make_input(self):
    return next(input_string)

def output_to_file(test_case_name, word_to_guess, guessed_letters, student_output, correct_output):
    with open('run_game_test_results.txt', 'a+') as f:
        f.write("=============================================================\n")
        f.write("RESULTS FOR TEST CASE: %s\n"%test_case_name)
        f.write("WORD USED IN TEST: %s\n"%word_to_guess)
        f.write("GUESSED LETTERS IN ORDER OF GUESS: %s\n"%guessed_letters)
        f.write('************************\n')
        f.write("YOUR OUTPUT:\n")
        f.write('************************\n')
        f.write(student_output+'\n')
        f.write('************************\n')
        f.write("POSSIBLE CORRECT OUTPUT:\n")
        f.write('************************\n')
        f.write(correct_output+'\n')
        f.write("=============================================================\n\n\n")

def compare_results(expected, actual):
    '''
    Used for comparing equality of student answers with staff answers
    '''
    def almost_equal(x,y):
        if x == y or x.replace(' ', '') == y.replace(' ',''):
            return True
        return False

    exp = expected.strip()
    act = actual.strip()
    return almost_equal(exp, act)


# A class that inherits from unittest.TestCase, where each function
# is a test you want to run on the student's code. For a full description
# plus a list of all the possible assert methods you can use, see the
# documentation: https://docs.python.org/3/library/unittest.html#unittest.TestCase
class TestPS2(unittest.TestCase):

    def test_check_user_input_correct_guess(self):
        self.assertTrue(student.check_user_input('as', 'as'))
        self.assertTrue(student.check_user_input('pat', 'pat'))
        self.assertTrue(student.check_user_input('face', 'face'))
        self.assertTrue(student.check_user_input('paint', 'paint'))

    def test_check_user_input_incorrect_word(self):
        self.assertTrue(student.check_user_input('as', 'if'))
        self.assertTrue(student.check_user_input('pat', 'tip'))
        self.assertTrue(student.check_user_input('face', 'tarp'))
        self.assertTrue(student.check_user_input('paint', 'dusky'))

    def test_check_user_input_wrong_word_length(self):
        self.assertFalse(student.check_user_input('face', 'tarps'))
        self.assertFalse(student.check_user_input('moves', 'tar'))
        self.assertFalse(student.check_user_input('cat', ''))

    def test_check_user_input_invalid_characters(self):
        self.assertFalse(student.check_user_input('face', '1234'))
        self.assertFalse(student.check_user_input('moves', '@#$%^'))
        self.assertFalse(student.check_user_input('face', 'fac^'))
        self.assertFalse(student.check_user_input('moves', 'mov3s'))
        self.assertFalse(student.check_user_input('tarp', '7arp'))

    def test_get_guessed_feedback_none_correct(self):
        self.assertEqual(student.get_guessed_feedback('if', 'on'),
            '_ _')
        self.assertEqual(student.get_guessed_feedback('cat', 'men'),
            '_ _ _')
        self.assertEqual(student.get_guessed_feedback('face', 'plot'),
            '_ _ _ _')
        self.assertEqual(student.get_guessed_feedback('sassy', 'their'),
            '_ _ _ _ _')

    def test_get_guessed_feedback_incorrect_location(self):
        self.assertEqual(student.get_guessed_feedback('in', 'no'),
            'n _')
        self.assertEqual(student.get_guessed_feedback('cat', 'arc'),
            'a _ c')
        self.assertEqual(student.get_guessed_feedback('face', 'cent'),
            'c e _ _')
        self.assertEqual(student.get_guessed_feedback('sassy', 'means'),
            '_ _ a _ s')

    def test_get_guessed_feedback_some_correct(self):
        self.assertEqual(student.get_guessed_feedback('in', 'on'),
            '_ N')
        self.assertEqual(student.get_guessed_feedback('cat', 'can'),
            'C A _')
        self.assertEqual(student.get_guessed_feedback('face', 'fade'),
            'F A _ E')
        self.assertEqual(student.get_guessed_feedback('sassy', 'saint'),
            'S A _ _ _')

    def test_get_guessed_feedback_correct_word(self):
        self.assertEqual(student.get_guessed_feedback('in', 'in'),
            'I N')
        self.assertEqual(student.get_guessed_feedback('cat', 'cat'),
            'C A T')
        self.assertEqual(student.get_guessed_feedback('face', 'face'),
            'F A C E')
        self.assertEqual(student.get_guessed_feedback('sassy', 'sassy'),
            'S A S S Y')
            
    def test_play_game_short(self):
        correct='''Loading word list from file...
   55900 words loaded.
Welcome to the game Wordle!
I am thinking of a word that is 6 letters long.
You have 3 warnings remaining.
You have 6 guesses left.
Please guess a word: cranky
WORDLE response:
c _ a _ _ _
Alphabet HINT:
/a/ b /c/ d  e  f  g  h  i  j  _  l  m  _  o  p  q  _  s  t  u  v  w  x  _  z 
--------------
You have 5 guesses left.
Please guess a word: alcove
WORDLE response:
c _ a _ _ _
a _ c o V E
Alphabet HINT:
/a/ b /c/ d |E| f  g  h  i  j  _  _  m  _ /o/ p  q  _  s  t  u |V| w  x  _  z 
--------------
You have 4 guesses left.
Please guess a word: octave
Congratulations, you won!
You guessed the correct word in 3 tries!
Your total score is 18.'''
        with unittest.mock.patch('builtins.input',  make_input):
            threw_exception =  False
            try:
                student.wordle("octave")
            except Exception as e:
                threw_exception = True
            global outputstr
            student_output = outputstr[:]
            sections = re.split('\-{3,}',outputstr)
            outputstr =""
            try:
                self.assertFalse(threw_exception, "test_play_game_short test could not be run to completion!")
                if len(sections) == 3:
                    self.assertTrue("6 letters" in sections[0], "Incorrect word length")
                    self.assertTrue("6 guesses" in sections[0], "Incorrect number of guesses remaining.")
                    self.assertTrue("3 warnings" in sections[0], "Incorrect warnings remaining.")
                    self.assertTrue("c _ a _ _ _" in sections[0], "Incorrect word progress after first guess")

                    self.assertTrue("5 guesses" in sections[1], "Incorrect number of guesses remaining.")
                    self.assertTrue("a _ c o V E" in sections[1], "Incorrect word progress after second guess")

                    self.assertTrue("4 guesses" in sections[2], "Incorrect number of guesses remaining.")
                    self.assertTrue("3 tries" in sections[2], "Incorrect count of guesses")
                    self.assertTrue("Congratulations, you won!" in sections[2], "Incorrect winning criteria")
                    self.assertTrue("score" in sections[2], "Please include the word \'score\' when revealing final score!")
                    self.assertTrue("18" in sections[2], "Incorrect final score. Expected 18.")
                else:
                    self.assertTrue(False, "Incorrect number of output sections (defined by rows of atleast 3 dashes). \
                        Compare with sample outputs for the expected placement of dashes.")
            except Exception as e:
                output_to_file('test_play_game_short', 'octave', ["cranky", "alcove", "octave"], student_output, correct)
                raise(e)

    def test_play_game_short_fail(self):
        correct='''Loading word list from file...
   55900 words loaded.
Welcome to the game Wordle!
I am thinking of a word that is 4 letters long
You have 3 warnings remaining
You have 6 guesses left.
Please guess a word: deaf
WORDLE response:
_ e _ _
Alphabet HINT:
 _  b  c  _ /e/ _  g  h  i  j  k  l  m  n  o  p  q  r  s  t  u  v  w  x  y  z 
----------
You have 5 guesses left.
Please guess a word: more
WORDLE response:
_ e _ _
_ O _ E
Alphabet HINT:
 _  b  c  _ |E| _  g  h  i  j  k  l  _  n |O| p  q  _  s  t  u  v  w  x  y  z 
----------
You have 4 guesses left.
Please guess a word: hope
WORDLE response:
_ e _ _
_ O _ E
_ O _ E
Alphabet HINT:
 _  b  c  _ |E| _  g  _  i  j  k  l  _  n |O| _  q  _  s  t  u  v  w  x  y  z 
----------
You have 3 guesses left.
Please guess a word: sole
WORDLE response:
_ e _ _
_ O _ E
_ O _ E
_ O _ E
Alphabet HINT:
 _  b  c  _ |E| _  g  _  i  j  k  _  _  n |O| _  q  _  _  t  u  v  w  x  y  z 
----------
You have 2 guesses left.
Please guess a word: joke
WORDLE response:
_ e _ _
_ O _ E
_ O _ E
_ O _ E
_ O _ E
Alphabet HINT:
 _  b  c  _ |E| _  g  _  i  _  _  _  _  n |O| _  q  _  _  t  u  v  w  x  y  z 
----------
You have 1 guesses left.
Please guess a word: tone
WORDLE response:
_ e _ _
_ O _ E
_ O _ E
_ O _ E
_ O _ E
_ O _ E
Alphabet HINT:
 _  b  c  _ |E| _  g  _  i  _  _  _  _  /n/ |O| _  q  _  _  _  u  v  w  x  y  z 
Sorry, you ran out of guesses. The word was none.'''
        global input_string
        input_string = (word for word in ["deaf", "more", "hope", "sole", "joke", "tone"])
        with unittest.mock.patch('builtins.input',  make_input):
            threw_exception =  False
            try:
                student.wordle("none")
            except Exception as e:
                threw_exception = True
            global outputstr
            sections = re.split('\-{3,}',outputstr)
            student_output = outputstr[:]
            outputstr =""
            try:
                self.assertFalse(threw_exception, "test_play_game_short test could not be run to completion!")
                if len(sections) == 6:
                    self.assertTrue("4 letters" in sections[0], "Incorrect word length")
                    self.assertTrue("6 guesses" in sections[0], "Incorrect number of guesses remaining.")
                    self.assertTrue("3 warnings" in sections[0], "Incorrect warnings remaining.")
                    self.assertTrue("_ e _ _" in sections[0], "Incorrect word progress after first guess")

                    self.assertTrue("5 guesses" in sections[1], "Incorrect number of guesses remaining.")
                    self.assertTrue("_ O _ E" in sections[1], "Incorrect word progress after second guess")

                    self.assertTrue("4 guesses" in sections[2], "Incorrect number of guesses remaining.")
                    self.assertTrue("_ O _ E" in sections[2], "Incorrect word progress after third guess")

                    self.assertTrue("3 guesses" in sections[3], "Incorrect number of guesses remaining.")
                    self.assertTrue("_ O _ E" in sections[3], "Incorrect word progress after fourth guess")

                    self.assertTrue("2 guesses" in sections[4], "Incorrect number of guesses remaining.")
                    self.assertTrue("_ O _ E" in sections[4], "Incorrect word progress after fifth guess")

                    self.assertTrue("1 guess" in sections[5], "Incorrect number of guesses remaining.")
                    self.assertTrue("_ O _ E" in sections[5], "Incorrect word progress after sixth guess")

                    self.assertTrue("ran out of guesses" in sections[5], "Incorrect losing criteria; reveal to player that they ran out of guesses.")
                else:
                    self.assertTrue(False, "Incorrect number of output sections (defined by rows of at least 3 dashes). \
                        Compare with sample outputs for the expected placement of dashes.")
            except Exception as e:
                output_to_file('test_play_game_short_fail', 'none', ["deaf", "more", "hope", "sole", "joke", "tone"], student_output, correct)
                raise(e)
            
    def test_play_game_warnings(self):
        correct='''Loading word list from file...
   55900 words loaded.
Welcome to the game Wordle!
I am thinking of a word that is 4 letters long
You have 3 warnings remaining
You have 6 guesses left.
Please guess a word: abcd 
Oops! That is not a real word.
You have 2 warnings remaining.
----------
You have 6 guesses left.
Please guess a word: 1234 
Oops! That is not a valid word.
You have 1 warnings remaining.
----------
You have 6 guesses left.
Please guess a word: a!222 
Oops! That word length is not correct.
You have 0 warnings remaining.
----------
You have 6 guesses left.
Please guess a word: 2@39
Oops! That is not a valid word.
You have 0 warnings remaining.
----------
You have 5 guesses left.
Please guess a word: aa88
Oops! That is not a valid word.
You have 0 warnings remaining.
----------
You have 4 guesses left.
Please guess a word: deaf
WORDLE response:
_ e _ _
Alphabet HINT:
 _  b  c  _ /e/ _  g  h  i  j  k  l  m  n  o  p  q  r  s  t  u  v  w  x  y  z 
----------
You have 3 guesses left.
Please guess a word: none
WORDLE response:
Congratulations, you won!
You guessed the correct word in 4 tries!
Your total score is 6.'''
        global input_string
        input_string = (word for word in ["abcd", "1234", "a!222", "2@39", "aa88", "deaf", "none"])
        with unittest.mock.patch('builtins.input',  make_input):
            threw_exception =  False
            try:
                student.wordle("none")
            except Exception as e:
                threw_exception = True
            global outputstr
            sections = re.split('\-{3,}',outputstr)
            student_output = outputstr[:]
            outputstr =""
            try:
                self.assertFalse(threw_exception, "test_play_game_warnings test could not be run to completion!")
                if len(sections) == 7:
                    self.assertTrue("4 letters" in sections[0], "Incorrect word length")
                    self.assertTrue("6 guesses" in sections[0], "Incorrect number of guesses remaining.")
                    self.assertTrue("3 warnings" in sections[0], "Incorrect warnings remaining.")
                    self.assertTrue("Oops! That is not a real word." in sections[0], "Incorrect detection of word not in dictionary")
                    self.assertTrue("2 warnings" in sections[0], "Incorrect warnings remaining.")

                    self.assertTrue("6 guesses" in sections[1], "Incorrect number of guesses remaining.")
                    self.assertTrue("Oops! That is not a valid word." in sections[1], "Incorrect detection of invalid characters")
                    self.assertTrue("1 warning" in sections[1], "Incorrect warnings remaining.")

                    self.assertTrue("6 guesses" in sections[2], "Incorrect number of guesses remaining.")
                    self.assertTrue("Oops! That word length is not correct." in sections[2], "Incorrect detection of wrong word length")
                    self.assertTrue("0 warning" in sections[2], "Incorrect warnings remaining.")

                    self.assertTrue("6 guesses" in sections[3], "Incorrect number of guesses remaining.")
                    self.assertTrue("Oops! That is not a valid word." in sections[3], "Incorrect detection of invalid characters")
                    self.assertTrue("0 warning" in sections[3], "Incorrect warnings remaining.")

                    self.assertTrue("5 guesses" in sections[4], "Incorrect number of guesses remaining.")
                    self.assertTrue("Oops! That is not a valid word." in sections[4], "Incorrect detection of invalid characters")
                    self.assertTrue("0 warning" in sections[4], "Incorrect warnings remaining.")

                    self.assertTrue("4 guesses" in sections[5], "Incorrect number of guesses remaining.")
                    self.assertTrue("_ e _ _" in sections[5], "Incorrect word progress")

                    self.assertTrue("3 guesses" in sections[6], "Incorrect number of guesses remaining.")
                    self.assertTrue("Congratulations, you won!" in sections[6], "Incorrect winning criteria")
                    self.assertTrue("score" in sections[6], "Please include the word \'score\' when revealing final score!")
                    self.assertTrue("6" in sections[6], "Incorrect final score. Expected 6.")
                else:
                    self.assertTrue(False, "Incorrect number of output sections (defined by rows of atleast 3 dashes). \
                        Compare with sample outputs for the expected placement of dashes.")
            except Exception as e:
                output_to_file('test_play_game_warnings', 'none', ["deaf", "more", "hope", "sole", "joke", "tone"], student_output, correct)
                raise(e)

# Dictionary mapping function names from the above TestCase class to
# messages you'd like the student to see if the test fails.
failure_messages = {
    'test_check_user_input_correct_guess' : 'Your function check_user_input() does not return the correct result.',
    'test_check_user_input_incorrect_word' : 'Your function check_user_input() does not return the correct result for an incorrect guess.',
    'test_check_user_input_wrong_word_length': 'Your function check_user_input() does not return the correct result for guesses of the incorrect length',
    'test_check_user_input_invalid_characters': 'Your function check_user_input() does not return the correct result for invalid character inputs.',
    'test_get_guessed_feedback_none_correct' : 'Your function get_guessed_feedback() does not return the correct result for guesses with no correct letters.',
    'test_get_guessed_feedback_incorrect_location' : 'Your function get_guessed_feedback() does not return the correct result when letters are in the wrong place.',
    'test_get_guessed_feedback_some_correct': 'Your function get_guessed_feedback() does not return the correct result when some letters are correct.',
    'test_get_guessed_feedback_correct_word': 'Your function get_guessed_feedback() does not return the correct result when the correct word is guessed.',
    'test_play_game_short': 'Your function wordle() does not display the expected gameplay',
    'test_play_game_short_fail': 'Your function wordle() does not display the expected gameplay when word is not guessed',
    'test_play_game_warnings': 'Your function wordle() does not display the expected gameplay when players receive warnings'
}

# Dictionary mapping function names from the above TestCase class to
# messages you'd like the student to see if their code throws an error.
error_messages = {
    'test_check_user_input_correct_guess' : 'Your function check_user_input() produces an error.',
    'test_check_user_input_incorrect_word' : 'Your function check_user_input() produces an error for an incorrect guess.',
    'test_check_user_input_wrong_word_length': 'Your function check_user_input() produces an error for guesses of the incorrect length',
    'test_check_user_input_invalid_characters': 'Your function check_user_input() produces an error for invalid character inputs.',
    'test_get_guessed_feedback_none_correct': 'Your function get_guessed_feedback() produces an error for no correct letters.',
    'test_get_guessed_feedback_incorrect_location': 'Your function get_guessed_feedback() produces an error when letters are in the wrong place.',
    'test_get_guessed_feedback_some_correct': 'Your function get_guessed_feedback() produces an error when some letters are correct.',
    'test_get_guessed_feedback_correct_word': 'Your function get_guessed_feedback() produces an error when the correct word is guessed.',
    'test_play_game_short': 'Your function wordle() does not display the expected gameplay',
    'test_play_game_short_fail': 'Your function wordle() does not display the expected gameplay when word is not guessed',
    'test_play_game_warnings': 'Your function wordle() does not display the expected gameplay when players recieve warnings'
}

# Dictionary mapping function names from the above TestCase class to
# the point value each test is worth. 
point_values = {
    'test_check_user_input_correct_guess' : .40,
    'test_check_user_input_incorrect_word' : .40,
    'test_check_user_input_wrong_word_length': .40,
    'test_check_user_input_invalid_characters': .40,
    'test_get_guessed_feedback_none_correct': .40,
    'test_get_guessed_feedback_incorrect_location': .40,
    'test_get_guessed_feedback_some_correct': .40,
    'test_get_guessed_feedback_correct_word': .40,
    'test_play_game_short': .60,
    'test_play_game_short_fail': .60,
    'test_play_game_warnings': .60
}

# Subclass to track a point score and appropriate
# grade comment for a suit of unit tests
class Results_600(unittest.TextTestResult):

    # We override the init method so that the Result object
    # can store the score and appropriate test output.
    def __init__(self, *args, **kwargs):
        super(Results_600, self).__init__(*args, **kwargs)
        self.output = []
        self.points = 5

    def addFailure(self, test, err):
        test_name = test._testMethodName
        self.handleDeduction(test_name, failure_messages)
        super(Results_600, self).addFailure(test, err)

    def addError(self, test, err):
        test_name = test._testMethodName
        self.handleDeduction(test_name, error_messages)
        super(Results_600, self).addError(test, err)

    def handleDeduction(self, test_name, messages):
        point_value = point_values[test_name]
        message = messages[test_name]
        self.output.append('[-%s]: %s' % (point_value, message))
        self.points -= round(point_value,2)

    def getOutput(self):
        if len(self.output) == 0:
            return "All correct!"
        return '\n'.join(self.output)

    def getPoints(self):
        return self.points

if __name__ == '__main__':
    exec("import wordle as student")

    sys.stdout = store
    print("Running unit tests")
    sys.stdout = MyStream(sys.stdout)
    suite = unittest.TestSuite()
    suite.addTest(unittest.makeSuite(TestPS2))
    result = unittest.TextTestRunner(verbosity=2, resultclass=Results_600).run(suite)

    output = result.getOutput()
    points = round(result.getPoints(),3)
    if points <=0:
        points=0.0
    sys.stdout = store

    print("\n\nProblem Set 2 Unit Test Results:")
    print(output)
    print("Points for these tests: %s/5\n (Please note that this is not your final pset score, additional test cases will be run on submissions)" % points)

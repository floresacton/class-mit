 # Problem Set 4C
# Name: Miguel Flores-Acton
# Collaborators:
# Time Spent: 0:40
# Late Days Used: 0

import json
from ps4b import PlaintextMessage, EncryptedMessage # Importing your work from Part B

### HELPER CODE ###
def load_words(file_name):
    '''
    file_name (string): the name of the file containing
    the list of words to load

    Returns: a list of valid words. Words are strings of lowercase letters.

    Depending on the size of the word list, this function may
    take a while to finish.
    '''
    # inFile: file
    with open(file_name, 'r') as inFile:
        # wordlist: list of strings
        wordlist = []
        for line in inFile:
            wordlist.extend([word.lower() for word in line.split(' ')])
        return wordlist

def is_word(word_list, word):
    '''
    Determines if word is a valid word, ignoring
    capitalization and punctuation

    word_list (list): list of words in the dictionary.
    word (string): a possible word.

    Returns: True if word is in word_list, False otherwise

    Example:
    >>> is_word(word_list, 'bat') returns
    True
    >>> is_word(word_list, 'asdf') returns
    False
    '''
    word = word.strip(" !@#$%^&*()-_+={}[]|\:;'<>?,./\"").lower()
    return word in word_list

def get_story_string():
    """
    Returns: a story in encrypted text.
    """
    f = open("story.txt", "r")
    story = str(f.read())
    f.close()
    return story[:-1]

def get_story_pads():
    """
    Returns: pads used to encrypt story. 
    """
    with open('pads.txt') as json_file:
        return json.load(json_file)

WORDLIST_FILENAME = 'words.txt'
### END HELPER CODE ###

def decrypt_message_try_pads(ciphertext, pads):
    '''
    Given a ciphertext and a list of possible pads used to create it, 
    find the pad used to create the ciphertext

    We will consider the pad used to create the ciphertext as the pad 
    that results in a plaintext with the most valid English words

    ciphertext (EncryptedMessage): The ciphertext
    pads (list of lists of ints): A list of pads which might 
        have been used to encrypt the ciphertext

    Returns: (PlaintextMessage) A message with the decrypted ciphertext and the best pad
    '''
    #load words
    word_list = load_words(WORDLIST_FILENAME)

    #helper function to count words in message
    def word_count(pad):
        plain_message = ciphertext.decrypt_message(pad)#test the pad with the ciphertext
        message_text = plain_message.get_text()#get raw message

        count = 0
        for word in message_text.split(" "):
            if is_word(word_list, word):
                count += 1

        return count

    #index of pad with the most words
    best_pad = 0
    #amount of words in best_pad
    most_words = word_count(pads[0])

    for i in range(1, len(pads)):
        #if better plain message
        if word_count(pads[i]) >= most_words:
            #update best_pad and most_words
            best_pad = i
            most_words = word_count(pads[i])

    #return PlainTextMessage decryption of best pad
    return ciphertext.decrypt_message(pads[best_pad])

def decode_story():
    '''
    Write your code here to decode Bob's story using a list of possible pads
    Hint: use the helper functions get_story_string and get_story_pads and your EncryptedMessage class.

    Returns: (string) the decoded story

    '''
    #load files
    story_pads = get_story_pads()
    story_string = get_story_string()

    #load story string into encrypted message
    ciphertext = EncryptedMessage(story_string)

    #returns the text of decrypted message
    return decrypt_message_try_pads(ciphertext, story_pads).get_text()

if __name__ == '__main__':
    # # Uncomment these lines to try running decode_story()
    # story = decode_story()
    # print("Decoded story: ", story)

    # This test is checking encoding a lowercase string with punctuation in it.
    # plaintext = PlaintextMessage('hello! ', [2, 0, 1, 4, 3, 36])
    # print('Expected Output: jemprE')
    # print('Actual Output:', plaintext.get_ciphertext())

    # # This test is checking decoding a lowercase string with punctuation in it.
    # encrypted = EncryptedMessage('jemprE')
    # print('Expected Output:', 'hello!')
    # print('Actual Output:', encrypted.decrypt_message([2, 0, 1, 4, 3, 36]).get_text())
    pass

# 6.100A Fall 2023
# Problem Set 3
# Name: Miguel Flores-Acton
# Collaborators: 

"""
Description:
    Computes the similarity between two texts using two different metrics:
    (1) shared words, and (2) term frequency-inverse document
    frequency (TF-IDF).
"""

import string
import math
import re

### DO NOT MODIFY THIS FUNCTION
def load_file(filename):
    """
    Args:
        filename: string, name of file to read
    Returns:
        string, contains file contents
    """
    # print("Loading file %s" % filename)
    inFile = open(filename, 'r')
    line = inFile.read().strip()
    for char in string.punctuation:
        line = line.replace(char, "")
    inFile.close()
    return line.lower()


### Problem 1: Prep Data ###
def prep_data(input_text):
    """
    Args:
        input_text: string representation of text from file,
                    assume the string is made of lowercase characters
    Returns:
        list representation of input_text, where each word is a different element in the list
    """
    #split on spaces
    return input_text.split()


### Problem 2: Get Frequency ###
def get_frequencies(word_list):
    """
    Args:
        word_list: list of strings, all are made of lowercase characters
    Returns:
        dictionary that maps string:int where each string
        is a word in l and the corresponding int
        is the frequency of the word in l
    """
    #create dictionary
    dictionary = {}
    for word in word_list:#every element
        #check if word is already present
        if word in dictionary.keys():
            dictionary[word] += 1
        else: #create dictionary entry (key) = 1
            dictionary[word] = 1
    return dictionary


### Problem 3: Get Words Sorted by Frequency
def get_words_sorted_by_frequency(frequencies_dict):
    """
    Args:
        frequencies_dict: dictionary that maps a word to its frequency
    Returns:
        list of words sorted by decreasing frequency with ties broken
        by alphabetical order
    """
    #compares a and b, both keys input
    def compare(a, b):
        if frequencies_dict[b] > frequencies_dict[a]:
            return True
        elif frequencies_dict[a] > frequencies_dict[b]:
            return False
        else:#by alphabetical
            return a > b
    
    sort_list = list(frequencies_dict.keys())
    for i in range(len(sort_list)):
        for j in range(i+1, len(sort_list)):
            if compare(sort_list[i], sort_list[j]):
                temp = sort_list[j]
                sort_list[j] = sort_list[i]
                sort_list[i] = temp
            
    return sort_list


### Problem 4: Most Frequent Word(s) ###
def get_most_frequent_words(dict1, dict2):
    """
    The keys of dict1 and dict2 are all lowercase,
    you will NOT need to worry about case sensitivity.

    Args:
        dict1: frequency dictionary for one text
        dict2: frequency dictionary for another text
    Returns:
        list of the most frequent word(s) in the input dictionaries

    The most frequent word:
        * is based on the combined word frequencies across both dictionaries.
          If a word occurs in both dictionaries, consider the sum the
          frequencies as the combined word frequency.
        * need not be in both dictionaries, i.e it can be exclusively in
          dict1, dict2, or shared by dict1 and dict2.
    If multiple words are tied (i.e. share the same highest frequency),
    return an alphabetically ordered list of all these words.
    """
    #all words in both dictionaries
    all_words = set(list(dict1.keys())+list(dict2.keys()))
    #create new ditionary to hold combined values
    combined_dictionary = {}
    for word in all_words:
        total = 0#count per word
        if word in dict1.keys():#add to total if in dict1
            total += dict1[word]
        if word in dict2.keys():#add to total if in dict2
            total += dict2[word]
        combined_dictionary[word] = total
    

    #holds the max count of any word in the dictionary
    maximum = 0
    #find max
    for word in all_words:
        maximum = max(maximum, combined_dictionary[word])

    max_count = 0
    #count how many words have this value in combined dictionary
    for word in all_words:
        if combined_dictionary[word] == maximum:
            max_count+=1

    #return max_count many from the list of sorted by frequency
    return get_words_sorted_by_frequency(combined_dictionary)[:max_count]
    

### Problem 5: Similarity ###
def calculate_similarity_score(dict1, dict2):
    """
    The keys of dict1 and dict2 are all lowercase,
    you will NOT need to worry about case sensitivity.

    Args:
        dict1: frequency dictionary of words of text1
        dict2: frequency dictionary of words of text2
    Returns:
        float, a number between 0 and 1, inclusive
        representing how similar the words/texts are to each other

        The difference in words/text frequencies = DIFF sums "frequencies"
        over all unique elements from dict1 and dict2 combined
        based on which of these three scenarios applies:
        * If an element occurs in dict1 and dict2 then
          get the difference in frequencies
        * If an element occurs only in dict1 then take the
          frequency from dict1
        * If an element occurs only in dict2 then take the
          frequency from dict2
         The total frequencies = ALL is calculated by summing
         all frequencies in both dict1 and dict2.
        Return 1-(DIFF/ALL) rounded to 2 decimal places
    """
    all_words = set(list(dict1.keys()) + list(dict2.keys()))

    def count(word, dictionary):
        if word in dictionary.keys():
            return dictionary[word]
        return 0

    def delta(word):
        return abs(count(word, dict1) - count(word, dict2))
    
    def rho(word):
        return count(word, dict1) + count(word, dict2)
    
    #add up all rho values for divisor
    denominator = float(sum([rho(word) for word in all_words]))
    numerator = float(sum([delta(word) for word in all_words]))
    return round(1.0 - numerator/denominator, 2)



### Problem 6: Finding TF-IDF ###
def get_tf(text_file):
    """
    Args:
        text_file: name of file in the form of a string
    Returns:
        a dictionary mapping each word to its TF

    * TF is calculated as TF(i) = (number times word *i* appears
        in the document) / (total number of words in the document)
    * Think about how we can use get_frequencies from earlier
    """
    # loads words from file
    words = prep_data(load_file(text_file))
    total_words = len(words)
    frequencies = get_frequencies(words)

    #create dictionary to be added to
    dictionary = {}
    for word in words:
        #calculate TF
        dictionary[word] = frequencies[word]/total_words

    return dictionary


def get_idf(text_files):
    """
    Args:
        text_files: list of names of files, where each file name is a string
    Returns:
       a dictionary mapping each word to its IDF

    * IDF is calculated as IDF(i) = log_10(total number of documents / number of
    documents with word *i* in it), where log_10 is log base 10 and can be called
    with math.log10()

    """
    #each file
    doc_freq = {}
    num_documents = len(text_files)

    for file in text_files:
        #get document's words
        words = prep_data(load_file(file))
        #non duplicate of words
        word_set = set(words)
        #add 1 for each word in word_set to the dictionary
        for word in word_set:
            if word in doc_freq.keys():
                doc_freq[word] += 1
            else:
                doc_freq[word] = 1
    
    #calculate idf for each word
    dict_idf = {}
    for word in doc_freq.keys():
        dict_idf[word] = math.log10(num_documents/doc_freq[word])
    
    return dict_idf


def get_tfidf(text_file, text_files):
    """
    Args:
        text_file: name of file in the form of a string (used to calculate TF)
        text_files: list of names of files, where each file name is a string
        (used to calculate IDF)
    Returns:
       a sorted list of tuples (in increasing TF-IDF score), where each tuple is
       of the form (word, TF-IDF). In case of words with the same TF-IDF, the
       words should be sorted in increasing alphabetical order.

    * TF-IDF(i) = TF(i) * IDF(i)
    """
    #get dictionaries of word values
    dict_tf = get_tf(text_file)
    dict_idf = get_idf(text_files)

    #create output touple array
    list_tfidf = []
    for word in dict_tf:
        #calculate tfidf
        list_tfidf.append((word, dict_tf[word]*dict_idf[word]))

    #compare function for tuple a and b
    def compare(a, b):
        #by value
        if a[1] > b[1]:
            return True
        elif b[1] > a[1]:
            return False
        else:#by alphabetical
            return a[0] > b[0]

    #bubble sort using compare function
    for i in range(len(list_tfidf)):
        for j in range(i+1, len(list_tfidf)):
            if compare(list_tfidf[i], list_tfidf[j]):
                temp = list_tfidf[j]
                list_tfidf[j] = list_tfidf[i]
                list_tfidf[i] = temp

    return list_tfidf



if __name__ == "__main__":
    ## Uncomment the following lines to test your implementation
    ## Tests Problem 1: Prep Data
    test_directory = "tests/student_tests/"
    hello_world, hello_friend = load_file(test_directory + 'hello_world.txt'), load_file(test_directory + 'hello_friends.txt')
    world, friend = prep_data(hello_world), prep_data(hello_friend)
    print(world) ## should print ['hello', 'world', 'hello', 'there']
    print(friend) ## should print ['hello', 'friends']

    ## Tests Problem 2: Get Frequencies
    world_word_freq = get_frequencies(world)
    friend_word_freq = get_frequencies(friend)
    print(world_word_freq) ## should print {'hello': 2, 'world': 1, 'there': 1}
    print(friend_word_freq) ## should print {'hello': 1, 'friends': 1}

    ## Tests Problem 3: Get Words Sorted by Frequency
    world_words_sorted_by_freq = get_words_sorted_by_frequency(world_word_freq)
    friend_words_sorted_by_freq = get_words_sorted_by_frequency(friend_word_freq)
    print(world_words_sorted_by_freq) ## should print ['hello', 'there', 'world']
    print(friend_words_sorted_by_freq) ## should print ['friends', 'hello']

    ## Tests Problem 4: Most Frequent Word(s)
    freq1, freq2 = {"hello":5, "world":1}, {"hello":1, "world":5}
    most_frequent = get_most_frequent_words(freq1, freq2)
    print(most_frequent) ## should print ["hello", "world"]

    ## Tests Problem 5: Similarity
    test_directory = "tests/student_tests/"
    hello_world, hello_friend = load_file(test_directory + 'hello_world.txt'), load_file(test_directory + 'hello_friends.txt')
    world, friend = prep_data(hello_world), prep_data(hello_friend)
    world_word_freq = get_frequencies(world)
    friend_word_freq = get_frequencies(friend)
    word_similarity = calculate_similarity_score(world_word_freq, friend_word_freq)
    print(word_similarity)        # should print 0.33

    ## Tests Problem 6: Find TF-IDF
    text_file = 'tests/student_tests/hello_world.txt'
    text_files = ['tests/student_tests/hello_world.txt', 'tests/student_tests/hello_friends.txt']
    tf = get_tf(text_file)
    idf = get_idf(text_files)
    tf_idf = get_tfidf(text_file, text_files)
    print(tf) ## should print {'hello': 0.5, 'world': 0.25, 'there': 0.25}
    print(idf) ## should print {'there': 0.3010299956639812, 'world': 0.3010299956639812, 'hello': 0.0, 'friends': 0.3010299956639812}
    print(tf_idf) ## should print [('hello', 0.0), ('there', 0.0752574989159953), ('world', 0.0752574989159953)]
# Problem Set 4B
# Name: Miguel Flores-Acton
# Collaborators:
# Time Spent: 0:40
# Late Days Used: 0

import random

class Message(object):
    def __init__(self, input_text):
        '''
        Initializes a Message object

        input_text (string): the message's text

        a Message object has one attribute:
            the message text
        '''
        self.message_text  = input_text

    def __repr__(self):
        '''
        Returns a human readable representation of the object

        Returns: (string) A representation of the object
        '''
        #DO NOT CHANGE
        return f'''Message('{self.get_text()}')'''

    def get_text(self):
        '''
        Used to access the message text outside of the class

        Returns: (string) the message text
        '''
        return self.message_text

    def shift_char(self, char, shift):
        '''
        Used to shift a character as described in the pset handout

        char (string): the single character to shift.
                    ASCII value in the range: 32<=ord(char)<=126
        shift (int): the amount to shift char ASCII value up by

        Returns: (string) the shifted character with ASCII value in the range [32, 126]
        '''
        char_value = ord(char)
        new_char_value = char_value + shift

        #bump up lower bound
        while new_char_value < 32:#min
            new_char_value += 95 #width of range

        #bump down upper bound
        while new_char_value > 126:#max
            new_char_value -= 95 #width of range

        return chr(new_char_value) #get back char of that ascii



    def apply_pad(self, pad):
        '''
        Used to calculate the ciphertext produced by applying a one time pad to the message text.
        For each character in the text at index i shift that character by
            the amount specified by pad[i]

        pad (list of ints): a list of integers used to encrypt the message text
                        len(pad) == len(the message text)

        Returns: (string) The ciphertext produced using the one time pad
        '''
        result = "" #accumulator string
        for i in range(len(pad)):
            result += self.shift_char(self.message_text[i], pad[i])

        return result

class PlaintextMessage(Message):
    def __init__(self, input_text, pad=None):
        '''
        Initializes a PlaintextMessage object.

        input_text (string): the message's text
        pad (list of ints OR None): the pad to encrypt the input_text or None if left empty
            if pad!= None then len(pad) == len(self.input_text)
            save as a COPY

        A PlaintextMessage object inherits from Message. It has three attributes:
            the message text
            the pad (list of integers, determined by pad
                or generated randomly using self.generate_pad() if pad == None)
            the ciphertext (string, input_text encrypted using the pad)
        '''
        super().__init__(input_text)
        if pad is None:
            self.pad = self.generate_pad()
        else:
            self.pad = [num for num in pad]
        self.ciphertext = self.apply_pad(self.pad)

    def __repr__(self):
        '''
        Returns a human readable representation of the object
        DO NOT CHANGE

        Returns: (string) A representation of the object
        '''
        return f'''PlaintextMessage('{self.get_text()}', {self.get_pad()})'''

    def generate_pad(self):
        '''
        Generates a one time pad which can be used to encrypt the message text.

        The pad should be generated as follows:
            Make a new list
            For each character in the message, choose a random number n in the range [0, 110)
            Add n to this new list    

        Returns: (list of integers) the new one time pad
                    len(pad) == len(message text)
        '''
        result = [] #list to be returned

        for _ in self.get_text():
            result.append(random.randint(0, 109))#add random number

        return result

    def get_pad(self):
        '''
        Used to safely access your one time pad outside of the class

        Returns: (list of integers) a COPY of your pad
        '''
        return [num for num in self.pad]# new array with same values

    def get_ciphertext(self):
        '''
        Used to access the ciphertext produced by applying the pad to the message text

        Returns: (string) the ciphertext
        '''
        return self.ciphertext

    def change_pad(self, new_pad):
        '''
        Changes the pad used to encrypt the message text and updates any other
        attributes that are determined by the pad.

        new_pad (list of ints): the new one time pad that should be associated with this message.
            len(new_pad) == len(the message text)
            save as a COPY

        Returns: nothing
        '''
        self.pad = [num for num in new_pad]# new array with same values
        self.ciphertext = self.apply_pad(self.pad)#update ciphertext

class EncryptedMessage(Message):
    def __init__(self, input_text):
        '''
        Initializes an EncryptedMessage object

        input_text (string): the ciphertext of the message

        an EncryptedMessage object inherits from Message. It has one attribute:
            the message text (ciphertext)
        '''
        super().__init__(input_text)

    def __repr__(self):
        '''
        Returns a human readable representation of the object
        DO NOT CHANGE

        Returns: (string) A representation of the object
        '''
        return f'''EncryptedMessage('{self.get_text()}')'''

    def decrypt_message(self, pad):
        '''
        Decrypts the message text that was encrypted with pad as described in the writeup

        pad (list of ints): the new one time pad used to encrypt the message.
            len(pad) == len(the message text)

        Returns: a PlaintextMessage intialized using the decrypted message and the pad
        '''
        negative_pad = [-num for num in pad] # multiplies the pad by -1
        plain_text = self.apply_pad(negative_pad) #unencrypt
        return PlaintextMessage(plain_text, pad)

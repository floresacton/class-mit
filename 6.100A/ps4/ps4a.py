# Problem Set 4a
# Name: Miguel Flores-Acton
# Collaborators:
# Time spent: 00:20

from tree import Node  # Imports the Node object used to construct trees

# Part A0: Data representation
# Fill out the following variables correctly.
# If correct, the tests named data_representation should pass.
tree_1 = Node(9, Node(6), Node(3, Node(7), Node(8)))
tree_2 = Node(7, Node(13, Node(15, Node(4), Node(6)), Node(5)), Node(2, Node(9), Node(11)))
tree_3 = Node(4, Node(9, Node(14), Node(25)), Node(17, Node(1), Node(8, Node(11), Node(6))))

def find_tree_height(tree):
    '''
    Find the height of the given tree
    Input:
        tree: An element of type Node constructing a tree
    Output:
        The integer depth of the tree
    '''
    #base case if leaf
    if tree.get_left_child() is None and tree.get_right_child() is None:
        return 0
    
    height = 0#variable to store height
    #recurse if left child present
    if tree.get_left_child():
        height = find_tree_height(tree.get_left_child()) + 1 #increase height
    if tree.get_right_child():
        #get maximum height of both children
        height = max(height, find_tree_height(tree.get_right_child()) + 1)
    
    #returns max height of children
    return height

def is_heap(tree, compare_func):
    '''
    Determines if the tree is a max or min heap depending on compare_func
    Inputs:
        tree: An element of type Node constructing a tree compare_func: 
              a function that compares the child node value to the parent node value
            
            i.e. compare_func(child_value,parent_value) for a max heap would return False 
                 if child_value > parent_value and True otherwise
                 
                 compare_func(child_value,parent_value) for a min meap would return False 
                 if child_value < parent_value and True otherwise
    Output:
        True if the entire tree satisfies the compare_func function; False otherwise
    '''
    #base case if leaf
    if tree.get_left_child() is None and tree.get_right_child() is None:
        return True
    
    #check left root
    if tree.get_left_child():
        if not compare_func(tree.get_left_child().get_value(), tree.get_value()) or not is_heap(tree.get_left_child(), compare_func):
            return False
    if tree.get_right_child():
        if not compare_func(tree.get_right_child().get_value(), tree.get_value()) or not is_heap(tree.get_right_child(), compare_func):
            return False
    
    #return true if everything passed
    return True

if __name__ == '__main__':
    # # You can use this part for your own testing and debugging purposes.
    # # IMPORTANT: Do not erase the pass statement below if you do not add your own code
    pass
== R1

=== Set Notation

$Omega$ is the universe

six sided die $S = {1,2,3,4,5,6}$\
fair coin $S = {H,T}$

$B^C$ complement of $B$

$A union B$ All that which ${X | X in A | X in B}$

disjoint sets $A and B =$ null

if disjoing $P(A) + P(B) = P(A union B)$

$B and B^C =$ null

$B union B^C = Omega$

=== Probability Laws

$Omega$ universe\
event A has n elements\
$Omega$ has N elements

Discrete uniform law - means each one is equally likely\
//#block(left, [
$P(A) = n/N$//])

Continuous Uniform Law,
$P(A) = P(x,y)={x,y|x+y <= 1/2}=1/8$

=== Axioms of Probabiliy
+ Non-negativity
  - $P(A) >= 0$
+ Normalization
  - $P(Omega) = 1$
+ Additivity
  - if $A union B =$ null, then $P(A union B) = P(A) + P(B)$ (disjoint set)

=== Practice Problems

*1 Probabilility difference of 2 events*\
$P[(A inter B^C) union (A^C inter B) = P(A) + P(B) - 2P(A inter B)]$\
This is like saying A only plus B only is what

Observation $A = (A inter B)$

*2 Romeo and Juliet time*

- Each one will arrive between 0 and 1 hour $[0,1]$
- All delays are equally likely
- The first to arrive will wait 15 minutes then leave

Between $[0, 1]$ means that its continuous and because all equaly, also uniform problem

M : Event that Romeo and Juliet meet, what is $P(M)$

Graph the problem where x is romeo and y is juliet, from 0 to 1
where $Omega$ is the 1x1 square

15min = 1/4 of an hour

M is like a diagonal banner line, so $P(M) = 1 - 2 (3/4 dot 3/4 dot 1/2)$\
$P(M) = 1 - 9/16 = 7/16$

*3 Bonferroni's Inequality*

Prove $P(A_1 inter A_2) >= P(A_1) + P(A_2) -1$

*4 Proving through induction*


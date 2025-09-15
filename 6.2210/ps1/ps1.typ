#set page(width: 8.5in, height: 11in)

= 6.2210 PSet1 #h(1fr) Miguel Flores-Acton

== Problem 1

=== A)

#block([$
    A_r=pi R_3^2 - pi R_2^2
  $
  $
    A_r=pi (R_3^2 - R_2^2)
  $

  $
    (partial rho) / (partial z) = A_r rho_V
  $

  $
    (partial rho) / (partial z) = pi (R_3^2 - R_2^2) rho_V
  $

  $
    L=2 pi R_1
  $

  $
    (partial rho) / (partial z) = L rho_S
  $

  $
    (partial rho) / (partial z) = 2 pi R_1 rho_S
  $

  Because the net charge has to be zero we can set the derivatives $(partial rho) / (partial z)$ equal to the negative of the other

  $
    2 pi R_1 rho_S = - pi (R_3^2 - R_2^2) rho_V
  $

  $
    rho_S = -((R_3^2 - R_2^2) rho_V) / (2 R_1)
  $])

=== B)

Since $nabla times E = 0$, and because of radial symmetry, we can say that the field
must also be purely radial, therefore the only non-zero component of $E$ is in the  $hat(r)$ direction.

=== C)

#block([
  $ integral harpoon(E) dot d harpoon(a) = q_e / epsilon_0 $
  Choosing a cylinder that encloses all the charges:\
  Since the cylinder is uniform to infinity on the z axis,
  we know that the none of $E$ points in the $hat(z)$ direction.

  Given that L is the length of the cylinder and r is the radius:\
  $
    2 pi r L Epsilon_r epsilon_0 = 2 pi R_1 -((R_3^2 - R_2^2) rho_V) / (2 R_1) L + pi (R_3^2 - R_2^2) L rho_V
  $

  $ 2 r E $

  Defining a cylinder around
])

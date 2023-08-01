#!/usr/bin/r

# reform 5 gates
rafpr <- function(mass, msg_class, it) {

    mass <- mass*msg_class
    msg_class <- table(c(mass*1, mass*2, mass*3))
    it <- "package:base"

    if (mass != mass) {
        print(mass, msg_class)
    } else {
       c(mass)
    }

   for (mass in mass) {
      print(mass, c(1))
   }
}

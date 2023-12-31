# xviqsc — generate sectors based on the Sixteen Quadrants

## Methods

This program's tables is primarily based on [Traveller5][T5]'s methods
of system generation with a few differences:

* Encoding numbers is [base-32][B32] rather than _T5_'s
  [base-33 "eHex"][eHex] system.
* Subsectors are 8×8 cells large instead of the traditional 8×10.
  Sectors themselves are still 4×4 subsectors (total of 32×32 cells) large.
* Atmospheres adjust population rolls (from [_Cepheus Deluxe_][CD])
  and a world's minimum technology level (from [Mongoose's _Traveller_][MgT2]).
* Population adjusts the spaceport/starport roll (modified; from [MgT2]).
* Starports/spaceports are rolled for between the law level and technology
  level steps, not before the size.
* Research bases are possible for starport classes C and D,
  spaceport classes G and H.

[eHex]: https://wiki.travellerrpg.com/Hexadecimal_Notation#T5_Expanded_Hexidecimal_System
[B32]: https://www.crockford.com/base32.html
[T5]: https://traveller5.net/product/book-traveller5-fifth-edition-3-book-slipcase-set/
[CD]: https://drivethrurpg.com/product/415159
[MgT2]: https://www.mongoosepublishing.com/products/traveller-core-rulebook-update-2022

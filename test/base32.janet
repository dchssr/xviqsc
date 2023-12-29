(import ../secgen/base32)

# To make sure I didn't accidentally screw up the alphabet.
(assert (= 32 (length base32/alphabet)))

# Encoding tests
(assert (= "77A8DC" (string/join (map base32/encode [7 7 10 8 13 12]))))
(assert (= "E" (base32/encode 14)))
(assert (= 16 (base32/decode "G")))

# Do we get an exception?
(assert (= :invalid (try (base32/encode 42) ([err] :invalid))))

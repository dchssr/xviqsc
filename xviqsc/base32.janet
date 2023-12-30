# Base 32 is an encoding system by Douglas Crockford
# (developer of the JSON format) to more easily encode
# binary information of up to 5 bits per symbol.
#
# Using this method and shrinking subsectors to 8×8
# from 8×10, I can record a star system's coördinates
# with only two alphanumbers instead of four numbers.
#
# https://www.crockford.com/base32.html

(def alphabet
  "Valid Base 32 values. Lowercase letters are also valid
but will be capitalized in this program."
  "0123456789ABCDEFGHJKMNPQRSTVWXYZ")

(defn encode [value]
  "Encode an integer into a Base 32 digit string."
  (if (int? value)
    (cond
      # Direct values
      (<= 0 value 31) (string/from-bytes (get alphabet value))
      # Numbers and uppercase letters
      (or (<= 48 value  57) (<= 65 value  90)) (string/from-bytes value)
      # Convert lowercase letters to upppercase
      (<= 97 value 122) (encode (string/ascii-upper value))
      (errorf "%d is out of range for a valid Base 32 value" value))
    (errorf "%v cannot be translated to a Base 32 value" value)))

(defn decode [value]
  "Decode an alphanumber digit into its Base 32 value."
  (string/find (string/ascii-upper value) alphabet))

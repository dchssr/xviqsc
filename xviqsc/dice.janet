(var rng (math/rng (os/cryptorand 4)))
(def int (partial math/rng-int rng))
(def roll (comp inc int))

(defn d [sides &opt amount]
  "Roll a SIDES-sided die AMOUNT times and add them together."
  (default amount 1)
  (sum (seq [:repeat amount] (roll sides))))

(def d6 (partial d 6))

(defn flux [] (- (d6) (d6)))

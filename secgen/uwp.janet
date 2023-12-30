(import ./base32)
(import ./dice)

(defn- clamp [val low high]
  (max low (min val high)))

(defn size []
  (let [size (- (dice/d6 2) 2)]
    (if (= size 10)
      (+ (dice/d6) 9)
      size)))

(defn atmosphere [&opt siz]
  (default siz (size))
  (if (zero? siz) 0
      (clamp (+ (dice/flux) siz) 0 15)))

(defn- hydadj [atm]
  (if (<= 3 atm 9) 0 -4))

(defn hydrographics [&opt siz atm]
  (default siz (size))
  (default atm (atmosphere siz))
  (if (< siz 2) 0
      (clamp (+ (dice/flux) atm (hydadj atm)) 0 10)))

(defn- popadj [atm hyd]
  (cond
    (and (zero? hyd) (<= 0 atm 3))  -1
    (any? (map |(= $ atm) [5 7 8])) +1
    (= atmosphere 6)                +3
                                    -2))

(defn population [&opt atm hyd]
  (default atm (atmosphere))
  (default hyd (hydrographics atm))
  (let [pop (- (dice/d6 2) 2)]
    (if (= pop 10)
      (+ (dice/d6 2) 3)
      (clamp (+ pop (popadj atm hyd)) 0 10))))
      
(defn government [&opt pop]
  (default pop (population))
  (clamp (+ (dice/flux) pop) 0 15))

(defn law-level [&opt gov]
  (default gov (government))
  (clamp (+ (dice/flux) gov) 0 18))

(defn- portadj [pop]
  (get 
   { 1 -2  2 -2  3 -1  4 -1  8 +1  9 +1
    10 +2 11 +2 12 +2 13 +2 14 +2 15 +2} pop 0))

(defn starport [&opt pop]
  (default pop (population))
  (let [roll (+ (dice/d6 2) (portadj pop))]
    (cond
      # (zero? population) "X"
      (<=   roll  2)     "X"
      (<= 3 roll  4)     "E"
      (<= 5 roll  6)     "D"
      (<= 7 roll  8)     "C"
      (<= 9 roll 10)     "B"
      (>=   roll 11)     "A")))

(defn- tladj [stp siz atm hyd pop gov]
  (+ (get {"A" +6 "B" +4 "C" +2 "X" -4 "F" +1}  stp 0)
     (get {0 +2 1 +2 2 +1 3 +1 4 +1}            siz 0)
     (if (or (<= atm 3) (>= atm 10)) +1 0)    # atm
     (get {0 +1 9 +1 10 +2}                     hyd 0)
     (get {1 +1 2 +1 3 +1 4 +1 5 +1 8 +1 9 +2
           10 +4 11 +4 12 +4 13 +4 14 +4 15 +4} pop 0)
     (get {0 +1 1 +1 5 +2 13 -2 14 -2}          gov 0)))

(def- mintl
  {0 8 1 8 2 5 3 5 4 3 5 0 6 0 7 3 8 0 9 3 10 8 11 9 12 10 13 5 14 5 15 5})

(defn technology-level [port siz atm hyd pop gov]
  (max (+ (tladj port siz atm hyd pop gov) (dice/d6))
       (mintl atm)))

(defn uwp [&opt fiat]
  (default fiat {})
  (let [siz  (in fiat :siz  (size))
        atm  (in fiat :atm  (atmosphere siz))
        hyd  (in fiat :hyd  (hydrographics siz atm))
        pop  (in fiat :pop  (population atm hyd))
        gov  (in fiat :gov  (government pop))
        law  (in fiat :law  (law-level gov))
        port (in fiat :port (starport pop))
        tl   (in fiat :tl   (technology-level port siz atm hyd pop gov))]
    {:siz siz :atm atm :hyd hyd
     :pop pop :gov gov :law law
     :port port        :tl  tl}))

(defn to-string [uwp]
  (string/format "%s%s%s%s%s%s%s-%s"
                 (in uwp :port)
                 ;(map (comp base32/encode (partial in uwp))
                       [:siz :atm :hyd :pop :gov :law :tl])))

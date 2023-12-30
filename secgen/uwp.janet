(import ./base32)
(use ./dice)

(defn- clamp [val low high]
  (max low (min val high)))

(defn size []
  (let [size (- (d6 2) 2)]
    (if (= size 10)
      (+ (d6) 9)
      size)))

(defn atmosphere [&opt size]
  (default size (size))
  (if (zero? size) 0
      (clamp (+ (flux) size) 0 15)))

(defn hydrographics [&opt size atmosphere]
  (default size (size))
  (default atmosphere (atmosphere size))
  (if (< size 2) 0
      (clamp (+ (flux)
		atmosphere
		(if (not (< 2 atmosphere 10)) 0 -4))
	     0 10)))

(defn- population-adjustment [atmosphere hydrographics]
  (default atmosphere (atmosphere))
  (default hydrographics (hydrographics))
  (cond
    (and (zero? hydrographics)
	 (any? (map |(= $ atmosphere) [0 1 2 3]))) -1
    (any? (map |(= $ atmosphere) [5 7 8]))         +1
    (= atmosphere 6)                               +3
                                                   -2))

(defn population [&opt atmosphere hydrographics]
  (default atmosphere (atmosphere))
  (default hydrographics (hydrographics))
  (let [population (- (d6 2) 2)]
    (if (= population 10)
      (+ (d6 2) 3)
      (clamp (+ population
		(population-adjustment atmosphere hydrographics))
	     0 15))))
      
(defn government [&opt population]
  (default population (population))
  (clamp (+ (flux) population) 0 15))

(defn law-level [&opt government]
  (default government (government))
  (clamp (+ (flux) government) 0 18))

(defn starport [&opt population]
  (let [adjustment (cond
		     (<=   population 2) -2
		     (<= 3 population 4) -1
		     (<= 8 population 9) +1
		     (>= population  10) +2
		                          0)
	roll (+ (d6 2) adjustment)]
    (cond
      (zero? population) "X"
      (<=   roll  2)     "X"
      (<= 3 roll  4)     "E"
      (<= 5 roll  6)     "D"
      (<= 7 roll  8)     "C"
      (<= 9 roll 10)     "B"
      (>=   roll 11)     "A")))

(defn- technology-level-adjustment [stp siz atm hyd pop gov]
  (+ (case stp "A" +6 "B" +4 "C" +2 "X" -4 "F" +1 0)
     (case siz 0 +2 1 +2 2 +1 3 +1 4 +1 0)
     (if (or (<= atm 3) (>= atm 10)) +1 0)
     (case hyd 0 +1 9 +1 10 +2 0)
     (cond (<= 1 pop 5) +1 (= pop 8) +1 (= pop 9) +2 (>= pop 10) +4 0)
     (case gov 0 +1 1 +1 5 +2 13 -2 14 -2 0)))

(def- minimum-technology-level
  {0 8 1 8 2 5 3 5 4 3 5 0 6 0 7 3 8 0 9 3 10 8 11 9 12 10 13 5 14 5 15 5})

(defn technology-level [starport size atmosphere hydrographics population government]
  (let [tl (+ (d6) (technology-level-adjustment starport size atmosphere
				       hydrographics population government))]
    (max tl (get minimum-technology-level atmosphere))))


(defn uwp [&opt fiat]
  (default fiat {})
  (let [size          (in fiat :size          (size))
	atmosphere    (in fiat :atmosphere    (atmosphere size))
	hydrographics (in fiat :hydrographics (hydrographics size atmosphere))
	population    (in fiat :population    (population atmosphere hydrographics))
	government    (in fiat :government    (government population))
	law-level     (in fiat :law-level     (law-level government))
	starport      (in fiat :starport      (starport population))
	technology-level (in fiat :technology-level
			    (technology-level starport size atmosphere
					      hydrographics population government))]
    {:size          size
     :atmosphere    atmosphere
     :hydrographics hydrographics
     :population    population
     :government    government
     :law-level     law-level
     :starport      starport
     :technology-level technology-level}))

(defn to-string [uwp]
  (string/format "%s%s%s%s%s%s%s-%s"
		 (in uwp :starport)
		 ;(map base32/encode
		       [(in uwp :size)
			(in uwp :atmosphere)
			(in uwp :hydrographics)
			(in uwp :population)
			(in uwp :government)
			(in uwp :law-level)
			(in uwp :technology-level)])))

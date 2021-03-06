;; Copyright 2018 the authors.
;; This file is part of Hy, which is free software licensed under the Expat
;; license. See the LICENSE.

(require [hy.contrib.multi [defmulti defmethod default-method defn]])
(import pytest)

(defn test-different-signatures []
  "NATIVE: Test multimethods with different signatures"
  (defmulti fun [&rest args]
    (len args))

  (defmethod fun 0 []
    "Hello!")

  (defmethod fun 1 [a]
    a)

  (defmethod fun 2 [a b]
    "a b")

  (defmethod fun 3 [a b c]
    "a b c")

  (assert (= (fun) "Hello!"))
  (assert (= (fun "a") "a"))
  (assert (= (fun "a" "b") "a b"))
  (assert (= (fun "a" "b" "c") "a b c")))

(defn test-different-signatures-defn []
  "NATIVE: Test defn with different signatures"
  (defn f1
    ([] "")
    ([a] "a")
    ([a b] "a b"))

  (assert (= (f1) ""))
  (assert (= (f1 "a") "a"))
  (assert (= (f1 "a" "b") "a b"))
  (with [(pytest.raises TypeError)]
    (f1 "a" "b" "c")))

(defn test-basic-dispatch []
  "NATIVE: Test basic dispatch"
  (defmulti area [shape]
    (:type shape))
  
  (defmethod area "square" [square]
    (* (:width square)
       (:height square)))
  
  (defmethod area "circle" [circle]
    (* (** (:radius circle) 2) 
       3.14))

  (default-method area [shape]
    0)

  (assert (< 0.784 (area {:type "circle" :radius 0.5}) 0.786))
  (assert (= (area {:type "square" :width 2 :height 2})) 4)
  (assert (= (area {:type "non-euclid rhomboid"}) 0)))

(defn test-docs []
  "NATIVE: Test if docs are properly handled"
  (defmulti fun [a b]
    "docs"
    a)

  (defmethod fun "foo" [a b]
    "foo was called")

  (defmethod fun "bar" [a b]
    "bar was called")
  
  (assert (= fun.--doc-- "docs")))

(defn test-kwargs-handling []
  "NATIVE: Test handling of kwargs with multimethods"
  (defmulti fun [&kwargs kwargs]
    (get kwargs "type"))

  (defmethod fun "foo" [&kwargs kwargs]
    "foo was called")

  (defmethod fun "bar" [&kwargs kwargs]
    "bar was called")

  (assert (= (fun :type "foo" :extra "extra") "foo was called")))

(defn test-basic-multi []
  "NATIVE: Test a basic arity overloaded defn"
  (defn f2
    ([] "Hello!")
    ([a] a)
    ([a b] "a b")
    ([a b c] "a b c"))

  (assert (= (f2) "Hello!"))
  (assert (= (f2 "a") "a"))
  (assert (= (f2 "a" "b") "a b"))
  (assert (= (f2 "a" "b" "c") "a b c")))


(defn test-kw-args []
  "NATIVE: Test if kwargs are handled correctly for arity overloading"
  (defn f3
    ([a] a)
    ([&optional [a "nop"] [b "p"]] (+ a b)))
   
  (assert (= (f3 1) 1))
  (assert (= (f3 :a "t") "t"))
  (assert (= (f3 "hello " :b "world") "hello world"))
  (assert (= (f3 :a "hello " :b "world") "hello world")))


(defn test-docs []
  "NATIVE: Test if docs are properly handled for arity overloading"
  (defn f4
    "docs"
    ([a] (print a))
    ([a b] (print b)))
  
  (assert (= f4.--doc-- "docs")))

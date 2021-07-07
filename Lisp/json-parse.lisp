;;;; -*- Mode: Lisp -*-

;;;; Ponti Federico  817395


;;;; json-parse

(defun json-parse (JSONString)
  (let ((JSONList (skip-whitespace (coerce JSONString 'list))))
    (or
     (is-object JSONList)
     (is-array JSONList)
     (error "Stringa non valida"))))


;;;; is-object

(defun is-object (JSONList)
  (if (eq (first JSONList) #\{)
      (if (eq (second JSONList) #\})
          (values 
           (list 'JSON-OBJ)
           (rest JSONList))
        (multiple-value-bind (members restJSONList)
            (is-member NIL JSONList)
          (values 
           (append (list 'JSON-OBJ) members)
           restJSONList))) 
    NIL))


;;;; is-member

(defun is-member (initialPairs JSONList)
  (cond ((and (eq (first JSONList) #\})
              (or (eq (second JSONList) #\,)
                  (eq (second JSONList) #\})))
         (values initialPairs (rest JSONList)))
        ((eq (first JSONList) #\})
         (values initialPairs JSONList))
        ((multiple-value-bind (pairs restJSONList) 
             (is-pair (rest JSONList))
           (if (null initialPairs)
               (is-member (list pairs) restJSONList)          
             (is-member 
              (append initialPairs (list pairs)) 
              restJSONList))))))


;;;; is-pair

(defun is-pair (JSONList)
  (multiple-value-bind (attribute restJSONList) 
      (is-string JSONList)
    (if (eq (first restJSONList) #\:)
        (multiple-value-bind (value otherJSONList) 
            (is-value (rest restJSONList))
          (values 
           (list (coerce attribute 'string) 
                 (if (or (eq (first value) 'JSON-ARRAY)
                         (eq (first value) 'JSON-OBJ))
                     value
                   (coerce value 'string)))
                   ;value))
           otherJSONList))
      (error "Errore nella costruzione del pair"))))    


;;;; is-value

(defun is-value (JSONList)
  ; is-string, is-number, -is-array, -is-object
  (cond ((eq (first JSONList) #\")
         (multiple-value-bind (value restJSONList)
             (is-string JSONList)
           (values value restJSONList)))
        ((digit-char-p (first JSONList))
         (multiple-value-bind (value restJSONList)
             (is-number JSONList)
           (values value restJSONList)))
        ((and (eq (first JSONList) #\-)
              (digit-char-p (SECOND JSONList)))
         (multiple-value-bind (value restJSONList)
             (is-negative-number JSONList)
           (values value restJSONList)))
        ((eq (first JSONList) #\[)
         (multiple-value-bind (value restJSONList)
             (is-array JSONList)
           (values value restJSONList)))
        ((eq (first JSONList) #\{)
         (multiple-value-bind (value restJSONList)
             (is-object JSONList)
           (values value restJSONList)))))


;;;; is-string

(defun is-string (JSONList)
  (if (eq (first JSONList) #\")
      (multiple-value-bind (stringa restJSONList) 
          (get-string NIL (rest JSONList))
        (values stringa restJSONList))
    (error "Errore nella sintassi")))


;;;; get-string

(defun get-string (parolaList stringList)
  (if (eq (first stringList) #\")
      (values parolaList (rest stringList))
   (get-string 
     (append parolaList (list (first stringList)))
     (rest stringList))))


;;;; is-number

(defun is-number (JSONList)
  (multiple-value-bind (numList restJSONList)
      (get-number NIL JSONList)
    (values numList restJSONList)))


;;;; is-negative-number

(defun is-negative-number (JSONList)
  (multiple-value-bind (numList restJSONList)
      (get-number NIL (rest JSONList))
    (values 
     (append (list #\-) numList) 
     restJSONList)))
      

;;;; get-number

(defun get-number (numList stringList)
  (if (digit-char-p (first stringList))
      (get-number 
       (append numList (list (first stringList)))
       (rest stringList))
    (values numList stringList)))


;;;; is-array

(defun is-array (JSONList)
  (cond ((eq (first JSONList) #\[)
         (multiple-value-bind (elementList restJSONList)
             (get-array-elements NIL (rest JSONList))
           (values 
            (append (list 'JSON-ARRAY) elementList) 
            (rest restJSONList))))))


;;;; get-array-elements

(defun get-array-elements (elementsList JSONList)
  (cond ((eq (first JSONList) #\])
         (values elementsList JSONList))
        ((eq (first JSONList) #\,)
         (get-array-elements elementsList (rest JSONList)))
        ((eq (first JSONList) #\})
         (get-array-elements elementsList (rest JSONList)))
        (T (multiple-value-bind (newElementList restJSONList)
               (is-value JSONList)
             (get-array-elements
              (append
               elementsList
               (if (or (eq (first newElementList) 'JSON-OBJ)
                       (eq (first newElementList) 'JSON-ARRAY))
                   (list newElementList)
                 (list (coerce newElementList 'string))))
              restjsonlist)))))


;;;; skip-whitespace

(defun skip-whitespace (JSONList)
  (if (null JSONList)
      ()
    (if (or (eq (first JSONList) #\Tab)
            (eq (first JSONList) #\Return)
            (eq (first JSONList) #\Space)
            (eq (first JSONList) #\NewLine))
        (skip-whitespace (rest JSONList))
      (append 
       (list (first JSONList)) 
       (skip-whitespace (rest JSONList))))))


;;; Json-access

(defun json-access (JSON attribute &rest index)
  (find-attribute JSON attribute index))

(defun find-attribute (JSON attribute index)
  (cond ((null JSON)
         (error "Attributo non trovato"))
        ((or (eq (first JSON) 'JSON-OBJ)
             (eq (first JSON) 'JSON-ARRAY))
         (find-attribute (rest JSON) attribute index))
        ((and (string-equal (first (first JSON)) attribute)
              (null index))
         (second (first JSON)))
        ((string-equal (first (first JSON)) attribute)
         (find-value (second (first JSON)) index))
        (T (find-attribute (rest JSON) attribute index))))

(defun find-value (value index)
  (cond ((or (eq (first value) 'JSON-ARRAY)
             (eq (first value) 'JSON-OBJ))
         (find-value (rest value) index))
        ((eq (first index) 0)
         (if (null (second index))
             (first value)
           (find-value (first value) (rest index))))
        (T (find-value 
            (rest value) 
            (append (list (- (first index) 1))
                    (rest index))))))


;;;; json-read

(defun json-read (filename)
  (with-open-file (in filename
                      :direction :input
                      :if-does-not-exist :error)
    (json-parse (coerce (read-line in) 'string))))
  

;;;; json-dump

(defun json-dump (json filename)
  (if (or (null json)
          (null filename))
      (error "ERROR: json-dumo")
    (with-open-file (out filename
                         :direction :output
                         :if-exists :supersede
                         :if-does-not-exist :create)
      (format out "~A" 
              (coerce (flatten (or (write-object json)
                                   (write-array json))) 'string))))
  filename)

(defun write-object (json)
  (if (eq (car json) 'json-obj)
      (if (null (cdr json)) 
          (list #\{ #\})
        (list #\{ (write-pair (cdr json)) #\}))
    nil))

(defun write-array (json)
  (if (eq (car json) 'json-array)
      (if (null (cdr json)) 
          (list #\[ #\])
        (list #\[ (write-element (cdr json)) #\]))
    nil))

(defun write-pair (json)
  (if (null (cdr json))
      (list (write-value (car (car json)))
            #\:
            (write-value (car (cdr (car json)))))
    (list (write-value (car (car json)))
          #\:
          (write-value (car (cdr (car json))))
          #\,
          (write-pair (cdr json)))))

(defun write-element (json)
  (if (null (cdr json))
      (list (write-value (car json)))
    (list (write-value (car json))
          #\,
          (write-element (cdr json)))))

(defun write-value (json)
  (cond ((null json)
         nil)
        ((numberp json)
         (coerce (write-to-string json) 'list))
        ((stringp json)
         (list #\" (coerce json 'list) #\"))
        ((eq (car json) 'json-obj)
         (write-object json))
        ((eq (car json) 'json-array)
         (write-array json))))

(defun flatten (x)
  (cond ((null x)
         x)
        ((atom x)
         (list x))
        (T (append (flatten (first x))
                   (flatten (rest x))))))

;;;; end of file -- json-parse.lisp --
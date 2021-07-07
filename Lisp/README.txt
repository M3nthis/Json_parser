Ponti Federico 817395


### JSON-PARSE

Converte la stringa passata come parametro in una lista di carattere tramite
il coerce. Vengono anche tolti tutti i caratteri sporchi 
(spazio, newline, ecc...) dalla lista.
Vengono poi messe in or le chiamate a is-object e is-array a cui 
viene passata la lista


### IS-OBJECT

Viene controllato che il primo carattere sia una parentesi graffa aperta.
Dopodichè se si tratta di un oggetto vuoto viene creata una lista con 
il solo termine 'JSON-OBJ.
Nel caso siano presenti altri elementi invece viene chiamata la funzione
is-member a cui viene passato NIL come primo parametro e la lista come
secondo.
I risultati vengono poi ritornati (alla lista dei membri viene viene
aggiunto il termine 'JSON-OBJ all'inizio)


### IS-MEMBER

Nel caso il primo elemento della lista passata sia una parentesi quadra
chiusa viene restituita la lista di pairs passata. Nel caso invece
ci siano altri valori viene chiamata la funzione is-pair al cui 
risultato vengono aggiunti i pair precedenti.
Finchè ci sono altri pair il metodo viene chiamato ricorsivamente


### IS-PAIR

Viene chiamata la funzione is-string per verificare che l'attributo sia
una stringa. Successivamente viene verificata la presenza dei due punti
e infine viene chiamata la funzione is-value sulla restante lista di 
caratteri.
La lista, nel caso non sia un 'JSON-ARRAY o un 'JSON-OBJ, viene poi
converita in stringa tramite coerce


### IS-VALUE

Controlla la lista passata sia un possibile valore, quindi una stringa,
un numero, un array o un oggetto.
Viene controllato il primo carattere e, in base alla condizione superata,
viene chiamata la funzione relativa a quel tipo di valore


### IS-STRING

Viene verificato che il primo carattere sia un double quote e, in caso
positivo, viene chiamata la funzione get-string a cui viene passata il
resto della lista (e il valore NIL come primo parametro)


### GET-STRING

finchè ci sono caratteri alfanumerici la funzione viene chiamata 
ricorsivamente e il carattere viene aggiunto alla lista creata.
Una volta incontrato il double quote finale viene restituita la
lista di caratteri creata


### IS-NUMBER

Chiama get-number a cui passa la lista di caratteri


### IS-NEGATIVE-NUMBER

Come is-number ma controlla (e alla fine aggiunge) la presenza del 
carattere "-" all'inizio della lista


### GET-NUMBER

Finche c'è un carattere numerico (controllato con digit-char-p) questo
viene aggiunto alla lista creata e la funzione richiamata ricorsivamente.
Una volta trovato un altro tipo di carattere viene ritornata la lista
creata e il resto della lista di caratteri


### IS-ARRAY

Controlla che il primo carattere sia la parentesi quadra aperta,
Dopodichè chiama get-array-elements da cui ottiene una lista con tutti
gli elementi dell'array


### GET-ARRAY-ELEMENTS

Se il primo carattere della lista è una parentesi quadra chiusa viene
ritornata la lista di elementi creata.
Altrimenti viene chiamata la funzione is-value che ritorna l'elemento
singolo della lista e questo viene aggiunto alla lista di elementi 
creati. La funzione viene poi richiamata ricorsivamente con il resto
della lista di caratteri


### SKIP-WHITESPACE

Scorre ricorsivamente la lista passata creando una lista - che alla
fine viene ritornata - con solo i caratteri "puliti", senza spazi,
newLine ecc...
una volta che la lista di caratteri è finita viene ritornata quella 
creata


### JSON-ACCESS

Chiama la funzione find-attribute a cui vengono passati tutti i 
parametri. 
Nel caso il primo elemento della lista sia 'JSON-OBJ o 'JSON-ARRAY
viene richiamata ricorsivamente la funzione togliendo il termine.
Se invece il primo elemento è effettivamente l'attributo cercato
viene restituito il secondo elemento (il value).
Nel caso sia presente anche un index viene chiamata la funzione 
find-value che, ricorsivamente, abbassa il valore di index fino a
0 togliendo per ogni chiamata il primo elemento della lista.
Quando l'index è a zero viene passato il primo elemento della lista
rimasta. 
La funzione è chiamata ricorsivamente fino a che la lista degli index
non è vuota


### JSON-READ

Viene letto il testo presente in filename e, convertito in string 
tramite coerce, viene applicato alla funzione json-parse


### JSON-DUMP

Chiama la funzione with-open-file in out passando la conversione
in string della funzione flatten applicata al risultato di
write-object o write-array.
Questi controllano che la lista inizi con 'json-obj o 'json-array,
poi se la lista non è vuota chiamano rispettivamente write-pair e
write-element.
write-pair controlla che sia l'ultimo pair e in caso crea una lista
con attributo e valore separati da ":" (tramite la funzione
write-value). Se invece ci sono altri elementi viene creata
una lista come prima a cui viene aggiunta una virgola e il risultato
della chiamata ricorsiva alla funzione.
write-element crea una lista con gli elementi separati da virgola
(sempre con chiamata ricorsiva) chiamando anch'essa write-value.
write-value controlla se il json passato è un numero, una stringa,
un oggetto o un array chiamando le rispettive funzioni.
Infine flatten controlla se il valore passato è un atomo e restituitsce
una lista con quell'atomo, altrimenti fa un append tra gli elementi 
della lista ac ui viene applicato flatten ricorsivamente

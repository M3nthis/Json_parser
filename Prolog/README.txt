Ponti Federico 817395


### JSON_PARSE/2

Controlla se la JSON String passata è un oggetto o un array:
Nel caso dell'oggetto passa la stringa al predicato is_object e prende
da questo l'oggetto ed eventuali caratteri successivi (che non devono
esserci).
Nel caso di array viene convertita la stringa in una lista di codici
numerici tramite string_codes e viene passata a is_array


### IS_OBJECT/3

Converte la stringa passata in una lista di codici numerici, salta i
caratteri vuoti come spazi ecc... tramite skip_all_wrong_characters,
controlla poi che il primo codice corrisponda ad una parentesi graffa
aperta e passa la restante lista a is_member.
Infine controlla che ci sia una parentesi graffa chiusa alla fine e crea
il predicato json_obj unificando il risultato di is_member


### IS_MEMBER/3

Controlla se nella lista di codici numerici passata ci sono "pair", coppie
di attributi e valori. Una volta trovato un pair controlla la lista restane:
Se non ci sono più pair (e/o una graffa chiusa) si attiva il caso base che 
restituisce la lista di pair creata. In caso ci siano altri pair viene
chiamato lo stesso predicato ricorsivamente che restituisce il nuovo pair


### IS_PAIR/4

Crea la coppia attributo - valore. Controlla che come attributo ci sia
una stringa con i double quotes prima e dopo seguita da due punti e
infine cerca di unificare il valore tramite il predicato is_value


### IS_VALUE/3

Prova a unificare la lista di caratteri numerici con uno dei predicati
riferiti ai valori: is_DQ_string, is_number, is_object,
is_array. Ritorna poi il valore che ha unificato e la rimanente lista
di caratteri


### iS_DQ_STRING/3

Controlla che li lista passata inizi con un double quote, continui con
una stringa - trmaite il predicato is_string -e presenti un altro double
quote successivamente


### iS_STRING/3

Controlla che il primo carattere della lista sia un carattere e controlla
quelli successivi ricorsivamente.
Come caso base controlla che sia presente un double quote com primo
carattere


### IS_CHAR_NUMBER/1

Il Char passato unifica se rappresenta un numero nella tabella ASCII


### IS_MINUS/1

Il Char passato unifica se rappresenta un "-" nella tabella ASCII


### IS_NUMBER/3

Controlla se il primo carattere della lista unifica con un carattere
numerico nella tabella ASCII e poi verifica il predicato
other_numer_chars passando il resto della stringa.
Controlla anche se il primo carattere unifica con il "-" e il secondo
con un carattere numerico, poi prova a unificare il resto della lista
con other_numer_chars


### OTHER_NUMBER_CHARS/2

Caso Base: il carattere non è un valore numerico, viene restituita
    la lista di caratteri creata

Caso ricorsivo: Il carattere è un valore numerico, lo aggiungo alla lista
    e richiamo il predicato ricorsivamente


### IS_ARRAY/3

Controlla che il primo carattere rappresenti una parantesi quadra aperta.
Passa poi il resto della lista al predicato scroll_array. Infine crea
il predeicato json_array con la variabile che unifica con il risultato di 
scroll_array


### SCROLL_ARRAY/3

Caso Base: C'è in cima alla lista un carattere che rappresenta la parentesi
    quadra chiusa. VIene restituita la lista di valori creata

Casi ricorsivi: se il primo carattere è una virgola (non viene aggiornata 
    la lista), se è un predicato json_array viene aggiunto alla lista dei valori,
    stessa cosa se è un predicaro json_obj e infine se è un valore, che viene
    convertito in stringa tramite il predicato string_codes


### IS_DUE_PUNTI/2

Controlla che il carattere rappresenti i ":" e salta tutti i caratteri vuoti.
Restituisce poi il resto della stringa


### SKIP_WHITE_SPACE/2

Viene richiamato ricorsivamente finchè il primo carattere è uno spazio vuoto,
restituisce poi i lresto della stringa quando il primo elemento della lista
è un carattere non vuoto


### SKIP_ALL_WRONG_CHARACTERS/2

Aggiunge alla lista restituita solo i caratteri non vuori. Il predicato viene
richiamato ricorsivamente fino a che la lista iniziale non è vuota


### SKIP_VIRGOLA/2

Toglie i caratteri vuoti prima e dopo il carattere virgola


### IS_WHITE_SPACE

Il predicato unifica se il carattere passato è uno spazio o un newline.
Il controllo viene fatto tramite il predicato char_type


### JSON_ACCESS/3

Passa i valori al predicarto find_pair che controlla se il pair è un array
o una normale associazione attributo-valore. Se i valori non corrispondono
a quelli cercati find_pair viene chiamato ricorsivamente.
Una volta trovato l'attributo corrispondente viene restituito il relativo 
valore.
Nel caso degli array si cerca di unificare anche con il predicato find_position
che ricosivamente abbassa di uno il valore dell'indice ricercato rimuovendo
a ogni chiamata ricorsiva il primo elemento della lista. Una volta che l'index
arriva a 0 viene restituito il primo elemento della lista rimasta


### JSON_READ/2

Viene usato il predicato PROLOG read_file_to_codes a cui viene passato il nomde
del file da leggere e viene restituita la lista di codici.
Viene poi chiamato il predicato json_parse con i codici restituiti dal predicato
precedente


### JSON_DUMP/2

Prova a unificare con i predicati write_object o write_array, dopodichè Converte
il risultato in stringa tramite il predicato string_codes e passa il risultato 
a write_string_to_file che scrive la stringa al file passato a json_dump.
i predicati write_object e write_array fanno un append del carattere
parentesi graffa/quadra aperta con il risultato di write_pair/wriite_values e 
infine fa un append del carattere parentesi graffa/quadra chiusa.
write_values fa un append tra il risultato di write_value e il
carattere virgola. Nel caso ci fossero altri elementi viene richiamato
ricorsivamente il predicato.
write_value chiama write_array/object nel caso si trovino questi elementi, se
no scrive una stringa (aggiungendo i double quotes) o un valore numerico.
write_pair scrive un paira composto ad una stringa (con double quotes) come
atrtibuto e il risultato di write_value per il valore. Se ci sono altri 
pair il predicato viene richiamato ricorsivamente.


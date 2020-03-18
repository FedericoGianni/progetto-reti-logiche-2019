# progetto-reti-logiche-2019
<h1>Prova finale di reti logiche - 2019</h1> 

valutazione  30/30

<h2> Descrizione generale </h2>

Sia dato uno spazio bidimensionale definito in termini di dimensione orizzontale e verticale,
e siano date le posizioni di N punti, detti “centroidi”, appartenenti a tale spazio. Si vuole
implementare un componente HW descritto in VHDL che, una volta fornite le coordinate di
un punto appartenente a tale spazio, sia in grado di valutare a quale/i dei centroidi risulti più
vicino (Manhattan distance).
Lo spazio in questione è un quadrato (256x256) e le coordinate nello spazio dei centroidi e
del punto da valutare sono memorizzati in una memoria (la cui implementazione non è parte
del progetto). La vicinanza al centroide viene espressa tramite una maschera di bit
(maschera di uscita) dove ogni suo bit corrisponde ad un centroide: il bit viene posto a 1 se il
centroide è il più vicino al punto fornito, 0 negli altri casi. Nel caso il punto considerato risulti
equidistante da 2 (o più) centroidi, i bit della maschera d’uscita relativi a tali centroidi
saranno tutti impostati ad 1.
Degli N centroidi K<=N sono quelli su cui calcolare la distanza dal punto dato. I K centroidi
sono indicati da una maschera di ingresso a N bit: il bit a 1 indica che il centroide è valido
(punto dal quale calcolare la distanza) mentre il bit a 0 indica che il centroide non deve
essere esaminato. Si noti che la maschera di uscita è sempre a N bit e che i bit a 1 saranno
non più di K.

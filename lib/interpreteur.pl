%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  
%%                   Fichier interpreteur.pl
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%
%%  Ce fichier contient les d�clarations des portes ainsi que
%%  la lecture des fichiers d�clarants les circuits.
%%
%%



% -----------------------------------------------------------------------------
% d�claration des op�rateurs
% -----------------------------------------------------------------------------

:- op(900,fx,input).
:- op(900,fx,output).
:- op(900,fx,cir).
:- op(800,fx,gate).


% -----------------------------------------------------------------------------
% d�claration des portes
% -----------------------------------------------------------------------------
% arg1: type
% arg2: liste des entr�es (pas de limite pour le nombre d'entr�es
% arg3: liste des sorties (pour l'instant 1 seule sortie)

% --- inverseur ---
porte(not,[IN],~IN).


% --- "et" � 2 entr�es ---
porte(and,[IN1,IN2],IN1*IN2).
% --- gestion du "et" � plusieurs entr�es ---
porte(and,[IN],IN).
porte(and,[IN1,IN2|RESTE],IN1*IN2*SUITE) :-
    porte(and,RESTE,SUITE).


% --- "ou" � 2 entr�es ---
porte(or,[IN1,IN2],IN1+IN2).
% --- gestion du "ou" � plusieurs entr�es ---
porte(or,[IN],IN).
porte(or,[IN1,IN2|RESTE],IN1+IN2+SUITE) :-
    porte(or,RESTE,SUITE).


% --- "ou exclusif" ---
porte(xor,[IN1,IN2],IN1#IN2).


% --- portes compl�ment�es ---
porte(nand,IN,~OUT) :- porte(and,IN,OUT).
porte(nor, IN,~OUT) :- porte(or, IN,OUT).
porte(xnor,IN,~OUT) :- porte(xor,IN,OUT).


% --- portes synonymes ---
porte(comp,IN,OUT)  :- porte(xnor,IN,OUT).
porte(inv, IN,OUT)  :- porte(not, IN,OUT).







% -----------------------------------------------------------------------------
% d�claration des options valables pour une porte
% -----------------------------------------------------------------------------
% arg1: nom de l'option
% arg2: valeur de l'option
% arg3: listes des valeurs des options remises dans l'ordre: name, type, in, out
% arg4: option valide ?

option_porte(name, VAL, [VAL,_,_,_], yes).

option_porte(type, VAL, [_,VAL,_,_], yes).

option_porte(in,   VAL,  [_,_,IN,_], yes)  :- 
     %on classe les entr�es (utilis� pour le repr�sentation graphique)
     list_to_ord_set( VAL, IN).

option_porte(out,  VAL, [_,_,_,OUT], yes) :-
     %on classe les sorties (utilis� pour le repr�sentation graphique)
     list_to_ord_set( VAL, OUT).
     
option_porte(OPT,  _, _, off) :-
   write('*** option non reconnue: '), write(OPT), nl.





% -----------------------------------------------------------------------------
% lecture des options de la porte
% -----------------------------------------------------------------------------

% on enl�ve l'�l�ment "gate"
lecture_porte(gate A, GATE) :-
     lecture_porte1(A,GATE).

% analyse option par option et remise dans l'ordre des options
lecture_porte1([],_).
lecture_porte1([OPTION:VALEUR|RESTE],GATE) :-
     %verifie la validit� de l'option et la m�morise
     option_porte(OPTION,VALEUR,GATE,_),

     %%d�buggage
     %option_porte(OPTION,VALEUR,GATE,OK),
     %( OK = yes -> 
     %   %ok, l'option et correte
     %   write('    '), write(OPTION), write(' is '), write(VALEUR), write(', '), nl ; 
     %   %on essaie de continuer m�me s'il y a une erreur dans le circuit
     %   true),

     %lecture de l'option suivante
     lecture_porte1(RESTE,GATE).





     
% -----------------------------------------------------------------------------
% lecture des portes du circuit et g�n�ration des �quations
% -----------------------------------------------------------------------------
% arg1: circuit
% arg2: liste des composants
% arg3: liste des noeuds
% arg4: circuit simplifi� (liste des portes)

lecture_circuit( [], [], [], []).

lecture_circuit( [PORTE|NEXTPORTES], [NAME|NEXTCOMP], ALLNODES, [GATE|NEXTGATES]) :-

     %recup les infos sur une porte (normalisation de l'�criture)
     lecture_porte(PORTE,GATE),
     GATE=[ NAME, _, IN, OUT],

     %concat�nation des entr�es/sorties
     append( IN, OUT, IO),
     append( IO, NODES, ALLNODES),
     
     %lecture de la porte suivante
     lecture_circuit( NEXTPORTES, NEXTCOMP, NODES, NEXTGATES).
     




% -----------------------------------------------------------------------------
% Compl�te les observations (ajoute des inconnues aux noeuds internes)
% -----------------------------------------------------------------------------
% arg1: Observations du circuit
% arg2: Observations compl�t�es
% arg3: listes de tous les noeuds du circuit

full_obs(HASH_OBS,FULLOBS,NODES) :-
     make_hash(OBS,HASH_OBS),

     %appel de la fonction r�cursive
     make_obs(FULLOBS,NODES,OBS,HASH_OBS).



make_obs( [], [], _, _).
make_obs( [NODE=VAL|FULLOBS], [NODE|NODES], OBS, HASH_OBS) :-
     ( 
       %le noeud � une valeur observ�e ?
       member( NODE, OBS) ->

       %oui, on prend la valeur
       key_to_val( [NODE], HASH_OBS, [VAL]);

       %non, on g�n�re une inconnue
       VAL = _
     ),

     %compl�te le maillon suivant
     make_obs( FULLOBS, NODES, OBS, HASH_OBS).






% -----------------------------------------------------------------------------
% Lit le fichier et r�cup�re les infos
% -----------------------------------------------------------------------------
% arg1: Fichier � charger
% arg2: Circuit remani�
% arg3: liste des entr�es du circuit (servira au placement des portes)
% arg4: liste des sorties du circuit (servira au placement des sorties)
% arg4: Observations
% arg5: Nom des composants associ�s � leur inconnue

interpreteur( FICHIER, SIMPLECIR, INPUT, OUTPUT, FULLOBS, HASH_COMPS) :-

     %chargement du circuit
     compile( FICHIER),

     %r�cup�re le circuit     
     cir CIRCUIT,

     write( 'Lecture du circuit... '), nl,
     lecture_circuit( CIRCUIT, COMPS, ALLNODES, SIMPLECIR),

     nl, write( 'Circuit remodel�: '), write( SIMPLECIR), nl,

     %on  fait correspondre une variable unique � chaque composant
     make_hash( COMPS, HASH_COMPS),

     %on enl�ve les doublons des noeuds
     remove_duplicates( ALLNODES, NODES),

     %r�cup�re les entr�es, sorties
     output OUT,
     input IN,

     %Obs repr�sente les observations
     append( IN, OUT, OBS),

     %r�cup�res les noeuds utilis�s
     full_obs( OBS, FULLOBS, NODES),

     %r�cup�re la liste de toutes les entr�es et sorties
     make_hash( INPUT, IN),
     make_hash( OUTPUT, OUT),

     nl, write( 'Observations: '), write( FULLOBS), nl.
     

% -------------------------------------------------------- fin du fichier interpreteur.pl
     

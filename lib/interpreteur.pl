%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  
%%                   Fichier interpreteur.pl
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%
%%  Ce fichier contient les déclarations des portes ainsi que
%%  la lecture des fichiers déclarants les circuits.
%%
%%



% -----------------------------------------------------------------------------
% déclaration des opérateurs
% -----------------------------------------------------------------------------

:- op(900,fx,input).
:- op(900,fx,output).
:- op(900,fx,cir).
:- op(800,fx,gate).


% -----------------------------------------------------------------------------
% déclaration des portes
% -----------------------------------------------------------------------------
% arg1: type
% arg2: liste des entrées (pas de limite pour le nombre d'entrées
% arg3: liste des sorties (pour l'instant 1 seule sortie)

% --- inverseur ---
porte(not,[IN],~IN).


% --- "et" à 2 entrées ---
porte(and,[IN1,IN2],IN1*IN2).
% --- gestion du "et" à plusieurs entrées ---
porte(and,[IN],IN).
porte(and,[IN1,IN2|RESTE],IN1*IN2*SUITE) :-
    porte(and,RESTE,SUITE).


% --- "ou" à 2 entrées ---
porte(or,[IN1,IN2],IN1+IN2).
% --- gestion du "ou" à plusieurs entrées ---
porte(or,[IN],IN).
porte(or,[IN1,IN2|RESTE],IN1+IN2+SUITE) :-
    porte(or,RESTE,SUITE).


% --- "ou exclusif" ---
porte(xor,[IN1,IN2],IN1#IN2).


% --- portes complémentées ---
porte(nand,IN,~OUT) :- porte(and,IN,OUT).
porte(nor, IN,~OUT) :- porte(or, IN,OUT).
porte(xnor,IN,~OUT) :- porte(xor,IN,OUT).


% --- portes synonymes ---
porte(comp,IN,OUT)  :- porte(xnor,IN,OUT).
porte(inv, IN,OUT)  :- porte(not, IN,OUT).







% -----------------------------------------------------------------------------
% déclaration des options valables pour une porte
% -----------------------------------------------------------------------------
% arg1: nom de l'option
% arg2: valeur de l'option
% arg3: listes des valeurs des options remises dans l'ordre: name, type, in, out
% arg4: option valide ?

option_porte(name, VAL, [VAL,_,_,_], yes).

option_porte(type, VAL, [_,VAL,_,_], yes).

option_porte(in,   VAL,  [_,_,IN,_], yes)  :- 
     %on classe les entrées (utilisé pour le représentation graphique)
     list_to_ord_set( VAL, IN).

option_porte(out,  VAL, [_,_,_,OUT], yes) :-
     %on classe les sorties (utilisé pour le représentation graphique)
     list_to_ord_set( VAL, OUT).
     
option_porte(OPT,  _, _, off) :-
   write('*** option non reconnue: '), write(OPT), nl.





% -----------------------------------------------------------------------------
% lecture des options de la porte
% -----------------------------------------------------------------------------

% on enlève l'élément "gate"
lecture_porte(gate A, GATE) :-
     lecture_porte1(A,GATE).

% analyse option par option et remise dans l'ordre des options
lecture_porte1([],_).
lecture_porte1([OPTION:VALEUR|RESTE],GATE) :-
     %verifie la validité de l'option et la mémorise
     option_porte(OPTION,VALEUR,GATE,_),

     %%débuggage
     %option_porte(OPTION,VALEUR,GATE,OK),
     %( OK = yes -> 
     %   %ok, l'option et correte
     %   write('    '), write(OPTION), write(' is '), write(VALEUR), write(', '), nl ; 
     %   %on essaie de continuer même s'il y a une erreur dans le circuit
     %   true),

     %lecture de l'option suivante
     lecture_porte1(RESTE,GATE).





     
% -----------------------------------------------------------------------------
% lecture des portes du circuit et génération des équations
% -----------------------------------------------------------------------------
% arg1: circuit
% arg2: liste des composants
% arg3: liste des noeuds
% arg4: circuit simplifié (liste des portes)

lecture_circuit( [], [], [], []).

lecture_circuit( [PORTE|NEXTPORTES], [NAME|NEXTCOMP], ALLNODES, [GATE|NEXTGATES]) :-

     %recup les infos sur une porte (normalisation de l'écriture)
     lecture_porte(PORTE,GATE),
     GATE=[ NAME, _, IN, OUT],

     %concaténation des entrées/sorties
     append( IN, OUT, IO),
     append( IO, NODES, ALLNODES),
     
     %lecture de la porte suivante
     lecture_circuit( NEXTPORTES, NEXTCOMP, NODES, NEXTGATES).
     




% -----------------------------------------------------------------------------
% Complète les observations (ajoute des inconnues aux noeuds internes)
% -----------------------------------------------------------------------------
% arg1: Observations du circuit
% arg2: Observations complétées
% arg3: listes de tous les noeuds du circuit

full_obs(HASH_OBS,FULLOBS,NODES) :-
     make_hash(OBS,HASH_OBS),

     %appel de la fonction récursive
     make_obs(FULLOBS,NODES,OBS,HASH_OBS).



make_obs( [], [], _, _).
make_obs( [NODE=VAL|FULLOBS], [NODE|NODES], OBS, HASH_OBS) :-
     ( 
       %le noeud à une valeur observée ?
       member( NODE, OBS) ->

       %oui, on prend la valeur
       key_to_val( [NODE], HASH_OBS, [VAL]);

       %non, on génère une inconnue
       VAL = _
     ),

     %complète le maillon suivant
     make_obs( FULLOBS, NODES, OBS, HASH_OBS).






% -----------------------------------------------------------------------------
% Lit le fichier et récupère les infos
% -----------------------------------------------------------------------------
% arg1: Fichier à charger
% arg2: Circuit remanié
% arg3: liste des entrées du circuit (servira au placement des portes)
% arg4: liste des sorties du circuit (servira au placement des sorties)
% arg4: Observations
% arg5: Nom des composants associés à leur inconnue

interpreteur( FICHIER, SIMPLECIR, INPUT, OUTPUT, FULLOBS, HASH_COMPS) :-

     %chargement du circuit
     compile( FICHIER),

     %récupère le circuit     
     cir CIRCUIT,

     write( 'Lecture du circuit... '), nl,
     lecture_circuit( CIRCUIT, COMPS, ALLNODES, SIMPLECIR),

     nl, write( 'Circuit remodelé: '), write( SIMPLECIR), nl,

     %on  fait correspondre une variable unique à chaque composant
     make_hash( COMPS, HASH_COMPS),

     %on enlève les doublons des noeuds
     remove_duplicates( ALLNODES, NODES),

     %récupère les entrées, sorties
     output OUT,
     input IN,

     %Obs représente les observations
     append( IN, OUT, OBS),

     %récupères les noeuds utilisés
     full_obs( OBS, FULLOBS, NODES),

     %récupère la liste de toutes les entrées et sorties
     make_hash( INPUT, IN),
     make_hash( OUTPUT, OUT),

     nl, write( 'Observations: '), write( FULLOBS), nl.
     

% -------------------------------------------------------- fin du fichier interpreteur.pl
     

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  
%%                   Fichier complement.pl
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%
%%  Contient les fonctions complémentaires:
%%    - gestion de liste cle=val
%%    - inversion d'un liste
%%
%%



% -----------------------------------------------------------------------------
% fait correspondre une variable unique à chaque noeud/comps
% -----------------------------------------------------------------------------
% arg1: liste des clés (noeuds/comps)
% arg2: liste des clés (noeuds/comps) associés à leur valeur

make_hash( [], []).

make_hash( [KEY|NEXTKEYS], [KEY=_|NEXTHASH]) :-
      make_hash( NEXTKEYS, NEXTHASH).



% -----------------------------------------------------------------------------
% récupère la variable associée à une liste de noeud/comps
% association clé<->valeur, comme dans un hashage
% -----------------------------------------------------------------------------
% arg1: liste des clés dont on recherche la valeur associée
% arg2: liste des clés associées à leur valeur (cle->val)
% arg3: liste des valeurs respectives

key_to_val( KEYS, HASH, VALS) :-
      key_to_val( KEYS, HASH, HASH, VALS).

key_to_val([],_,_,[]).
key_to_val( [KEY|NEXTKEYS], [KEY=VAL|_], HASH, [VAL|NEXTVAR]) :-
      key_to_val( NEXTKEYS, HASH, HASH, NEXTVAR),!.
      
key_to_val( KEYS, [_|NEXTHASH], HASH, VAL) :-
      key_to_val( KEYS,NEXTHASH, HASH, VAL).




% -----------------------------------------------------------------------------
% inverse une liste
% -----------------------------------------------------------------------------
% arg1: liste
% arg2: inverse de la liste

reverse(A,B) :-
    reverse(A,[],B).

reverse([E|L],I,R) :-
    reverse(L,[E|I],R).
reverse([],I,I).



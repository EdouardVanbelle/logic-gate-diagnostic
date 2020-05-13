%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  
%%                   Fichier complement.pl
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%
%%  Contient les fonctions compl�mentaires:
%%    - gestion de liste cle=val
%%    - inversion d'un liste
%%
%%



% -----------------------------------------------------------------------------
% fait correspondre une variable unique � chaque noeud/comps
% -----------------------------------------------------------------------------
% arg1: liste des cl�s (noeuds/comps)
% arg2: liste des cl�s (noeuds/comps) associ�s � leur valeur

make_hash( [], []).

make_hash( [KEY|NEXTKEYS], [KEY=_|NEXTHASH]) :-
      make_hash( NEXTKEYS, NEXTHASH).



% -----------------------------------------------------------------------------
% r�cup�re la variable associ�e � une liste de noeud/comps
% association cl�<->valeur, comme dans un hashage
% -----------------------------------------------------------------------------
% arg1: liste des cl�s dont on recherche la valeur associ�e
% arg2: liste des cl�s associ�es � leur valeur (cle->val)
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



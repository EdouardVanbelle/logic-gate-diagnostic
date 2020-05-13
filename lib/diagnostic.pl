%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  
%%                   Fichier diagnostic.pl
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%
%%  Partie principale du projet:
%%    - compl�te les observation
%%    - g�n�re les �quations
%%    - s�lectionne les NOGOODS et NOGOODS minimaux
%%
%%


% -----------------------------------------------------------------------------
% r�cup�re les Candidats
% -----------------------------------------------------------------------------
% arg1: liste du circuit simplifi�
% arg2: liste des candidats minimaux
% arg3: liste des noeuds associ�s avec leur valeur (cl�=val)
% arg4: liste des composants associ�s � leur valeur (cl�=val)


%diagnostic minimal
diagnostic( SIMPLECIR, L_CANDIDATS, HASH_NODES, HASH_COMPS, minimaux) :-
     %r�cup�re la liste des nogoods
     get_all_nogoods( SIMPLECIR, L_NOGOOD, HASH_NODES, HASH_COMPS),

     nl,write('Mode minimal: '), nl,

     %ne prend en compte que les nogoods minimaux
     all_nogoods_minim( L_NOGOOD, L_NOGOOD_MIN),

     nl, write( '   Liste des NOGOODS minimaux: '), write( L_NOGOOD_MIN), nl,     

     %r�cup�re les candidats � partir des nogoods
     candidats( L_NOGOOD_MIN, L_CANDIDATS),

     nl, write( '   Liste des CANDIDATS: '), write( L_CANDIDATS), nl.


%diagnostic complet
diagnostic( SIMPLECIR, L_CANDIDATS, HASH_NODES, HASH_COMPS, all) :-
     %r�cup�re la liste des nogoods
     get_all_nogoods( SIMPLECIR, L_NOGOOD, HASH_NODES, HASH_COMPS),

     nl,write('Mode complet: '),nl,        
     %prend en compte tous les NOGOODS

     nl, write( '   Liste des NOGOODS: '), write( L_NOGOOD), nl,     

     %r�cup�re les candidats � partir des nogoods
     candidats( L_NOGOOD, L_CANDIDATS),

     nl, write( '   Liste des CANDIDATS: '), write( L_CANDIDATS), nl.




%r�cup�re la liste des nogoods
get_all_nogoods( SIMPLECIR, L_NOGOOD, HASH_NODES, HASH_COMPS) :-
     %g�n�ration des equations     
     gen_equations( SIMPLECIR, EQU, HASH_NODES, HASH_COMPS),

     nl, write( 'Equations: '), write( EQU), nl,

     %r�cup�re tous les nogoods
     findall( NOGOOD,    
              (select( HASH_COMPS, NOGOOD),\+EQU), 
              L_NOGOOD).
     
     

% -----------------------------------------------------------------------------
% cr�� le syst�me d'�quations
% -----------------------------------------------------------------------------
% arg1: liste du circuit simplifi�
% arg2: liste des �quations
% arg3: liste des noeuds associ�s avec leur valeur (cl�=val)
% arg4: liste des composants associ�s � leur valeur (cl�=val)

%dernier appel
gen_equations( [GATE], FIRST_EQU, HASH_NODES, HASH_COMPS) :-
     gen_une_equation(GATE, FIRST_EQU, HASH_NODES, HASH_COMPS).

%boucle r�cursive
gen_equations( [GATE|SIMPLECIR], (EQU1,NEXT_EQU), HASH_NODES, HASH_COMPS) :-

     %g�n�re l'�quation
     gen_une_equation( GATE, EQU1, HASH_NODES, HASH_COMPS),
     
     %appel r�cursif
     gen_equations( SIMPLECIR, NEXT_EQU, HASH_NODES, HASH_COMPS).
     
     
gen_une_equation( [KEY_NAME, TYPE, KEY_IN, KEY_OUT], EQU, HASH_NODES, HASH_COMPS) :-

     %remplace les noeuds/portes par leur valeurs/variables
     key_to_val( KEY_IN, HASH_NODES, VAL_IN),
     key_to_val( KEY_OUT, HASH_NODES,[VAL_OUT]),
     key_to_val( [KEY_NAME], HASH_COMPS, [VAL_NAME]),
     
     %r�cup�re l'�quation de la porte
     porte( TYPE, VAL_IN, GATE_EQU),
     
     %g�n�re l'�quation:
     %% d'un point de vue logique:
     %% VAL_NAME => VAL_OUT #= GATE_EQU
     %% est �quivalent �
     %% (not VAL_NAME) or (GATE_EQU xnor VAL_OUT)
     EQU=( clpb:sat(  VAL_NAME=<((GATE_EQU)=:=VAL_OUT)  ) ).




% -----------------------------------------------------------------------------
% selection des diff�rents �l�ments (NOGOODS)
% -----------------------------------------------------------------------------
% arg1: liste des cl�s des composants associ�es � leurs valeurs
% arg2: listes des composants "NOGOOD" (cl�)

select( [], []).
%cas o� il ne faut pas m�moriser la porte
select( [_=0|NEXTHASH_COMPS], NOGOOD) :-
     select( NEXTHASH_COMPS, NOGOOD).
     
%cas o� il faut m�moriser la porte
select( [NOM=1|NEXTHASH_COMPS], [NOM|NEXTNOGOOD]) :-
     select( NEXTHASH_COMPS, NEXTNOGOOD).





% -----------------------------------------------------------------------------
% Recherche des nogoods minimaux (il ne faut pas de sous ensemble)
% -----------------------------------------------------------------------------
% arg1: liste de tous les nogoods
% arg2: liste des nogoods minimaux

%on prend tous les nogoods minimaux
all_nogoods_minim( NOGOODS, LNOGOODS_MIN):- 
     findall( NOGOOD_MIN,
              nogood_minimal( NOGOODS, NOGOOD_MIN),
              LNOGOODS_MIN
            ).


%m�thode utilis�e: on recherche un �l�ment qui n'a pas de sous-ensemble
nogood_minimal( ALLNOGOODS, MINIMAL) :-
     %on cherche un membre des NOGOODS
     member( MINIMAL, ALLNOGOODS),
     
     %qui n'a pas de soous-ensemble minimal
     \+has_subset( MINIMAL, ALLNOGOODS).
     
     
%renvoie vrai si un NOGOOD � un sous-ensemble NOGOOD
has_subset( NOGOOD, ALLNOGOODS) :-
     %on effectue tous un test sur tous les autres NOGOODS de la liste
     member( MEMBRE, ALLNOGOODS),
     
     %sauf sue lui m�me
     MEMBRE \== NOGOOD,
     
     %plus besoin de continuer, on � trouv� un sous-ensemble
     ord_subset( MEMBRE, NOGOOD).



%%% m�thode obsol�te et inachev�e donc inutilis�e.
%%%condition initiale: la liste des NOGOODS MINIMAUX = liste des NOGOODS
%%nogoods_minimaux(_,[],1).
%%nogoods_minimaux(INPUT,[PETIT|NEW_NOGOODS_MIN],PASSAGE) :-
%%     
%%     PASSAGE is OLDPASSAGE+1;
%%     
%%     %supprime tous les surensembles de PETIT
%%     remove_all_supset(SELEC,OLD_NOGOODS_MIN,NEW_NOGOODS_MIN),
%%     %recomence avec
%%     nogoods_minimaux(,OLD_GOODS_MIN,OLDPASSAGE).
%%
%%%enl�ve les sur-ensembles � un nogood
%%remove_all_supset(_,[],[]).     
%%remove_all_supset(PETIT,[NOGOOD|NOGOODS_MIN],NEW_NOGOODS_MIN) :-
%%     (
%%      ord_subset(PETIT,NOGOOD) ->
%%      %on ne prend pas en compte le nogood
%%      NEW_NOGOODS_MIN=OLD_NOGOODS_MIN ;
%%      %on garde le nogood
%%      NEW_NOGOODS_MIN=[NOGOOD|OLD_NOGOODS_MIN]
%%     ),
%%     %passe � l'�l�ment suivant
%%     remove_all_supset(PETIT, NOGOODS_MIN, OLD_NOGOODS_MIN).


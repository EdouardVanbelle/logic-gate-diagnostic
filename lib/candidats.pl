%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  
%%                   Fichier candidats.pl
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%
%%  module de gestion des candidats
%%
%%


%déclaration des fonctions visibles (ici une seule)
:- module(candidats,[candidats/2]).

:- use_module(library(ordsets)).

:- prolog_flag(single_var_warnings,_,off).

candidats(LISTE_NOGOODS,LISTE_CANDIDATS) :-
	candidats_1(LISTE_NOGOODS,[[]],LISTE_CANDIDATS).

candidats_1([],CANDIDATS,CANDIDATS).
candidats_1([NOGOOD|R_NOGOOD],CANDIDATS_INITIAUX,CANDIDATS_FINAUX) :-
	list_to_ord_set(NOGOOD,NOGOOD1),
	add_nogood(NOGOOD1,CANDIDATS_INITIAUX,NEW_CAND),
	candidats_1(R_NOGOOD,NEW_CAND,CANDIDATS_FINAUX).


add_nogood(NOGOOD,OLD_CAND,NEW_CAND) :-
	partitionner(NOGOOD,OLD_CAND,C_m,C_p),
	combiner(NOGOOD,C_m,[],C_m_m),
	retrait_surensembles(C_m_m,C_p,C_m_m_m),
	ord_union(C_p,C_m_m_m,NEW_CAND).


partitionner(NOGOOD,[],[],[]).
partitionner(NOGOOD,[C|RC],C_m,[C|RC_p]) :-
	ord_intersect(NOGOOD,C),
	!,
	partitionner(NOGOOD,RC,C_m,RC_p).
partitionner(NOGOOD,[C|RC],[C|RC_m],C_p) :-
	partitionner(NOGOOD,RC,RC_m,C_p).


combiner(NOGOOD,[],RES,RES).
combiner(NOGOOD,[C|RC],RES_COUR,RES) :-
	combiner_1(NOGOOD,C,RES1),
	ord_union(RES1,RES_COUR,NEW_RES_COUR),
	combiner(NOGOOD,RC,NEW_RES_COUR,RES).

combiner_1([],C,[]).
combiner_1([N|RN],C,[NC|RC]) :-
	ord_add_element(C,N,NC),
	combiner_1(RN,C,RC).

retrait_surensembles([],REF,[]).
retrait_surensembles([C|RC],REF,RC1) :-
	test_si_surensemble(C,REF),
	!,
	retrait_surensembles(RC,REF,RC1).
retrait_surensembles([C|RC],REF,[C|RC1]) :-
	retrait_surensembles(RC,REF,RC1).


test_si_surensemble(C,[]) :-
	fail.
test_si_surensemble(C,[REF|R_REF]) :-
	ord_subset(REF,C),
	!.
test_si_surensemble(C,[REF|R_REF]) :-
	test_si_surensemble(C,R_REF).

:- prolog_flag(single_var_warnings,_,on).

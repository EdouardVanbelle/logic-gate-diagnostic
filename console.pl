%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  
%%                   Fichier start.pl
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%
%%  Charge la totalité des fichiers puis lance la partie
%%  principale.
%%
%%


% --------------------------------------------------------------------------------
% chargement des bibliothèques:
% --------------------------------------------------------------------------------


%gestion des listes
:- use_module(library(lists)).
%gestion de la logique boolean
:- use_module(library(clpb)).
%gestion des candidats
:- use_module('lib/candidats').
%gestion des listes ordonnées (ensembles)
:- use_module(library(ordsets)).

%permet de charger d'autres fichier (donc de redéfinir le circuit sans warning)
:- prolog_flag(redefine_warnings,_,off).

:- prolog_flag(single_var_warnings,_,on).
:- prolog_flag(debugging,_,off).

%chargement des programmes principaux
:- compile(['lib/interpreteur','lib/complement','lib/diagnostic']).


%diagnostique le fichier avec les nogoods minimaux
diag( FICHIER) :-
     %on chage le circuit
     interpreteur( FICHIER, SIMPLE_CIR, _, _, HASH_NODES, HASH_COMPS),

     %recherche des candidats
     diagnostic( SIMPLE_CIR, _, HASH_NODES, HASH_COMPS, minimaux ).


%diagnostique le fichier avec tous les nogoods
diag_all( FICHIER) :-
     %on chage le circuit
     interpreteur( FICHIER, SIMPLE_CIR, _, _, HASH_NODES, HASH_COMPS),

     %recherche des candidats
     diagnostic( SIMPLE_CIR, _, HASH_NODES, HASH_COMPS, all ).





:- nl,nl,write('chargement terminé, pour lancer un diagnostic, utilisez: '),nl,
   write('"diag(nom_de_fichier.cir)." (utilise les nogoods minimaux)'),nl,
   write('"diag_all(nom_de_fichier.cir)." (utilise tous les nogoods)'),nl,
   nl.
   
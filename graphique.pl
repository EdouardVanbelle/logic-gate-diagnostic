%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  
%%                   Fichier start.pl
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%
%%  Charge la totalit� des fichiers puis lance la partie
%%  principale.
%%
%%


% --------------------------------------------------------------------------------
% chargement des biblioth�ques:
% --------------------------------------------------------------------------------


%gestion des listes
:- use_module(library(lists)).
%gestion de la logique boolean
:- use_module(library(clpb)).
%gestion des candidats
:- use_module('lib/candidats').
%gestion des listes ordonn�es (ensembles)
:- use_module(library(ordsets)).

%pour l'interface graphique (tcl/tk)
:- use_module(library(tcltk)).


%permet de charger d'autres fichier (donc de red�finir le circuit sans warning)
:- prolog_flag(redefine_warnings,_,off).

:- prolog_flag(single_var_warnings,_,on).
:- prolog_flag(debugging,_,off).

%chargement des programmes principaux
:- compile(['lib/interpreteur','lib/complement','lib/affichage','lib/diagnostic','lib/interface']).

%lancemant de la fonction principale (cf fichier lib/interface.pl)
:- main.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  
%%                   Fichier graphique.pl
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%
%%
%%     Corps principal du projet (effectue la totalit� des
%%     op�rations)
%%
%%      

% ces fonction sont red�finies � chaque chargement d'un circuit
%:- dynamic simple_cir, hash_nodes, hash_comps.

:- assert(simple_cir(_)).
:- assert(hash_nodes(_)).
:- assert(hash_comps(_)).
:- assert(save_input(_)).
:- assert(save_output(_)).

% -----------------------------------------------------------------------------
% programme principal.
% -----------------------------------------------------------------------------
%diag :-
%     %exemple sur le fichier par d�faut.
%     diag('circuits/default.cir').



%diag( FICHIER) :-
%     %on chage le circuit
%     interpreteur( FICHIER, SIMPLECIR, INPUT, HASH_NODES, HASH_COMPS),
%
%     %demande � l'interpr�teur tcl/tk d'afficher le circuit
%     affichage( SIMPLECIR, INPUT),
%
%     %recherche des candidats
%     diagnostic( SIMPLECIR, _, HASH_NODES, HASH_COMPS ).

main :-
     %chargement de l'interface tcl/tk
     tk_new([top_level_events,name('Diagnostic d\'un circuit bool�en')],Interp),
     assert(tcl_interpreter(Interp)),
     nl,write('Lancement de l\'interface...'),nl,
     %pr�cise au prog tcl que l'on travaille depuis prolog
     tcl_eval(Interp,'set interface "lib/interface"', _),
     tcl_eval(Interp,'source $interface/main.tcl', _),
     wait_event(Interp).




%attente d'une action (boucle)
wait_event(Interp) :-
     tk_next_event(Interp, L),
     call(L),
     wait_event(Interp).



%lance une commande tcl
exec_proc(List) :-
     tcl_interpreter(X),
     tcl_eval(X,List,_).



%chargement du fichier
charge( FICHIER) :-
     interpreteur( FICHIER, SIMPLE_CIR, INPUT, OUTPUT, HASH_NODES, HASH_COMPS),

     %on enregistre les variables
     assert(save_input(INPUT)),
     assert(save_output(OUTPUT)),
     assert(simple_cir(SIMPLE_CIR)),
     assert(hash_nodes(HASH_NODES)),
     assert(hash_comps(HASH_COMPS)).

affiche :-
     %on r�cup�re les variables
     save_input(INPUT),
     save_output(OUTPUT),
     simple_cir(SIMPLE_CIR),
     hash_nodes(HASH_NODES),
      
     %demande � l'interpr�teur tcl/tk d'afficher le circuit
     affichage( SIMPLE_CIR, INPUT, OUTPUT, HASH_NODES).


%affiche les portes d�ffectueuses
%MODE repr�sente s'il ne faut prendre que les nogoods minimaux
diag(MODE) :-

     %on r�cup�re les variables
     simple_cir(SIMPLE_CIR),
     hash_nodes(HASH_NODES),
     hash_comps(HASH_COMPS),

     %recherche des candidats
     diagnostic( SIMPLE_CIR, LCANDIDATS, HASH_NODES, HASH_COMPS, MODE),

     %d�sactivation du bouton calculer
     %exec_proc(['disable_calcul']),

     %on apprend � l'interface tcl, touts les CANDIDATS
     learn( LCANDIDATS),
     
     %apprend � l'interface les portes qui sont correctes
     exec_proc( ['learn_good']),

     %affichage de la premi�re solution
     exec_proc( ['aff_first']),
 
     %activation des boutons de navigation
     exec_proc(['enable_navig']).



%termine la fonction calcA (cf fichier batch.tcl)
finishcalctout :-
     nl,
     write('Lancement le rapport sur tous les calculs'),nl,
     exec_proc( ['calc_tout_end'] ).



clean_dyna :-
     save_input(INPUT),
     save_output(OUTPUT),
     simple_cir(SIMPLE_CIR),
     hash_nodes(HASH_NODES),
     hash_comps(HASH_COMPS),
     
     write('On vide les pr�dicats...'),nl,
     
     %destruction des clauses dynamiques
     retract(save_input(INPUT)),
     retract(save_output(OUTPUT)),
     retract(simple_cir(SIMPLE_CIR)),
     retract(hash_nodes(HASH_NODES)),
     retract(hash_comps(HASH_COMPS)).




%fonction d'apprentissage des candidats pour l'interface graphique
learn( []).
learn( [CANDIDATS|NEXTCANDIDATS]) :-
     exec_proc(['learn_candidats','{',CANDIDATS,'}']),
     learn( NEXTCANDIDATS).



%quitter le programme.     
exit_main :-
     nl,write('Sortie du programme, veuillez patienter...'),nl,
     tcl_interpreter(Interp),      
  
     %demande la fermeture des fen�tres tcl
     tcl_eval(Interp,['destroy .'],_),  

     %plus besoin de l'interpr�teur
     tcl_delete(Interp),                
     %d�truit la fonction tcl_interpreter
     retract(tcl_interpreter(Interp)),  
     %quitte prolog
     halt.                              

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  
%%                   Fichier affichage.pl
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%
%%  Ce fichier permet de commander tcl/tk, il place 
%%  automatiquement les portes logiques
%%
%%


% -----------------------------------------------------------------------------
% affiche le circuit
% -----------------------------------------------------------------------------

affichage( CIR, INPUT, OUTPUT, HASH_NODES) :-

     %affichage des entrées
     exec_proc(['CreateInputs','{',INPUT,'}']), 
     
     append( INPUT, OUTPUT, IO),

     %apprentissage des observations
     learn_obs( HASH_NODES, IO),

     %classe les clés dans l'ordre alphabétique
     list_to_ord_set( INPUT, SORTED_NODES),     

     %récupère le circuit dans l'ordre
     aff_circuit( CIR, SORTED_NODES, LLGATES),

     %retourne la liste
     reverse( LLGATES, INV_LLGATES),

     assign_pos( INV_LLGATES),
     
     length( INV_LLGATES, POSX),
     
     %affichage des sorties
     exec_proc(['CreateOutputs','{',OUTPUT,'}',POSX]).
     

%apprentissage des observations à l'interface
learn_obs( [], _).
learn_obs( [CLE=VAL|NEXTHASH], IO) :-
     ( member(CLE, IO) ->  exec_proc(['learn_obs',CLE,VAL]) ; true ),
     learn_obs( NEXTHASH, IO).

%attribue une position relative à la porte
assign_pos([]).
assign_pos([LGATE|NEXTLLGATES]) :-
     assign_pos1( LGATE, NEXTLLGATES),
     assign_pos( NEXTLLGATES).

assign_pos1( [], _).
assign_pos1( [[NOM,TYPE,IN,OUT]|NEXTLGATES], NEXTLLGATES) :-
     %récupère le niveau
     length( NEXTLLGATES, POSX),
     length(  NEXTLGATES, POSY),

     %exemple de commande tcl
     write('tcl> '), write('CreateGate "'), write(NOM),  write('", '),
                                            write(TYPE), write(', '),
                                            write(IN),   write(', '),
                                            write(OUT),  write(', '),
                                            write(POSX), write(', '), 
                                            write(POSY), nl,

     %lance la commande tcl
     exec_proc(['CreateGate',NOM,TYPE,'{',IN,'}','{',OUT,'}',POSX,POSY]),


     assign_pos1( NEXTLGATES, NEXTLLGATES).





aff_circuit( [], _, []).
aff_circuit( CIR, NODES, [LGATES|NEXTLLGATES]) :-

     %récupère toutes les portes du même niveau
     findall(GATE,
             find_one_gate( CIR, NODES, GATE),
             LGATES
            ),

     %trie les listes sinon on ne peut faire "ord_subtract" !!
     list_to_ord_set(LGATES,SORTED_LGATES),
     list_to_ord_set(CIR,SORTED_CIR),

     %on travaille par la suite le circuit sans les portes qui ont été trouvées
     ord_subtract( SORTED_CIR, SORTED_LGATES, CLEANED_CIR),

     %récupère toutes les sorties du niveau trouvé
     outputs_at_level( LGATES, NEWOUT),

     %ajoute les noeuds de sorties aux noeuds de recherche
     append( NODES, NEWOUT, NEWNODES),

     %reclasse les noeuds de recherche
     list_to_ord_set( NEWNODES, SORTED_NEWNODES),  

     %recherche des porte sur le niveau suivant
     aff_circuit( CLEANED_CIR, SORTED_NEWNODES, NEXTLLGATES).





%récupère une porte qui a toutes ses entrées dans la liste de noeuds
find_one_gate( CIR, NODES, GATE) :-

     %on prend une porte du circuit
     member( GATE, CIR),

     GATE=[_,_,IN,_],     

     %on vérifie si toutes le portes font bien parties des noeuds    
     ord_subset( IN, NODES).





%récupère toutes les sorties du niveau trouvé
outputs_at_level( [], []).
outputs_at_level( [[_,_,_,OUT]|NEXTGATES], NEWOUT) :-
     %concaténation des 2 listes
     append( OUT, OLDOUT, NEWOUT),

     %regarde la porte suivante
     outputs_at_level( NEXTGATES, OLDOUT).
     


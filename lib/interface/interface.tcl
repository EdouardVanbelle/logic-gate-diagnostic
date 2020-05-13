# -----------------------------------------------------------------------
# Définition de la fenêtre principale
# -----------------------------------------------------------------------


#attributs de la fenêtre principale
   set titre "Diagnostic"
   wm title . $titre
   #ainsi quand on ferme la fenêtre, on ferme aussi PROLOG
   wm protocol . WM_DELETE_WINDOW { quitter } 

#chargement des images
   image create photo dart_left      -file "$interface/icons/dart_left.gif"
   image create photo dart_left_end  -file "$interface/icons/dart_left_end.gif"
   image create photo dart_right     -file "$interface/icons/dart_right.gif"
   image create photo dart_right_end -file "$interface/icons/dart_right_end.gif"

# -----------------------------------------------------------------------
# Définition du menu
# -----------------------------------------------------------------------
menu .menu -tearoff 0

set m .menu.file
menu $m -tearoff 0
.menu add cascade -label "Fichier" -menu $m -underline 0
   $m add command -label "Ouvrir..." -command { fileDialog }
   $m add separator
   $m add command -label "Fermer" -command { efface }
   $m add separator
   $m add command -label "Enregistrer" -command { Save } -state disabled
   $m add command -label "Enregistrer sous..." -command { SaveAs }  
   $m add separator
   $m add command -label "Quitter" -command { quitter }

set m .menu.simulation
menu $m -tearoff 0
.menu add cascade -label "Simulation" -menu $m -underline 0
   $m add command -label "Observations..." -command { obs }
   $m add command -label "Diagnostiquer"   -command { new_calc }
   $m add separator
   $m add command -label "Diagnositcs multiples..." -command { batch } 
   
set m .menu.mode
menu $m -tearoff 0
.menu add cascade -label "Mode" -menu $m -underline 0
   $m add radio -label "Avec tous les nogoods" -variable minimaux -value "all" \
                                               -command { check_enable }
   $m add radio -label "Avec les nogoods minimaux" -variable minimaux -value "minimaux" \
                                               -command { check_enable }
   $m add separator
   $m add radio -label "Afficher les routes" -variable routes -value 1 \
                                             -command { force_show_wire }
   $m add radio -label "Cacher les routes"   -variable routes -value 0 \
                                             -command { hide_wire }
   

set m .menu.debug
menu $m -tearoff 0
.menu add cascade -label "Debuggage" -menu $m -underline 0
   $m add command -label "Variables" -command { debug_variable }  -state disabled



set m .menu.help
menu $m -tearoff 0
.menu add cascade -label "Aide" -menu $m -underline 0
   $m add command -label "Aide"     -command { GetHelp }
   $m add separator
   $m add command -label "A propos" -command { apropos }


# -----------------------------------------------------------------------
# Définition des boutons du haut
# -----------------------------------------------------------------------
frame .boutons
   button .boutons.obs      -text "Observations"  -height 1           -command { obs  } 
   button .boutons.calculer -text "Diagnostiquer" -height 1           -command { new_calc }  
   button .boutons.first -image dart_left_end    -height 21 -width 21 -command { aff_first } -state disabled
   button .boutons.prec  -image dart_left        -height 21 -width 21 -command { aff_prev }  -state disabled
   label  .boutons.navig -text " "               -height 2  -width  7 -relief groove           
   button .boutons.next  -image dart_right       -height 21 -width 21 -command { aff_next }  -state disabled
   button .boutons.last  -image dart_right_end   -height 21 -width 21 -command { aff_last }  -state disabled

   pack .boutons.obs .boutons.calculer .boutons.first .boutons.prec .boutons.navig .boutons.next .boutons.last \
        -side left -padx 2


# -----------------------------------------------------------------------
# Définition des boutons de gauche
# -----------------------------------------------------------------------
#Ajout des boutons pour placer des portes
frame .gate
   button .gate.boutonOr   -text "Or" 	 -width 4 -command {EnterGate ""   or "" "" "" ""}	 
   button .gate.boutonAnd  -text "And" 	 -width 4 -command {EnterGate ""  and "" "" "" ""}	 
   button .gate.boutonNor  -text "Nor" 	 -width 4 -command {EnterGate ""  nor "" "" "" ""}	 
   button .gate.boutonNand -text "Nand"  -width 4 -command {EnterGate "" nand "" "" "" ""} 	 
   button .gate.boutonXor  -text "Xor" 	 -width 4 -command {EnterGate ""  xor "" "" "" ""}	 
   button .gate.boutonXnor -text "Xnor"  -width 4 -command {EnterGate "" xnor "" "" "" ""}	 
   button .gate.boutonNot  -text "Not" 	 -width 4 -command {EnterGate ""  not "" "" "" ""}	 

   button .gate.boutonInput -text "Entrées"  -width 4 -command {EnterIn }	 
   button .gate.boutonOut -text "Sorties"    -width 4 -command {EnterOut }	 
      

   pack .gate.boutonOr .gate.boutonAnd .gate.boutonOr .gate.boutonAnd .gate.boutonNor \
	  .gate.boutonNand .gate.boutonXor .gate.boutonNot .gate.boutonXnor .gate.boutonInput\
	  .gate.boutonOut \
	  -side top 


   #button .gate.trace -text "Relier" 	 -width 4 -command {show_wire}	 
   #pack .gate.trace -side top -pady 35


# -----------------------------------------------------------------------
# Définition de la barre de status
# -----------------------------------------------------------------------
frame .statebar
   label .statebar.text -text " Attention: aucune vérification n'est effectuée,\
ni les saisies de valeurs, ni la validité des routes" -justify left
   pack .statebar.text -side left -fill x 


# -----------------------------------------------------------------------
# Définition du plan de travail
# -----------------------------------------------------------------------
frame .frame
set c .frame.c
canvas $c -scrollregion {0c 0c 60c 124c} -width 20c -height 15c \
          -background "#ffffcc" \
  	    -relief sunken -borderwidth 2 \
	    -xscrollcommand ".frame.hscroll set" \
	    -yscrollcommand ".frame.vscroll set"
	
scrollbar .frame.vscroll -command "$c yview"
scrollbar .frame.hscroll -orient horiz -command "$c xview"

grid $c -in .frame  -row 0 -column 0 -rowspan 1 -columnspan 1 -sticky news
grid .frame.vscroll -row 0 -column 1 -rowspan 1 -columnspan 1 -sticky news
grid .frame.hscroll -row 1 -column 0 -rowspan 1 -columnspan 1 -sticky news
grid rowconfig      .frame 0 -weight 1 -minsize 0
grid columnconfig   .frame 0 -weight 1 -minsize 0



# -----------------------------------------------------------------------
# Dessine l'écran
# -----------------------------------------------------------------------
. configure -menu .menu
pack  .boutons  -side top     -fill x
pack  .statebar -side bottom  -fill x 
pack  .gate     -side left    -fill y -pady 10
pack  .frame    -side top     -fill both -expand yes




# -----------------------------------------------------------------------
# Définition du popup
# -----------------------------------------------------------------------
menu  .menupopup -tearoff 0
.menupopup add command -label "Propriétés" -command { edit }
.menupopup add command -label "Infos position" -command { debug "Coordonnées: [GetPos [current_object]]"}
.menupopup add separator
.menupopup add command -label "Supprimer"  -command { delete_object  }


# -------------------------- fonctions ----------------------------------


# -----------------------------------------------------------------------
# Fonction qui gère la barre de status
# -----------------------------------------------------------------------
proc statusbar { text } {
   .statebar.text configure -text $text
}


# -----------------------------------------------------------------------
# Fonctions qui gèrent l'état des boutons de navigation
# -----------------------------------------------------------------------
proc disable_navig {} {
   # désactivation des boutons
   .boutons.first configure -state disabled
   .boutons.prec  configure -state disabled
   .boutons.next  configure -state disabled
   .boutons.last  configure -state disabled
}

proc enable_navig {} {
   # activation des boutons
   .boutons.first configure -state normal
   .boutons.prec  configure -state normal
   .boutons.next  configure -state normal
   .boutons.last  configure -state normal
}

# -----------------------------------------------------------------------
# Fonctions qui gèrent l'état du bouton de calcul
# -----------------------------------------------------------------------
#proc disable_calcul {} {
#   # désactivation des boutons
#   .boutons.calculer configure -state disabled
#}

#proc enable_calcul {} {
#   # activation des boutons
#   .boutons.calculer configure -state normal
#}

#proc check_enable {} {
#   global gate
#   if {([llength $gate] > 0)} {
#      #ok il y a un circuit chargé, on peut activer la command calcul
#      enable_calcul
#   }
#}


# ---------------------------------- fin de la déclaration de l'interface


# --------------------------------------------------------------
# Gestion des boîtes de dialogues
# --------------------------------------------------------------

# --------------------------------------------------------------
# Fenêtre à propos
# --------------------------------------------------------------
proc apropos {} {   
   tk_messageBox -title "A propos" -icon info -type ok -parent . -message \
"      Diagnostic\n\n\
Version Alpha\n\n\
auteurs:\n\
   Pérard Lionel <p44080@isen.fr>\n\
   Vanbelle Edouard <evanbelle@ifrance.com>"
   
}

# --------------------------------------------------------------
# Fenetre de débuggage
# --------------------------------------------------------------
proc debug {text} {
   tk_messageBox -title "debug" -icon info -message $text -type ok -parent .
}

# --------------------------------------------------------------
# Fenetre d'erreur
# --------------------------------------------------------------
proc erreur {text} {
   tk_messageBox -title "Erreur" -icon error -message $text -type ok -parent .
}



# --------------------------------------------------------------
# Fenêtre d'ouverture d'un fichier
# --------------------------------------------------------------
proc fileDialog {} {
    global titre

    #   Type names		Extension(s)	Mac File Type(s)
    #
    #---------------------------------------------------------
    set types {
	{"Circuits"		{.cir}		}
	{"Fichiers text"	{.txt}		TEXT}
	{"Tous"		*}
    }
    
    set fichier [tk_getOpenFile -filetypes $types -parent .]
    if {$fichier != ""} {
       #efface le plan de travail
       efface

       #change le titre
       wm title . "$titre: $fichier"

       #demande au prolog d'afficher le circuit (commande le tcl)
       prolog_event "affiche"

       #demande au prolog de charger le fichier
       prolog_event "charge('$fichier')"
       
       #demande au prolog de vider la variables globales
       prolog_event "clean_dyna"
       
       #modifie le mode bach
       get_from_standard
       
    }
}

# --------------------------------------------------------------
# Fenêtre d'enregistrement d'un fichier
# --------------------------------------------------------------
proc SaveAs {} {
    global last_filename gate inputf outputf obs
    
    if {( ([llength $gate]==0) || ([llength $inputf]==0) || ([llength $outputf]==0) || ([array size obs]==0) )} {
        erreur "Vous devez créer un circuit complet et définir toutes le observations pour sauvegarder"
        return
    }

    #   Type names		Extension(s)	Mac File Type(s)
    #
    #---------------------------------------------------------
    set types {
	{"Circuits"		{.cir}		}
	{"Fichiers text"	{.txt}		TEXT}
	{"Tous"		*}
    }
    
    set fichier [tk_getSaveFile -filetypes $types -parent .]
    if {$fichier != ""} {
       set last_filename $fichier
       Save
    }
}

proc Save {} {
    global last_filename gate inputf outputf obs

    if {( ([llength gate]==0) || ([llength inputf]==0) || ([llength outputf]==0) || ([array size obs]==0) )} {
        erreur "Vous devez créer un circuit complet et définir toutes le observations pour sauvegarder"
        return
    }

    CreateFile $last_filename
}


# --------------------------------------------------------------
# Fenêtre de création d'un porte
# --------------------------------------------------------------
  proc EnterGate { name type entrees sorties posx posy } {

	toplevel .topl
	wm geometry .topl 240x205
	wm title .topl "Création d'une porte $type"

	frame .topl.fdial
	pack .topl.fdial -fill both

	label .topl.fdial.nom -text "nom de la porte"
	entry .topl.fdial.name

	label .topl.fdial.en1 -justify left -text "noms des entrées" 
        label .topl.fdial.rap1 -justify left -text "syntaxe : e1 e2 e3 e4 e5 etc..."
	entry .topl.fdial.e1
        
	label .topl.fdial.en2 -text "nom de la sortie"
	entry .topl.fdial.e2

	pack .topl.fdial.nom .topl.fdial.name -side top  -pady 0
 	pack .topl.fdial.en1 .topl.fdial.rap1 -side top -pady 0 -padx 1
	pack .topl.fdial.e1 .topl.fdial.en2 -side top -pady 5 -padx 10 -fill x
	pack .topl.fdial.e2 -side top -pady 0 -padx 10 -fill x

	global ttype
	set ttype $type

	button .topl.fdial.ok -text "Ok" -width 4 -command {	
          CreateGate [.topl.fdial.name get] $ttype [.topl.fdial.e1 get] [.topl.fdial.e2 get] "" ""	    
	  destroy .topl 
      }	 
	button .topl.fdial.ann -text "Cancel" -width 4 -command {destroy .topl} 

	pack .topl.fdial.ann .topl.fdial.ok -side right -pady 15 -padx 10

	.topl.fdial.name insert 0 $name
        .topl.fdial.e1 insert 0 $entrees
        .topl.fdial.e2 insert 0 $sorties

  }

# --------------------------------------------------------------
# Fenêtre: Suppression d'un élément
# --------------------------------------------------------------
proc delete_object {} {
   global c gate outputf

   
   set objet [current_object]
   
   switch [get_object_type $objet] {
      "porte" {
         #c'est une porte
         set answer [tk_messageBox -message "Voulez-vous supprimer la porte '$objet'" \
                                  -title "Suppression..." -type yesno -icon question -parent .]
         if {("$answer"=="yes")} {
             DestroyGate $objet
         }
      }
      "sortie" {
         #c'est une sortie final
         set answer [tk_messageBox -message "Voulez-vous supprimer la sortie '$objet'" \
                                   -title "Suppression..." -type yesno -icon question -parent .]
         if {("$answer"=="yes")} {
             DestroySortie $objet
         }
      }
      "entree" {
         EnterIn
      }
   }
}


# --------------------------------------------------------------
# Fenêtre: Débuggage
# --------------------------------------------------------------
proc debug_variable {} {

        global outputf

	toplevel .topl
	wm geometry .topl 200x95
	wm title .topl "Débuggage"

	frame .topl.fdial
	pack  .topl.fdial -fill both

	label .topl.fdial.lbl -text "Variables"
        label .topl.fdial.syn -justify left -text "[info vars]"
	entry .topl.fdial.sorties
	         
	pack .topl.fdial.lbl .topl.fdial.syn .topl.fdial.sorties -side top -pady 0
	
	button .topl.fdial.ok -text "Ok" -width 4 -command {		
          set var [.topl.fdial.sorties get]    
          global $var
          debug  ${$var}
	  destroy .topl 
        }	 
	button .topl.fdial.ann -text "Cancel" -width 4 -command {destroy .topl} 

	pack .topl.fdial.ann .topl.fdial.ok -side right -pady 10 -padx 10

}


# --------------------------------------------------------------
# Fenêtre: saisie des val des entrées/sorties
# --------------------------------------------------------------
proc obs {} {
	global obs inputf outputf
	
	if  {( ([llength $inputf]<=0 )||([llength $outputf]<=0) )} {
	    erreur "Vous devez tout d'abord créer des entrées ou sortie(s)."
	    return
	} 
	
	toplevel .topl
	wm title .topl "Observation des entrés/sorties"

	frame .topl.fin
	pack .topl.fin -fill x

	label .topl.fin.lbl -text "valeurs des entrées"
	pack .topl.fin.lbl -side top	
		foreach in $inputf {
			label .topl.fin.lb$in -text $in -justify left
			entry .topl.fin.en$in -width 3
			pack  .topl.fin.lb$in .topl.fin.en$in -side left -padx 5			
			.topl.fin.en$in insert 0 [lindex [array get obs $in] 1]
		}

	frame .topl.fout
	pack .topl.fout -fill x

	label .topl.fout.label -text "valeurs des sorties"
	pack 	.topl.fout.label -side top
		foreach out $outputf {
				label .topl.fout.lab$out -text $out -justify left
				entry .topl.fout.en$out -width 3
				pack  .topl.fout.lab$out .topl.fout.en$out -side left -padx 5
				.topl.fout.en$out insert 0 [lindex [array get obs $out] 1]
			}

	frame .topl.but
	pack .topl.but -fill x

	button .topl.but.ok -text "Ok" -width 5 -command {		
		foreach node $inputf {
		        set liste {}
		        lappend liste $node
		        lappend liste [.topl.fin.en$node get]
			array set obs $liste
		}
		foreach node $outputf {
		        set liste {}
		        lappend liste $node
		        lappend liste [.topl.fout.en$node get]
			array set obs $liste
		}
	    destroy .topl 
        }	 
	button .topl.but.ann -text "Cancel" -width 5 -command {destroy .topl} 

	pack .topl.but.ann .topl.but.ok -side right -pady 10 -padx 10

}




# --------------------------------------------------------------
# Fenêtre: saisie des sorties
# --------------------------------------------------------------
proc EnterOut {} {

        global outputf

	toplevel .topl
	wm geometry .topl 200x95
	wm title .topl "Création des sorties du circuit"

	frame .topl.fdial
	pack .topl.fdial -fill both

	label .topl.fdial.lbl -text "nom des sorties"
        label .topl.fdial.syn -justify left -text "syntaxe : s1 out s2 s3 s4 s5 etc..."
	entry .topl.fdial.sorties
	         
	pack .topl.fdial.lbl .topl.fdial.syn .topl.fdial.sorties -side top -pady 0

	#on garde les valeurs déjà mémorisées
        .topl.fdial.sorties insert 0 "$outputf"
	
	button .topl.fdial.ok -text "Ok" -width 4 -command {	
          CreateOutputs [.topl.fdial.sorties get] 2    
	  destroy .topl 
        }	 
	button .topl.fdial.ann -text "Cancel" -width 4 -command {destroy .topl} 

	pack .topl.fdial.ann .topl.fdial.ok -side right -pady 10 -padx 10

}


# --------------------------------------------------------------
# Fenêtre: saisie des entrées
# --------------------------------------------------------------
proc EnterIn {} {
        global inputf

	toplevel .topl
	wm geometry .topl 200x95
	wm title .topl "Création des entrées du circuit"

	frame .topl.fdial
	pack .topl.fdial -fill both

	label .topl.fdial.lbl -text "nom des entrés"
	label .topl.fdial.syn -justify left -text "syntaxe : e1 in e2 e3 in1 e4 etc..."
	entry .topl.fdial.ent

	pack .topl.fdial.lbl .topl.fdial.syn .topl.fdial.ent -side top -pady 0

        .topl.fdial.ent insert 0 "$inputf"
	
	button .topl.fdial.ok -text "Ok" -width 4 -command {	
          DeleteInputs	
          CreateInputs [.topl.fdial.ent get]
	    destroy .topl 
        }	 
	button .topl.fdial.ann -text "Cancel" -width 4 -command {destroy .topl} 

	pack .topl.fdial.ann .topl.fdial.ok -side right -pady 10 -padx 10


}

# --------------------------------------------------------------
# Fenêtre pour l'aide
# --------------------------------------------------------------
proc GetHelp { } {
   #open "help/help.html" r
   #toplevel
   debug "en cours de développement"
}

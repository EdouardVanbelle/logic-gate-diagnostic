

# --------------------------------------------------------------
# Fenêtre: saisie des val des entrées/sorties en mode batch
# --------------------------------------------------------------
proc batch {} {
   global obs inputf outputf
	
   if  {( ([llength $inputf]<=0 ) || ([llength $outputf]<=0) )} {
      erreur "Vous devez tout d'abord créer des entrées ou sortie(s)."
      return
   } 
	
   toplevel .topl
   wm title .topl "Observation des entrés/sorties"

   frame .topl.info
      label .topl.info.txt -text "Cette fenêtre vous permet de rentrer plusieurs observations pour avoir un meilleur\
                                  diagnostic de votre schéma\n\n\
                                  Si vous choisissez de tout diagnostiquer, un travaill par élimination sera effectué\
                                  et vous aurez les portes valides en vert."
      pack .topl.info.txt
      pack .topl.info -fill x
      
   frame .topl.boutons
      label  .topl.boutons.fiche -text "Observation n°"
      button .topl.boutons.first -image dart_left_end    -height 21 -width 21 -command { get_values; first_obs }
      button .topl.boutons.prec  -image dart_left        -height 21 -width 21 -command { get_values; prec_obs }
      label  .topl.boutons.obs   -text " "               -height 2  -width  8 -relief groove           
      button .topl.boutons.next  -image dart_right       -height 21 -width 21 -command { get_values; next_obs }
      button .topl.boutons.last  -image dart_right_end   -height 21 -width 21 -command { get_values; last_obs }
      button .topl.boutons.add   -text "Ajouter"         -height 1            -command { get_values; add_obs }  
      button .topl.boutons.del   -text "Supprimer"       -height 1            -command { get_values; del_obs }
      button .topl.boutons.delA  -text "Tout supprimer"  -height 1            -command { get_values; dela_obs } 
      pack .topl.boutons.fiche .topl.boutons.first .topl.boutons.prec \
           .topl.boutons.obs .topl.boutons.next .topl.boutons.last \
           -side left -padx 2
      pack .topl.boutons.add -side left -padx 20
      pack .topl.boutons.del .topl.boutons.delA -side left -padx 2
      pack .topl.boutons -fill x -pady 15


   frame .topl.fin
      pack  .topl.fin -fill x
      label .topl.fin.lbl -text "valeurs des entrées"
      pack  .topl.fin.lbl -side top
      foreach in $inputf {
         label .topl.fin.lb$in -text $in -justify left
         entry .topl.fin.en$in -width 3
         pack  .topl.fin.lb$in .topl.fin.en$in -side left -padx 5			
      }


   frame .topl.fout
      pack  .topl.fout -fill x
      label .topl.fout.label -text "valeurs des sorties"
      pack  .topl.fout.label -side top
      foreach out $outputf {
         label .topl.fout.lab$out -text $out -justify left
         entry .topl.fout.en$out -width 3
         pack  .topl.fout.lab$out .topl.fout.en$out -side left -padx 5
      }


   frame .topl.but
      button .topl.but.save  -text "Enregistrer"         -command { get_values; save_values }	-state disabled	
      button .topl.but.load  -text "Charger"             -command { load_values }		-state disabled
      button .topl.but.calc1 -text "Diag. cette obs."    -command { get_values; calc1 }		
      button .topl.but.calcA -text "Tout diagnostiquer"  -command { get_values; calc_tout }		
      button .topl.but.close -text "Fermer"              -command { get_values; destroy .topl }
      pack  .topl.but.close .topl.but.calc1 .topl.but.calcA .topl.but.save .topl.but.load \
            -side right -pady 10 -padx 10
      pack  .topl.but -fill x
      
   redraw_obs
   set_values
}

#pour le hashage de batch_obs on prend comme clé: noeud@current_obs


# ----------------------------------------------------------------------
# récupère les obs standard pour les mémoriser sur la fiche courrante
# ----------------------------------------------------------------------
proc get_from_standard {} {
   global batch_obs inputf outputf obs current_obs
   foreach node $inputf {
      set liste {}
      #clé
      lappend liste "$node@$current_obs"
      #valeur
      lappend liste [lindex [array get obs $node] 1]
      #enregistrement
      array set batch_obs $liste
   }
   foreach node $outputf {
      set liste {}
      #clé
      lappend liste "$node@$current_obs"
      #valeur
      lappend liste [lindex [array get obs $node] 1]
      #enregistrement
      array set batch_obs $liste
   }
}

# ----------------------------------------------------------------------
# récupère les obs de la fiche courrante et les passe en standard
# ----------------------------------------------------------------------
proc set_to_standard {} {
   global batch_obs inputf outputf obs current_obs
   foreach node $inputf {
      set liste {}
      #clé
      lappend liste $node
      #valeur
      lappend liste [lindex [array get batch_obs "$node@$current_obs"] 1]
      #enregistrement
      array set obs $liste
   }
   foreach node $outputf {
      set liste {}
      #clé
      lappend liste $node
      #valeur
      lappend liste [lindex [array get batch_obs "$node@$current_obs"] 1]
      #enregistrement
      array set obs $liste
   }    
}

# ----------------------------------------------------------------------
# affiche les observations courrantes dans la fenêtre de saisie
# ----------------------------------------------------------------------
proc set_values {} {
   global batch_obs inputf outputf current_obs
   
   if {([array size batch_obs]==0)} {
      #le tableau n'existe pas, on le créé depuis les observations d'origine
      get_from_standard
   }

   #assigne les obs d'une fiche à la fenêtre de saisie
   foreach node $inputf {
      .topl.fin.en$node  delete 0
      .topl.fin.en$node  insert 0 [lindex [array get batch_obs "$node@$current_obs"] 1]
   }
   foreach node $outputf {
      .topl.fout.en$node delete 0
      .topl.fout.en$node insert 0 [lindex [array get batch_obs "$node@$current_obs"] 1]
   }
   
}

# ----------------------------------------------------------------------
#  copie une fiche en une autre
# ----------------------------------------------------------------------
proc copy_fiche { source dest } {
   global current_obs
   #sauvegarde la fiche courrante
   set tmp $current_obs
   #copie la fiche source en standard
   set current_obs $source
   set_to_standard
   #copie l'obs standard en fiche dest
   set current_obs $dest
   get_from_standard
   #revient sur la fiche courrante
   set current_obs $tmp
}

# ----------------------------------------------------------------------
# récupère les saisies de la fenêtre et les mémorise
# ----------------------------------------------------------------------
proc get_values {} {
   global batch_obs inputf outputf obs current_obs
   foreach node $inputf {
      set liste {}
      #clé
      lappend liste "$node@$current_obs"
      #valeur
      lappend liste [.topl.fin.en$node get]
      #enregistrement
      array set batch_obs $liste
   }
   foreach node $outputf {
      set liste {}
      #clé
      lappend liste "$node@$current_obs"
      #valeur
      lappend liste [.topl.fout.en$node get]
      #enregistrement
      array set batch_obs $liste
   }

}

# ----------------------------------------------------------------------
# redessine le numéro de la fiche et actualise les saisies
# ----------------------------------------------------------------------
proc redraw_obs {} {
    global current_obs nb_obs
    .topl.boutons.obs configure -text "$current_obs/$nb_obs"
    if {($nb_obs==1)} {
       .topl.boutons.del  configure -state disabled
       .topl.boutons.delA configure -state disabled 
    } else {
       .topl.boutons.del  configure -state normal
       .topl.boutons.delA configure -state normal 
    }
    #redessine la table des saisies
    set_values
}


# ----------------------------------------------------------------------
# ajoute une fiche
# ----------------------------------------------------------------------
proc add_obs {} {
    global current_obs nb_obs
    incr nb_obs
    #la nouvelle fiche est une copie de celle actuelle
    copy_fiche $current_obs $nb_obs
    #on va sur la nouvelle fiche
    set  current_obs $nb_obs
    redraw_obs    
}


# ----------------------------------------------------------------------
# détruit toutes le fiches sauf la courrante
# ----------------------------------------------------------------------
proc dela_obs {} {
    global current_obs nb_obs
    #recopie la fiche actuelle en standard (seule fiche qui va rester)
    copy_fiche $current_obs 1
    set current_obs 1
    set nb_obs 1
    redraw_obs
}


# ----------------------------------------------------------------------
# Détruit la fiche courrante
# ----------------------------------------------------------------------
proc del_obs {} {
    global current_obs nb_obs
    if ($nb_obs>1) {
      #il reste plus d'une obs, on peut en enlever
      incr nb_obs -1
      if ($current_obs>1) {
         #on reste sur l'observation primaire
         incr current_obs -1
         
      }
      redraw_obs
    }
}

# ----------------------------------------------------------------------
# retourne sur la 1iere fiche
# ----------------------------------------------------------------------
proc first_obs {} {
    global current_obs nb_obs
    set current_obs 1
    #incr nb_obs  
    redraw_obs
}

# ----------------------------------------------------------------------
# va à la fiche précédente
# ----------------------------------------------------------------------
proc prec_obs {} {
    global current_obs nb_obs
    incr current_obs -1
    if { ($current_obs==0) } {
       set current_obs $nb_obs
    }
    redraw_obs
}

# ----------------------------------------------------------------------
# va à fiche suivante
# ----------------------------------------------------------------------
proc next_obs {} {
    global current_obs nb_obs
    incr current_obs
    if { ($current_obs>$nb_obs) } {
       set current_obs 1
    }
    redraw_obs
}


# ----------------------------------------------------------------------
# va à la dernière fiche
# ----------------------------------------------------------------------
proc last_obs {} {
    global current_obs nb_obs
    set current_obs $nb_obs
    redraw_obs
}


# ----------------------------------------------------------------------
# diagnostique l'observation actuelle
# ----------------------------------------------------------------------
proc calc1 {} {
    set_to_standard
    new_calc
    destroy .topl
}


# ----------------------------------------------------------------------
# Redessine le numéro du calcul en cours
# ----------------------------------------------------------------------
proc redraw_progression {} {
    global current_obs nb_obs
    .topl.info.end configure -text "$current_obs/$nb_obs"
    update
}

# ----------------------------------------------------------------------
# calcule toutes le fiches
# ----------------------------------------------------------------------
proc calc_tout {} {
   global current_obs nb_obs goods last_obs cumul_all_candidats
   global minimaux all_candidats working_file inputf outputf gate
   
   destroy .topl

   toplevel .topl
   wm title .topl "Progression..."
   
   frame .topl.info
      pack .topl.info
      label .topl.info.begin -text "Calcul en cours: "
      label .topl.info.end   -text "init" -width 8
      pack  .topl.info.begin .topl.info.end -side left

   #passe la souris en sablier
   . configure -cursor watch
   update

   set last_obs $current_obs
   set goods {}
   set cumul_all_candidats {}

   
   # ne pas oublier que les événements sont dans une fifo
   #demande au prolog de lancer les résultats (ainsi on attent qu'il ait fini tous ces calculs)
   prolog_event "finishcalctout"

   
   for {set current_obs 1} {($current_obs<=$nb_obs)} {incr current_obs} {

      redraw_progression

      #vide tous les candidats
      set all_candidats {}
   
      #mémorise le circuit (sauvgarde)
      CreateFile "$working_file"
   
      # !!!  on utilise une fifo pour les événements (donc tout est inversé)
   
      #effectue le diagnostique (complet ou minimal)
      prolog_event "diag($minimaux)"
      #charge le circuit dans l'interpréteur prolog
      prolog_event "charge('$working_file')"       
      #demande au prolog de vider la variables globales
      prolog_event "clean_dyna"
            
   }
   
}


# ----------------------------------------------------------------------
#fin de la procédure calc_tout (appelée par Prolog)
# ----------------------------------------------------------------------
proc calc_tout_end {} {
   global goods last_obs current_obs cumul_all_candidats goods gate
  
   #on recherche les éléments qui sont corrects et on les marque
    set defectueux {}
    foreach candidat $cumul_all_candidats {
          set defectueux [concat $defectueux $candidat]

    }
    #on recherche les éléments qui sont corrects et on les marque
    foreach porte $gate {
       if { ([lsearch $defectueux $porte]==(-1)) } {
          #la porte n'est pas deffectueuse
          if {([lsearch $goods $porte]==-1)} {
             #on la mémorise car ce n'est pas encore fait
             lappend goods $porte
          }
       }
    }
  
  
   #désactive les boutons de navigation
   disable_navig
   
   #passe toutes le portes en blanc
   validate_all_gates
   
   #met en vert toutes les portes parfaites
   show_good_gates
   
   #remet la souris normale
   . configure -cursor arrow
   update

   set current_obs $last_obs
   
   destroy .topl
   
   tk_messageBox -title "résultat" -icon info -type ok -parent . \
                 -message "Il y a [llength $goods] porte(s) correcte(s) (en vert)" 

}

# ----------------------------------------------------------------------
# sauvegarde les fiches
# ----------------------------------------------------------------------	 
proc save_values {} {
    debug "En cours de développement"
    destroy .topl
}

# ----------------------------------------------------------------------
# charge les fiches
# ----------------------------------------------------------------------
proc load_values {} {
    debug "En cours de développement"
    destroy .topl
}
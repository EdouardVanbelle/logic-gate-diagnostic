
# ----------------------------------------------------------------------
# récupère la position d'un objet
# ----------------------------------------------------------------------
proc GetPos { objet } {
   global gate outputf 
   
   if { ([lsearch $gate $objet]>=0) } {
      return [GetGatePos $objet]
   } elseif { ([lsearch $outputf $objet]>=0) } {
      return [GetSortiePos $objet]
   } else {
      return "Pas de coordonnée pour cette objet"
   }
}


# ----------------------------------------------------------------------
# récupère les coordonnées de la patte d'une sortie
# ----------------------------------------------------------------------
proc get_coord_sortie { name } {
    global gate ins outs c
        
    set ids [$c find withtag $name]
       
    #récupère les coordonnées de la patte
    set coords [$c coords [lindex $ids end]]
    #remarque: utiliser coords au lieu de bbox
    
    #sélectionne le bon côté de la patte (sortie=droite, entrée=gauche)
    lappend retour [lindex $coords 2]   
    lappend retour [lindex $coords 3]
    return $retour
}

# ----------------------------------------------------------------------
# récupère les coordonnées d'une patte d'une porte
# ----------------------------------------------------------------------
proc get_coord_node { name node } {
    global gate ins outs c
        
    set pos [lsearch $gate $name]
    set in  [lindex $ins $pos]
    set out [lindex $outs $pos]
    
    set pos_in  [lsearch $in  $node]
    set pos_out [lsearch $out $node]
    
    set len_in  [llength $in]
    set len_out [llength $out]
    
    set ids     [$c find withtag $name]
    set len_ids [llength $ids]
   
    if {($pos_out>-1)} {
      #le noeud se trouve dans les sorties
      set seek [expr $len_ids-$len_in-$len_out+$pos_out]
    }  elseif {($pos_in>-1)} {
      #le noeud se trouve dans les sorties
      set seek [expr $len_ids-$len_in+$pos_in]
    } else {
      #le noeud n'existe pas dans cette porte, on retourne une liste vide
      return {}
    }
    
    #récupère les coordonnées de la patte
    set coords [$c coords [lindex $ids $seek]]
    #remarque: utiliser coords au lieu de bbox
    
    #sélectionne le bon côté de la patte (sortie=droite, entrée=gauche)
    lappend retour [lindex $coords 2]   
    lappend retour [lindex $coords 3]
    return $retour
}

# ----------------------------------------------------------------------
# cette fonction affiche les routes s'il le faut
# ----------------------------------------------------------------------
proc show_wire {} {
    global routes
    if ($routes) {
        force_show_wire
    }
}

# ----------------------------------------------------------------------
# redessine les routes
# ----------------------------------------------------------------------
proc redraw {} {
    hide_wire
    #le choix de l'affichage des routes par l'utilisateur est pris en compte
    show_wire
}

# ----------------------------------------------------------------------
# affiche les routes
# ----------------------------------------------------------------------
proc force_show_wire {} { 
    LinkGates
}

# ----------------------------------------------------------------------
# cache les routes
# ----------------------------------------------------------------------
proc hide_wire {} {
   global wires c
   if ([llength $wires]>0) {
      #destruction des routes
      foreach obj $wires {
         $c delete $obj
      }
      set wires {}
   }
}

# ----------------------------------------------------------------------
# on efface tous les éléments
# ----------------------------------------------------------------------
proc efface {} {
    global c gate all_candidats ins outs titre outputf inputf types goods cumul_all_candidats 
    global current_obs nb_obs
    
    hide_wire
    if ([llength $gate]>0) {
       #destruction des entrées du circuit
       $c delete entree
       #destruction des portes
       foreach obj $gate {
          $c delete $obj
       }
       #destruction des sorties du circuit
       foreach obj $outputf {
          $c delete $obj
       }
       
       #réinitialise les variables
       set gate {}
       set types {}
       set all_candidats {}
       set ins {}
       set outs {}
       set inputf {}
       set outputf {}
       set goods {}
       set cumul_all_candidats  {}
       #plus de navigation possible
       disable_navig

       set current_obs 1
       set nb_obs 1

       #remet le titre normal
       wm title . $titre
       
    }
}


# ----------------------------------------------------------------------
# effectue 1 diagnostic
# ----------------------------------------------------------------------
proc new_calc {} {
   global minimaux all_candidats working_file inputf outputf gate goods
   
   
   if  {( ([llength $inputf]<=0 )||([llength $outputf]<=0)||([llength $gate]<=0))} {
      erreur "Vous devez tout d'abord créer un circuit complet."
      return
   } 

   set goods {}

   #passe la souris en sablier
   . configure -cursor watch
   update
   
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

   #remet la souris
   . configure -cursor arrow
   update
   
}




# ----------------------------------------------------------------------
# apprentissage des candidats (ajoute la liste des candidats à la suite)
# ----------------------------------------------------------------------
proc learn_candidats { candidats } {
    global all_candidats cumul_all_candidats 
    lappend all_candidats $candidats
    if {([lsearch $cumul_all_candidats $candidats]==(-1))} {
       #le candidat n'est pas encore mémorise, on le fait
       lappend cumul_all_candidats $candidats
    }
}


# ----------------------------------------------------------------------
# apprentissage des portes correctes (en fonction des candidats)
# ----------------------------------------------------------------------
proc learn_good {} {
    global gate goods all_candidats
    set defectueux {}
    foreach candidat $all_candidats {
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
}

# ----------------------------------------------------------------------
# apprentissage des observations
# ----------------------------------------------------------------------
proc learn_obs { cle val } {
    global obs
    set liste {}
    lappend liste $cle
    lappend liste $val
    array set obs $liste
}



# ----------------------------------------------------------------------
# colorise une porte
# ----------------------------------------------------------------------
proc colorize { gate color } { 
   global c 
   set ids [$c find withtag $gate]
   foreach id $ids {
      set typeobj [$c type $id]
      if {(("$typeobj" == "rectangle") || ("$typeobj" == "oval"))} {
         $c itemconfigure $id -fill $color
      }
   }
}


# ----------------------------------------------------------------------
# colorise en route la liste des portes
# ----------------------------------------------------------------------
proc unvalidate_gates { gates } {
   set bad "#ff6666"
   foreach gate $gates {
       colorize $gate $bad
   }
}


# ----------------------------------------------------------------------
# repasse toutes les portes en blanc
# ----------------------------------------------------------------------
proc validate_all_gates {} {
    global gate
    foreach one_gate $gate {
        colorize $one_gate white
    }
}

# ----------------------------------------------------------------------
# passe les portes correctes en vert
# ----------------------------------------------------------------------
proc show_good_gates {} {
    global goods
    set color "#66ff66"
    foreach porte $goods {
       colorize $porte $color
    }
}


# ----------------------------------------------------------------------
# affiche la couleur de chaque porte en fonction de son état
# ----------------------------------------------------------------------
proc show_state { indice } {
    global all_candidats
    validate_all_gates

    #modifie le label (indique la solution affichée)
    .boutons.navig configure -text "[expr $indice+1]/[llength $all_candidats]"

    unvalidate_gates [lindex $all_candidats $indice]
    show_good_gates 
}


# ----------------------------------------------------------------------
# sauvegarde le plan de travail
# ----------------------------------------------------------------------
proc CreateFile { filename } {

global pos gate ins outs inputf outputf types obs 

set file [open $filename w]


puts $file "cir \["

set pos 0
set end [expr [llength $gate]-1]
foreach porte $gate {
  #détermine s'il faut ajouter une virgule en fin de ligne
  if {($pos == $end)} { set sep "" } else { set sep "," }
  set entrees [join [lindex $ins $pos] ", "]
  set sorties [join [lindex $outs $pos] ", "]
  puts $file "  gate \[ name: $porte, type: [lindex $types $pos], in: \[$entrees\], out: \[$sorties\] \]$sep"
  incr pos 1
}
puts $file "\]."

puts $file "input \["
set pos 0
set end [expr [llength $inputf]-1]
foreach in $inputf {
  #détermine s'il faut ajouter une virgule en fin de ligne
  if {($pos == $end)} { set sep "" } else { set sep "," }
  puts $file "  $in=[lindex [array get obs $in] 1]$sep"
  incr pos 1
}
puts $file "\]."

puts $file "output \["
set pos 0
set end [expr [llength $outputf]-1]
foreach out $outputf {
  #détermine s'il faut ajouter une virgule en fin de ligne
  if {($pos == $end)} { set sep "" } else { set sep "," }
  puts $file "  $out=[lindex [array get obs $out] 1]$sep"
  incr pos 1
}
puts $file "\]."

#on ferme le fichier
close $file

}

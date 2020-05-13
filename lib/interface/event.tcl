# ------------------------------------------------------------
# Gestion des �venements
# ------------------------------------------------------------

#Binds de la souris pour les actions

bind $c <1> { itemStartDrag %x %y }
bind $c <B1-Motion> { itemDrag %x %y }
bind $c <ButtonRelease-1> {hide_wire ; show_wire}

bind $c <Control-1> { startPanning %x %y}
bind $c <Control-B1-Motion> { Panning %x %y  }

bind . <Control-KeyPress> { . configure -cursor hand1; update }
bind . <Control-KeyRelease> { . configure -cursor arrow; update }

$c bind all <Any-Enter> { is_on }
$c bind all <Any-Leave> { is_out }

$c bind all <ButtonRelease-3> { tk_popup .menupopup %X %Y }
$c bind all <Double-Button-1> { edit }


# ------------------------------------------------------------
# Actions associ�es aux boutons de navigation
# ------------------------------------------------------------
proc aff_first {} {
    global state 
    set state 0
    show_state $state
}

proc aff_next {} {
    global state all_candidats
    incr state
    if {($state == [llength $all_candidats])} {
       set state 0
    }
    show_state $state
}

proc aff_prev {} {
    global state all_candidats
    incr state -1
    if {($state == -1)} {
       set state [expr [llength $all_candidats]-1]
    }
    show_state $state
}

proc aff_last {} {
    global state all_candidats
    set state [expr [llength $all_candidats]-1]
    show_state $state
}

# ------------------------------------------------------------
# Actions associ�es au d�placement du plan de travail
# ------------------------------------------------------------
proc startPanning {x y} {
  global c
  $c scan mark [expr $x/10] [expr $y/10]
}

proc Panning {x y} {
  global c
  $c scan dragto [expr $x/10] [expr $y/10]
}



# ------------------------------------------------------------
# Double clic: edition des props d'une porte
# ------------------------------------------------------------
proc edit {} {
    global gate ins outs types c
    set objet [current_object]
    switch [get_object_type $objet]  {
       "porte" {
          #on se trouve sur une porte, on peut ouvrir ses propri�t�s
          set pos  [lsearch $gate $objet]
          set in   [lindex $ins $pos]
          set out  [lindex $outs $pos]
          set type [lindex $types $pos]
          EnterGate $objet $type $in $out 3 3               
       }
       "entree" {
          #on entre les entr�es
          EnterIn
       }
       "sortie" {
          #on edite les sorties
          EnterOut
       }
       default {
          debug "En cours de d�veloppement"
       }
    }
}



# ------------------------------------------------------------
# Actions associ�es au passage de la souris sur une porte
# ------------------------------------------------------------
proc is_on {} {
    global c
    set objet [current_object]
    set type [get_object_type $objet] 
    if { (("$type"=="porte") || ("$type"=="sortie")) } {
      . configure -cursor hand1
      update
    }
}

proc is_out {} {
   #remet la souris normale
   . configure -cursor arrow
   update
}

# ------------------------------------------------------------
# Actions associ�es au d�placement d'une porte
# ------------------------------------------------------------
proc itemStartDrag {x y} {
    global lastX lastY c
    set lastX [$c canvasx $x]
    set lastY [$c canvasy $y]

}

proc itemDrag {x y} {
    global lastX lastY c

    set objet [current_object]
    set type [get_object_type $objet] 
    if { (("$type"=="porte") || ("$type"=="sortie")) } {
      set x [$c canvasx $x]
      set y [$c canvasy $y]
      $c move $objet [expr $x-$lastX] [expr $y-$lastY]
      set lastX $x
      set lastY $y
    }

 }

# ------------------------------------------------------------
# Action associ�e � la fermeture de la fen�tre
# ------------------------------------------------------------
proc quitter {} {
   global interface

   set answer [tk_messageBox -title "Quitter..." \
              -message "Voulez-vous quitter l'application ?\n (pensez � enregistrer votre sch�ma)"\
              -type yesno -icon question -parent .]

   if {("$answer"=="yes")} {
      if {("$interface" != ".")} {
         #on est en mode prolog
         #demande au prolog de tout fermer
         prolog_event "exit_main"
      } else {
         #on est en mode autonome (test de l'interface)
         #on d�truit tout (fermeture des fen�tres)
         destroy .
      }
   }
}

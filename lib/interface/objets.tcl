# ------------------------------------------------------------
# Renvoie le nom de l'objet courrant
# ------------------------------------------------------------
proc current_object {} {
   global c
   return [lindex [$c gettags current] 0]
}

# ------------------------------------------------------------
# Renvoie le type d'objet
# ------------------------------------------------------------
proc get_object_type { objet } {
   global gate outputf
   if {([lsearch $gate $objet]>=0)} {
      return "porte"
   } elseif {("$objet"=="entree")} {
      return "entree"
   } elseif { ([lsearch $outputf $objet]>=0) } {
      return "sortie"
   } else {
      return "noeud"
   }
}

# ------------------------------------------------------------
# Dessine les entrés du circuit
# ------------------------------------------------------------

proc CreateInputs {liste_entrees} {
   global c inputf
   set x 10  

   foreach entree $liste_entrees {
      incr x 40
      $c addtag entree withtag [$c create text $x 1c -text $entree -anchor s]
      $c addtag entree withtag [$c create line $x 1c $x 1500 ]
      lappend inputf $entree
   }

   #redessine les routes
   redraw
}


# ------------------------------------------------------------
# Détruit les entrées
# ------------------------------------------------------------
proc DeleteInputs {} {
   global c inputf
   if {([llength $inputf]>0)} {
      #il y a des entrées, on peut les détruire
      $c delete entree 
      set inputf {}
   }

   #redessine les routes
   redraw

}



# ------------------------------------------------------------
# Détruit une sortie du circuit
# ------------------------------------------------------------
proc DestroySortie { out } {
    global c outputf

    set pos [lsearch $outputf $out]
        
    if {($pos!=(-1))} {
       #supprime les éléments caractérisant la sortie
       set outputf [lreplace $outputf $pos $pos]
    
       #on enlève l'objet du canvas
       $c delete $out
    }

   #redessine les routes
   redraw

}


# ------------------------------------------------------------
# Récupère la position d'une sortie
# ------------------------------------------------------------
proc GetSortiePos { out } {
   global c
   set objets [$c find withtag $out]
   foreach obj $objets {
      if {("[$c type $obj]" == "polygon")} {
         set coords [$c coords $obj]
         set newcoord {}
         lappend newcoord [expr round(([lindex $coords 0]+[lindex $coords 6])/2)]
         lappend newcoord [expr round(([lindex $coords 1]+[lindex $coords 7])/2)]

         return $newcoord
      }
   }
}


# ------------------------------------------------------------
# Déssine les sorties du circuit
# ------------------------------------------------------------
proc CreateOutputs { lsorties xx } {
    global c outputf
    set sizenode 16
    
    set ywidth 7
    set xwidth 30
    
    set x [expr ($xx +2) * 150]
    #set x $xx
    set y 150
    
    foreach nom $outputf {
       if { ([lsearch $lsorties $nom]==(-1)) } {
          #la sortie n'existe plus on peut la supprimer
          set pos [lsearch $outputf $nom]
          set outputf [lreplace $outputf $pos $pos]
          
          $c delete $nom
       }
    }
    
    foreach nom $lsorties {

       if { ([lsearch $outputf $nom]==(-1)) } {
           #la sortie n'existe pas, on peut la créer

           $c addtag $nom withtag [$c create polygon [expr $x-$xwidth] [expr $y-$ywidth] \
                                                     [expr $x+$xwidth] [expr $y-$ywidth] \
                                                     [expr $x+$xwidth+10] $y \
                                                     [expr $x+$xwidth] [expr $y+$ywidth] \
                                                     [expr $x-$xwidth] [expr $y+$ywidth] \
                                                     -outline black -fill white]    
           #affichage du nom
           $c addtag $nom withtag [$c create text $x $y -text $nom -justify center]

           #affichage de la patte
           $c addtag $nom withtag  [$c create line [expr $x-$xwidth] $y \
                                                   [expr $x-$xwidth-$sizenode] $y \
                                                   -fill black]

           #mémorise dans la liste des sorties du circuit        
           lappend outputf $nom
           incr y 150
       }
    }

   #redessine les routes
   redraw
}

# -----------------------------------------  les portes --------------------------------------------------

# ------------------------------------------------------------
# création d'une porte
# ------------------------------------------------------------
proc CreateGate {name type entrees sorties xx yy} {
    global c gate
    if { (($xx == "") || ($yy == "")) } {
       #on place la porte au milieu de l'écran
       set x 350
       set y 400
    } else {
       set x [expr ($xx+2) * 150]
       set y [expr (($yy+1)*150 + 75*(($xx%2)-1))]
    }

    if ([lsearch $gate $name]==(-1)) {
      #ok la porte n'existe pas, on peut la créer
      DrawGate $name $type $entrees $sorties $x $y
    } else {
      #la porte existe déjà, on la remplace
      set coord [GetGatePos $name]
      DestroyGate $name
      DrawGate $name $type $entrees $sorties [lindex $coord 0] [lindex $coord 1]
    }

   #redessine les routes
   redraw

}

# ------------------------------------------------------------
# Récupère la position d'une porte
# ------------------------------------------------------------
proc GetGatePos { gate } {
   global c
   set objets [$c find withtag $gate]
   foreach obj $objets {
      if {("[$c type $obj]" == "rectangle")} {
         set coords [$c coords $obj]
         set newcoord {}
         lappend newcoord [expr round(([lindex $coords 0]+[lindex $coords 2])/2)]
         lappend newcoord [expr round(([lindex $coords 1]+[lindex $coords 3])/2)]

         return $newcoord
      }
   }
}


# ------------------------------------------------------------
# Détruit une porte
# ------------------------------------------------------------
proc DestroyGate { porte } {
    global c gate ins outs types

    set pos [lsearch $gate $porte]
    
    if {($pos!=(-1))} {
       #supprime les éléments caractérisant la porte
       set gate  [lreplace $gate  $pos $pos]
       set ins   [lreplace $ins   $pos $pos]
       set outs  [lreplace $outs  $pos $pos]
       set types [lreplace $types $pos $pos]    
       #on enlève l'objet du canvas
       $c delete $porte

       #redessine les routes
       redraw
    }
}

# ------------------------------------------------------------
# Déssine une porte sur le circuit
# ------------------------------------------------------------
proc DrawGate {name type entrees sorties x y} {
    global c gate ins outs types

    set decal 6
    #compte le nombre d'entrées
    set nb_entrees [llength $entrees]
    #calcul la hauteur de la porte
    set ywidth [expr ($nb_entrees+1) * $decal]
    set xwidth 25
    set sizenode 8
           
    $c addtag $name withtag [$c create rectangle [expr $x - $xwidth] [expr $y - $ywidth] \
                                                 [expr $x + $xwidth] [expr $y + $ywidth] \
                                                 -outline black -fill white]
    
    #tracé du nom de la porte
    switch $type {
       not { set symbol "1"}
       inv { set symbol "1"}
       and { set symbol "&"}
        or { set symbol ">=1"}
       xor { set symbol "=1"}
      nand { set symbol "&"}
       nor { set symbol ">=1"}
      xnor { set symbol "=1"}
    }
    $c addtag $name withtag [$c create text $x $y -text $symbol -justify center]


    $c addtag $name withtag [$c create text $x [expr $y+$ywidth+3] -text $name  -anchor n]
    
    #ATTENTION: l'odre d'affichage des pattes est très important, ne pas le modifier (car il respecte l'ordre 
    #           respectif des sorties puis des entrées (utilisé par la suite))
    
    
    #affichage des noms noeuds d'entrée
    set posy [expr $y - $ywidth]
    foreach entree $entrees  {
        incr posy [expr 2 * $decal]
        $c addtag $name withtag [$c create text [expr $x-$xwidth-$sizenode] $posy \
                                                -text $entree -anchor se -fill "#888888"]
    }

    #affichage du nom du noeud de sortie
    $c addtag $name withtag [$c create text [expr $x+$xwidth+$sizenode] $y \
                                            -text [lindex $sorties 0] -anchor sw -fill "#888888"]


    #tracé de la sortie
    if {(("$type"=="not") || ("$type"=="nand") || ("$type"=="nor") || ("$type"=="inv") || ("$type"=="xnor"))} {
      #on affiche l'inversion de la sortie
      $c addtag $name withtag [$c create oval [expr $x+$xwidth] [expr $y-$sizenode/2] \
                                              [expr $x+$xwidth+$sizenode] [expr $y+$sizenode/2] \
                                              -fill white -outline black]
      $c addtag $name withtag [$c create line [expr $x+$xwidth+$sizenode] $y \
                              [expr $x+$xwidth+$sizenode*2] $y -fill black]
    } else {
      #on affiche une sortie normale
      $c addtag $name withtag [$c create line [expr $x+$xwidth] $y \
                              [expr $x+$xwidth+$sizenode*2] $y -fill black]
    }
    
    #tracé des entrées
    set posy [expr $y - $ywidth]
    foreach entree $entrees  {
        incr posy [expr 2 * $decal]
        $c addtag $name withtag [$c create line [expr $x-$xwidth] $posy \
                                                [expr $x-$xwidth-$sizenode*2] $posy -fill black]
    }

    #correction de l'espace inséré par prolog
    set my_entrees {}
    foreach tmp $entrees {
       lappend my_entrees $tmp
    }
    set my_sorties {}
    foreach tmp $sorties {
       lappend my_sorties $tmp
    }

    #on mémorise les infos
    lappend gate  $name
    lappend ins   $my_entrees
    lappend outs  $my_sorties
    lappend types $type
    
    redraw
}

# ------------------------------------------------------------
# Déssine une route sur le circuit
# ------------------------------------------------------------
proc wire { gate1 gate2 node } {
   global c ins outs gate inputf outputf wires

   set coord1 [get_coord_node $gate1 $node]
   set coord2 [get_coord_node $gate2 $node]

   set x1 [lindex $coord1 0]
   set y1 [lindex $coord1 1]
   
   set x2 [lindex $coord2 0]
   set y2 [lindex $coord2 1]

   draw_line $node $x1 $y1 $x2 $y2
}  

# ------------------------------------------------------------
# Trace une ligne
# ------------------------------------------------------------
proc draw_line { node x1 y1 x2 y2 } { 
   global c wires gate  ins outs inputf outputf
   
   set name    _$node
   set color   "#8888ff"
   set radius  1.5

   if {( ($x1==$x2) || ($y1==$y2) )} {
      $c addtag $name withtag [$c create line $x1 $y1 $x2 $y2  -fill $color]
   } else {
      set xm [expr round(($x1+$x2)/2)]
      $c addtag $name withtag [$c create line $x1 $y1 $xm $y1 $xm $y2 $x2 $y2  -fill $color]
      
   }
   
   
   #tracé des points de jointure
   $c addtag $name withtag [$c create oval [expr $x1-$radius] [expr $y1-$radius] \
                                           [expr $x1+$radius] [expr $y1+$radius] \
                                           -fill $color -outline $color]
   $c addtag $name withtag [$c create oval [expr $x2-$radius] [expr $y2-$radius] \
                                           [expr $x2+$radius] [expr $y2+$radius] \
                                           -fill $color -outline $color]
   #passe la ligne en dessous de la première porte
   $c lower $name [lindex [$c find withtag [lindex $gate 0]] 0]
   
   lappend wires $name
}

# ------------------------------------------------------------
# Trace les liaisons
# ------------------------------------------------------------
proc LinkGates { } {
   global c ins outs gate inputf outputf wires

   set pos 0   

   #on applique sur toutes les portes
   foreach currentgate $gate {

	set ingate [lindex $ins $pos]
	set outgate [lindex $outs $pos]

	#sur chaque entree
	foreach patte $ingate {
		
		#on cherche les liens avec les entrees du circuit
		set wichinput 10
		foreach incir $inputf {
			incr wichinput 40
			if {[string compare $patte $incir]== 0} {
				set curcoor [get_coord_node $currentgate $patte]
				set x [lindex $curcoor 0]
				set y [lindex $curcoor 1]				
				set x0 $wichinput
				draw_line $patte  $x $y $x0 $y
			}
		}

		#on cherche les liens avec les sorties de composants
		set whichgate 0
		foreach outcomp $outs {
			if {[string compare $patte $outcomp]==0} {
				wire $currentgate [lindex $gate $whichgate] $patte
			}
		incr whichgate 1
		}
	}

	#sur chaque sortie
	foreach patte $outgate {

		#on cherche les liens avec les sorties du circuit
		foreach outcir $outputf {
			if {[string compare $patte $outcir]==0} {
				set curcoor [get_coord_node $currentgate $patte]
				set x [lindex $curcoor 0]
				set y [lindex $curcoor 1]
				set outcoor [get_coord_sortie $outcir]  
				set x1 [lindex $outcoor 0]
				set y1 [lindex $outcoor 1]
				draw_line $patte  $x $y $x1 $y1
			}
		}
	}
	incr pos 1
   }
}

# ---------------------------------------------------------- fin de fichier


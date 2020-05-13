# -------------------------------------------------------
# Chargement des différents fichiers
# -------------------------------------------------------

#variable définie par prolog sinon on la définie pour les tests
if {([info exist interface] == 0)} {
   set interface .
}


#déclaration de l'interface
source "$interface/interface.tcl"
source "$interface/objets.tcl"
source "$interface/dialog.tcl"
source "$interface/event.tcl"
source "$interface/circuit.tcl"
source "$interface/batch.tcl"

# -------------------------------------------------------
# initialisation
# -------------------------------------------------------

#liste qui contiendra toutes le portes (noms)
set gate  {}
set ins   {}
set outs  {}
set types {}

set wires {}

#liste des entrees/sorties du circuit  
set inputf {}
set outputf {}

#tableau des observations
array set obs {}

set all_candidats {}
set cumul_all_candidats {}
set goods {}
set state 0


set current_obs 1
set nb_obs 1
array set batch_obs {}


#par défaut, ne calcul que les candidats minimaux
set minimaux "minimaux"

#par défaut on trace les routes
set routes 1

#fichier de travail (pour les négociations avec prolog)
set working_file "current.cir"

# exemple
#CreateInputs {a b c d e f g}
#CreateGate et1 and {a b c d e f} {s1} 1 1
#CreateGate xnor xnor {s1 g} {out} 2 1
#CreateOutputs {out} 3
#wire et1 xnor s1
#LinkGates
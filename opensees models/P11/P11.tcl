wipe                               # clear memory of all past model definitions
model BasicBuilder -ndm 3 -ndf 6; # Define the model builder ndm=#dimension, ndf=#dofs# define UNITS ----------------------------------------------------------------------------
set NT 1.0; # define basic units -- output units
set mm 1.0; # define basic units -- output units
set sec 1.0; # define basic units -- output units
set kN [expr 1000.0*$NT];
set MPa [expr 1.0*$NT/pow($mm,2)];
set LunitTXT "mm"; # define basic-unit text  for output
set FunitTXT "kN"; # define basic-unit text for output
set TunitTXT "sec"; # define basic-unit text for output
set m [expr 1000.0*$mm]; # m
set mm2 [expr $mm*$mm]; # mm^2
set mm4 [expr $mm*$mm*$mm*$mm]; # mm^4
set cm [expr 100.0*$mm];
set PI [expr 2*asin(1.0)]; # define constants
set Ubig 1.e10; # a really large number
set Usmall [expr 1/$Ubig]; # a really small number
puts "define UNITS Completed"
# define GEOMETRY -------------------------------------------------------------
# define pier section geometry
set DCol [expr 2500.*$mm]; # Column Diameter
set RCol [expr $DCol/2.]; # Column Radius
set ACol [expr $PI*pow($RCol,2)]; # cross-sectional area
set IzCol [expr 1./64.*$PI*pow($DCol,4)]; # Column moment of inertia
# define steel section geometry
set coverCol [expr 90.*$mm]; # Column cover width
set coverCol2 [expr 190.*$mm];
set Rcore [expr ($RCol-$coverCol)]; # Column inner radius of column section
set Rcore2 [expr ($RCol-$coverCol2)]
set numBarsCol 80; # number of longitudinal-reinforcement bars in column. (symmetric top & bot)
set numBarsCol2 70
set diameter 32
set tdiameter 25
set radius 16
set Dbar [expr $diameter.*$mm]; # Diameter of bar
set tDbar [expr $tdiameter.*$mm];
set Rbar [expr $radius.*$mm];
set Abar [expr $PI*pow($Dbar,2)/4.0]; # area of individual bar
set tAbar [expr $PI*pow($tDbar,2)/4.0]; # area of Reduce individual bar
set CAbar [expr $numBarsCol*$Abar]; # all area of longitudinal-reinforcement bars
set CtAbar [expr $numBarsCol*$tAbar]; #all area
set gdiameter 10
set dgbar [expr $gdiameter.*$mm]
set rsteel [expr ($RCol-$coverCol-$Rbar)]
set rsteel2 [expr ($RCol-$coverCol2-$Rbar)]
puts "define GEOMETRY Completed"
node 1 0 0 0;
node 2 0 0 0;
node 3 0 150 0;
node 4 0 350 0;
node 5 0 550 0;
node 6 0 750 0;
node 7 0 950 0;
node 8 0 1100 0;
node 9 0 1300 0;
node 10 0 1660 0;
node 11 0 2000 0;
node 12 0 2500 0;
node 13 0 3000 0;
node 14 0 3500 0;
node 15 0 4000 0;
node 16 0 5000 0;
node 17 0 6000 0;
node 18 0 7000 0;
fix 1 1 1 1 1 1 1; 
equalDOF 1 2 1 3 5;
set ColTransfTag 1; # associate a tag to column transformation
set ColTransfType PDelta;
geomTransf $ColTransfType $ColTransfTag 0 0 -1;
# Define ELEMENTS & SECTIONS ----------------------------------------------------
set ColSecTag 1; # assign a tag number to the column section
set FRPR25 2; # assign a tag number to the FRP-confined column
set FRPR21 3; # assign a tag number to the FRP-confined column
set ConR25 4;
set ConR21 5;
set FRPconcrete 6;
set tFRPreinf 7;
set huayi 8;
puts "NODE Completed"
# MATERIAL parameters -----------------------------------------------------------
set IDsteel 1;
set IDFRPreinf 2; # materila ID tag -- FRP confined concrete
set IDssteel 3; # materila ID tag --steel plate
set Steelplate 4;
set IDConreinf 5;
set IDsteel2 10
set su 11
set IDZeroSteel 12
# steel-----------
set Fy [expr 397.*$MPa]; # STEEL yield stress
set Es [expr 203000.*$MPa]; # modulus of steel
set Bs 0.02; # strain-hardening ratio
set tFy [expr 455.*$MPa];
set tEs [expr 203000.*$MPa];
set tBs 0.01;
puts 22222
uniaxialMaterial Concrete02 $su -30 -0.002 -8 -0.004 0.4 3 3150;
uniaxialMaterial Concrete04 $IDConreinf -37 -0.004 -0.02 27000 3 0.00015 0.1;
uniaxialMaterial Concrete01 $IDFRPreinf -35 -1.5 -23 -5.25;
uniaxialMaterial Bond_SP01 $IDZeroSteel 397 0.9 549 36 0.5 0.5;
uniaxialMaterial Steel02 $IDsteel $Fy $Es $Bs 12 0.925 0.15; # build reinforcement material
uniaxialMaterial Steel02 $IDsteel2 $tFy $tEs $tBs 12 0.925 0.15;
puts "MATERIAL parameters"
# FIBER SECTION properties ---------------------------------------
# symmetric section
# RC section:
set nfFRPcoreC 60;
set nfFRPcoreR 60;
set nfFRPcoreR2 10;
set ZeroColSecTag 324
#--------------------------------------------------------
section Fiber $huayi -GJ [expr 1.7E14] {
patch circ $IDFRPreinf $nfFRPcoreC $nfFRPcoreR 0. 0. 0. $RCol 0. 360.;
layer circ $IDZeroSteel $numBarsCol $Abar 0. 0. $rsteel 0. [expr 360-360/$numBarsCol]
layer circ $IDZeroSteel $numBarsCol2 $Abar 0. 0. $rsteel2 0. [expr 360-360/$numBarsCol2]
}
section Fiber $ConR25 -GJ [expr 1.7E14] {
patch circ $IDConreinf $nfFRPcoreC $nfFRPcoreR 0. 0. 0 $Rcore 0. 360.;
patch circ $su $nfFRPcoreC $nfFRPcoreR2 0. 0. $Rcore $RCol 0. 360.;
layer circ $IDsteel $numBarsCol $Abar 0. 0. $rsteel 0. [expr 360-360/$numBarsCol]
layer circ $IDsteel $numBarsCol2 $Abar 0. 0. $rsteel2 0. [expr 360-360/$numBarsCol2]
}
set numIntgrPts 4; # number of integration points for force-based element
element zeroLengthSection 1 1 2 $huayi -orient  0 1 0 1 0 0;
element dispBeamColumn 2 2 3 $numIntgrPts $ConR25 $ColTransfTag;
element dispBeamColumn 3 3 4 $numIntgrPts $ConR25 $ColTransfTag;
element dispBeamColumn 4 4 5 $numIntgrPts $ConR25 $ColTransfTag;
element dispBeamColumn 5 5 6 $numIntgrPts $ConR25 $ColTransfTag;
element dispBeamColumn 6 6 7 $numIntgrPts $ConR25 $ColTransfTag;
element dispBeamColumn 7 7 8 $numIntgrPts $ConR25 $ColTransfTag;
element dispBeamColumn 8 8 9 $numIntgrPts $ConR25 $ColTransfTag;
element dispBeamColumn 9 9 10 $numIntgrPts $ConR25 $ColTransfTag;
element dispBeamColumn 10 10 11 $numIntgrPts $ConR25 $ColTransfTag;
element dispBeamColumn 11 11 12 $numIntgrPts $ConR25 $ColTransfTag;
element dispBeamColumn 12 12 13 $numIntgrPts $ConR25 $ColTransfTag;
element dispBeamColumn 13 13 14 $numIntgrPts $ConR25 $ColTransfTag;
element dispBeamColumn 14 14 15 $numIntgrPts $ConR25 $ColTransfTag;
element dispBeamColumn 15 15 16 $numIntgrPts $ConR25 $ColTransfTag;
element dispBeamColumn 16 16 17 $numIntgrPts $ConR25 $ColTransfTag;
element dispBeamColumn 17 17 18 $numIntgrPts $ConR25 $ColTransfTag;
# self-explanatory when using variables
# Define RECORDERS -------------------------------------------------------------
recorder Node -file nodetop-disp.txt -time -node 18 -dof 1 disp
recorder Node -file nodebase-force.txt -time -node 2 -dof 1 reaction
# define GRAVITY -------------------------------------------------------------
pattern Plain 1 Linear {
load 18 0 -9576000 0 0 0 0
};
set Tol 1.0e-8; 
constraints Transformation; 
numberer Plain; 
system BandGeneral; 
test NormDispIncr $Tol 6 0; 
algorithm Newton; 
set NstepGravity 10; 
set DGravity [expr 1./$NstepGravity]; 
integrator LoadControl $DGravity; 
analysis Static; 
analyze $NstepGravity; 
loadConst -time 0.0
puts "Model Built Completed"
puts "pushover"
## Load Case = PUSH
pattern Plain 2 Linear {
load 18 1 0 0 0 0 0
}
puts "analysis"
constraints Transformation 
numberer RCM
system BandGeneral
test NormDispIncr 1.0e-6 200
algorithm KrylovNewton
analysis Static
integrator	DisplacementControl	18	1	-0.3498
analyze	100
integrator	DisplacementControl	18	1	1.0398
analyze	100
integrator	DisplacementControl	18	1	-1.6098
analyze	100
integrator	DisplacementControl	18	1	1.4496
analyze	100
integrator	DisplacementControl	18	1	-1.44
analyze	100
integrator	DisplacementControl	18	1	1.77
analyze	100
integrator	DisplacementControl	18	1	-1.59
analyze	100
integrator	DisplacementControl	18	1	1.47
analyze	100
integrator	DisplacementControl	18	1	-1.5498
analyze	100
integrator	DisplacementControl	18	1	1.3302
analyze	100
integrator	DisplacementControl	18	1	-1.0704
analyze	100
integrator	DisplacementControl	18	1	0.8604
analyze	100
integrator	DisplacementControl	18	1	-0.7302
analyze	100
integrator	DisplacementControl	18	1	0.72
analyze	100
integrator	DisplacementControl	18	1	-0.6702
analyze	100
integrator	DisplacementControl	18	1	0.7602
analyze	100
integrator	DisplacementControl	18	1	-0.57
analyze	100
integrator	DisplacementControl	18	1	0.18
analyze	100
integrator	DisplacementControl	18	1	-0.7698
analyze	100
integrator	DisplacementControl	18	1	2.1696
analyze	100
integrator	DisplacementControl	18	1	-2.8896
analyze	100
integrator	DisplacementControl	18	1	2.5698
analyze	100
integrator	DisplacementControl	18	1	-3.2598
analyze	100
integrator	DisplacementControl	18	1	3.18
analyze	100
integrator	DisplacementControl	18	1	-3.1104
analyze	100
integrator	DisplacementControl	18	1	3.9504
analyze	100
integrator	DisplacementControl	18	1	-3.5604
analyze	100
integrator	DisplacementControl	18	1	2.8902
analyze	100
integrator	DisplacementControl	18	1	-2.5398
analyze	100
integrator	DisplacementControl	18	1	2.25
analyze	100
integrator	DisplacementControl	18	1	-1.89
analyze	100
integrator	DisplacementControl	18	1	1.8798
analyze	100
integrator	DisplacementControl	18	1	-1.0602
analyze	100
integrator	DisplacementControl	18	1	0.1902
analyze	100

puts "Bravo!"

function cgirComp = getWireComp( hN, hInSignals, hOutSignals, compName,  ...
desc, slHandle, ~ )


if nargin < 4
compName = [ hInSignals( 1 ).Name, '_wire' ];
end 

if nargin < 5
desc = '';
end 

if nargin < 6
slHandle =  - 1;
end 

hInT = hInSignals.Type;
hOutT = hOutSignals.Type;
isScalar = ~hOutT.isArrayType || ~hInT.isArrayType;

if isScalar ||  ...
( numel( hOutT.Dimensions ) == numel( hInT.Dimensions ) &&  ...
all( hOutT.Dimensions == hInT.Dimensions ) )


cgirComp = pircore.getWireComp( hN, hInSignals, hOutSignals, compName, desc, slHandle );
else 
assert( prod( hInT.Dimensions ) == prod( hOutT.Dimensions ),  ...
'Inputs and outputs to a wirecomp must have the same number of elements' );




cgirComp = pirelab.getReshapeComp( hN, hInSignals, hOutSignals );
end 
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpyZPZKv.p.
% Please follow local copyright laws when handling this file.


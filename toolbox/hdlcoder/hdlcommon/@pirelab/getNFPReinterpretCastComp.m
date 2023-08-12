function cgirComp = getNFPReinterpretCastComp( hN, hInSignals, hOutSignals, compName, desc, slHandle )



if ( nargin < 5 )
compName = [ hInSignals( 1 ).Name, '_wire' ];
end 

if ( nargin < 6 )
desc = '';
end 

if ( nargin < 7 )
slHandle =  - 1;
end 

cgirComp = pircore.getNFPReinterpretCastComp( hN, hInSignals, hOutSignals, compName, desc, slHandle );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpXq_EAy.p.
% Please follow local copyright laws when handling this file.


function unaryMinusComp = getUnaryMinusComp( hN, hInSignals, hOutSignals, satMode, compName )



if ( nargin < 5 )
compName = 'uminus';
end 

if ( nargin < 4 )
satMode = 'Wrap';
end 

unaryMinusComp = pircore.getUnaryMinusComp( hN, hInSignals, hOutSignals, satMode, compName );

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpA7U3K9.p.
% Please follow local copyright laws when handling this file.


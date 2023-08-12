function nilComp = getNilComp( hN, hInSignals, hOutSignals, compName, desc, slHandle )



if ( nargin < 6 )
slHandle =  - 1;
end 

if ( nargin < 5 )
desc = '';
end 

if ( nargin < 4 )
compName = 'nil';
end 

if ( nargin < 3 )
hOutSignals = [  ];
end 

if ( nargin < 2 )
hInSignals = [  ];
end 

nilComp = pircore.getNilComp( hN, hInSignals, hOutSignals, compName, desc, slHandle );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpYk4qoz.p.
% Please follow local copyright laws when handling this file.


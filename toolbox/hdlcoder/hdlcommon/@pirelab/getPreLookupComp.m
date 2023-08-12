function cgirComp = getPreLookupComp( hN, hInSignals, hOutSignals,  ...
bp_data, bpType, kType, fType, idxOnly, powerof2, compName, slbh, diagnostics )









if ( nargin < 10 )
compName = 'PreLookup';
end 

if ( nargin < 11 || isempty( slbh ) )
slbh =  - 1;
end 

if ( nargin < 12 )
diagnostics = 'Error';
end 

cgirComp = pircore.getPreLookupComp( hN, hInSignals, hOutSignals,  ...
bp_data, bpType, kType, fType, idxOnly, powerof2, compName, slbh, diagnostics );

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpT7y7os.p.
% Please follow local copyright laws when handling this file.


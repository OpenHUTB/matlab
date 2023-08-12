function [ varList, firstChangedVar ] = getChangedGlobalVariablesFromChecksums( vars, origChecksums, curChecksums )





if length( curChecksums ) > 1









mismatch = any( origChecksums ~= curChecksums, 2 );


globalVarCell = textscan( vars, '%s', 'delimiter', ',' );


globalVarCell = globalVarCell{ 1 }( mismatch );



varList = strjoin( globalVarCell, ', ' );
firstChangedVar = globalVarCell{ 1 };
else 
varList = vars;
firstChangedVar = vars;
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpRzzYo4.p.
% Please follow local copyright laws when handling this file.


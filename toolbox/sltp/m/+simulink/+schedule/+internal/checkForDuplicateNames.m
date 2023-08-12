function duplicateNames = checkForDuplicateNames( names )



R36
names( :, 1 )string
end 

[ ~, ia, ~ ] = unique( names );
duplicates = setdiff( 1:length( names ), ia );
if ~isempty( duplicates )

duplicateNames = string( unique( names( duplicates ) ) );
else 
duplicateNames = strings( 0 );
end 
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpwdmrk1.p.
% Please follow local copyright laws when handling this file.


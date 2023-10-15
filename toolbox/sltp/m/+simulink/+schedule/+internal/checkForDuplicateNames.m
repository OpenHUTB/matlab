function duplicateNames = checkForDuplicateNames( names )

arguments
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


function varNames = pmsl_blocknametovarname( blockNames, reservedNames )















narginchk( 1, 2 );




modifiedCandidateNames = regexprep( blockNames, '//+', '' );




modifiedCandidateNames = strrep( modifiedCandidateNames, '/', '_' );
if ( nargin == 1 )
reservedNames = '';
end 
varNames = lGenVarName( modifiedCandidateNames, reservedNames );

end 

function varNames = lGenVarName( candidateNames, reservedNames )












narginchk( 1, 2 );




modifiedCandidateNames = regexprep( candidateNames, '\W', '' );
if ( nargin == 1 )
reservedNames = '';
end 
varNames = genvarname( modifiedCandidateNames, reservedNames );



end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpQl6CxC.p.
% Please follow local copyright laws when handling this file.


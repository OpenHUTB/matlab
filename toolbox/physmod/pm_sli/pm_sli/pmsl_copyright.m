function crString = pmsl_copyright( startYear )







narginchk( 1, 1 );

clockRet = clock;
endYear = clockRet( 1 );

if startYear == endYear
crString = sprintf( 'Copyright %d The MathWorks, Inc.', startYear );
else 
crString = sprintf( 'Copyright %d-%d The MathWorks, Inc.', startYear, endYear );
end 

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpqZyTsc.p.
% Please follow local copyright laws when handling this file.


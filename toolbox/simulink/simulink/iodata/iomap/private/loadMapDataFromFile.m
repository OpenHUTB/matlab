function loadMapDataFromFile( inputMap, dataOnSource, varNameMapped )








if ~isempty( inputMap )


emptyIdx = cellfun( @isempty, varNameMapped );


if any( emptyIdx )

varNameMapped( emptyIdx ) = [  ];
end 


for k = 1:length( varNameMapped )


idxMatch = strcmp( varNameMapped{ k }, dataOnSource.Names );
var = dataOnSource.Data{ idxMatch };
assignin( 'base', varNameMapped{ k }, var );

end 

end 


end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpyZ8Rs4.p.
% Please follow local copyright laws when handling this file.


function validateSignalName( signalName )




if isstring( signalName )
if isscalar( signalName )
signalName = char( signalName );
else 
signalName = cellstr( signalName );
end 
end 

if ( ~ischar( signalName ) && ( ~lIsExpectedCellArray( signalName ) && ( ~( isempty( signalName ) && isnumeric( signalName ) ) ) ) )
DAStudio.error( 'sl_inputmap:inputmap:inportMapSignalNameValue' );
end 



function bool = lIsExpectedCellArray( aCell )



bool = false;


if iscell( aCell ) && ~isempty( aCell )


for k = 1:length( aCell )

if ~ischar( aCell{ k } ) && ~isempty( aCell{ k } )
return ;
end 
end 

bool = true;
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmp9lWz5L.p.
% Please follow local copyright laws when handling this file.


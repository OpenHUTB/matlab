function [ final, varargout ] = findif( iCellArray, iHook )






























































CheckCA( iCellArray, '1st' );
CheckCA( iHook, '2nd' );
CheckFunc( iHook{ 1 } );

out = {  };
final = {  };
i = 1;

while isempty( final ) && i <= length( iCellArray )

if nargout > 1
[ final, out{ i, 1:nargout - 1 } ] = feval( iHook{ : }, iCellArray{ i } );
else 
final = feval( iHook{ : }, iCellArray{ i } );
end 

i = i + 1;

end 






dim = size( iCellArray );
dim( dim > 1 ) = i - 1;
for j = 1:nargout - 1
varargout{ j } = reshape( { out{ :, j } }, dim( 1 ), dim( 2 ) );
end 



function CheckFunc( f )

if ~isa( f, 'function_handle' ) && ~ischar( f )
DAStudio.error( 'Simulink:utility:argTypeMustBeFcnHandleOrChar', class( f ) );
end 


function CheckCA( iCA, iNth )

if ~iscell( iCA )
DAStudio.error( 'Simulink:utility:argTypeMustBeCell', iNth, class( iCA ) );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp6uPSbN.p.
% Please follow local copyright laws when handling this file.


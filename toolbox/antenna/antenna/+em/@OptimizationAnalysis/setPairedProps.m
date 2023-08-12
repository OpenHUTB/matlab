function setPairedProps( obj, nameObjectCell )







R36
obj( 1, 1 ){ mustBeNonempty }
nameObjectCell( 1, : )cell{ mustBeNonempty, mustSatisfy( nameObjectCell ) }
end 
obj.OptimStruct.PairedProps = nameObjectCell;
end 


function mustSatisfy( input )

names = input( 1:2:end  );
objects = input( 2:2:end  );
for i = 1:length( names )
if ~( ischar( names{ i } ) ||  ...
isstring( names{ i } ) )
eid = 'Class:notCorrectClass';
msg = 'Input must be of class char or string';
throwAsCaller( MException( eid, msg ) )
end 
end 
for i = 1:length( objects )
if ~( isstruct( objects{ i } ) || isobject( objects{ i } ) )
eid = 'Class:notCorrectClass';
msg = 'Input must be of class struct or object';
throwAsCaller( MException( eid, msg ) )
end 
end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpFIIHsV.p.
% Please follow local copyright laws when handling this file.


function setPairedProps( obj, nameObjectCell )

arguments
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




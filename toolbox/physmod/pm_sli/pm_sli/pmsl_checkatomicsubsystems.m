function out = pmsl_checkatomicsubsystems( blocks )


















blocks = lGetHandle( blocks );
parents = blocks;
types = lGetTypes( parents );




while ~isempty( find( types == 1, 1 ) )
[ parents, types ] = lUpdateParents( parents, types );
end 




atomicSubsystemsIdx = types == 2;
atomicSubsystems = parents( atomicSubsystemsIdx );




uniqueSystems = unique( atomicSubsystems );
if ( isempty( uniqueSystems ) ||  ...
numel( uniqueSystems ) == 1 &&  ...
numel( atomicSubsystems ) == numel( parents ) )
out = [  ];
else 
out = blocks( atomicSubsystemsIdx );
end 

end 

function [ parents, types ] = lUpdateParents( parents, types )



blocks = types == 1;
parents( blocks ) = lGetHandle( get_param( parents( blocks ), 'Parent' ) );
types( blocks ) = lGetTypes( parents( blocks ) );

end 

function types = lGetTypes( objects )





types = zeros( size( objects ) );
typesStr = get_param( objects, 'Type' );

types( strcmp( typesStr, 'block_diagram' ) ) = 3;

blockIdx = find( strcmp( typesStr, 'block' ) );
types( blockIdx ) = 1;

isSubsystem =  ...
strcmp( get_param( objects( blockIdx ), 'BlockType' ), 'SubSystem' );

isAtomic = false( size( blockIdx ) );
isAtomic( isSubsystem ) = strcmp(  ...
get_param( objects( blockIdx( isSubsystem ) ), 'TreatAsAtomicUnit' ),  ...
'on' );
types( blockIdx( isAtomic ) ) = 2;

end 

function handles = lGetHandle( objects )



handles = get_param( objects, 'Handle' );
if iscell( handles )
handles = cell2mat( handles );
end 

end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpcur43p.p.
% Please follow local copyright laws when handling this file.


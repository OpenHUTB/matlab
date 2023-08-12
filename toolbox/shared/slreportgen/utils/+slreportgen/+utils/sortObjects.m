function sortedList = sortObjects( inList, sortByOption )


























R36
inList
sortByOption string ...
{ matlab.system.mustBeMember( sortByOption,  ...
[ "alphabetical", "systemAlpha", "depth", "none" ] ) } = "alphabetical"
end 

sortedList = inList;
if isempty( inList )
return ;
end 

if isa( inList, "mlreportgen.finder.Result" )
objList = { inList.Object };
else 
objList = inList;
end 

switch lower( sortByOption )
case "alphabetical"

[ nameList, badIdx ] = mlreportgen.utils.safeGet( objList, 'name' );
if ~isempty( badIdx )


[ nameListGetParam, badIdxGetParam ] = mlreportgen.utils.safeGet( objList( badIdx ), "name", "get_param" );
nameList( badIdx ) = nameListGetParam;
badIdx = badIdx( badIdxGetParam );
end 
nameList( badIdx ) = [  ];
inList( badIdx ) = [  ];

[ ~, sortIdx ] = sort( lower( nameList ) );
case "systemalpha"

[ parentsList, badIdx ] = mlreportgen.utils.safeGet( objList, "parent", "get_param" );
if ~isempty( badIdx )

[ sfParents, sfBadIdx ] = mlreportgen.utils.safeGet( objList( badIdx ), "Path" );
parentsList( badIdx ) = sfParents;
badIdx = badIdx( sfBadIdx );
end 
parentsList( badIdx ) = [  ];
inList( badIdx ) = [  ];


emptyParentsIdx = cellfun( @isempty, parentsList );
parentsList( emptyParentsIdx ) = { '' };


blockTypes = mlreportgen.utils.safeGet( parentsList, "blocktype", "get_param" );
blockIdx = ~ismember( blockTypes, [ "SubSystem", "N/A" ] );
blockParents = mlreportgen.utils.safeGet( parentsList( blockIdx ), "Parent", "get_param" );
parentsList( blockIdx ) = blockParents;


parentNames = mlreportgen.utils.safeGet( parentsList, "name", "get_param" );
parentNames( emptyParentsIdx ) = { '' };


[ ~, sortIdx ] = sort( lower( parentNames ) );
case "depth"

depthList = getDepth( objList );

okEntries = depthList >= 0;
depthList = depthList( okEntries );
inList = inList( okEntries );

[ ~, sortIdx ] = sort( depthList );
otherwise 

sortIdx = 1:numel( objList );
end 
sortedList = inList( sortIdx );
sortedList = sortedList( : );
end 

function value = getDepth( objList )
if iscell( objList )
subsrefType = '{}';
elseif ischar( objList )
objList = { objList };
subsrefType = '{}';
else 
subsrefType = '()';
end 

value = [  ];
for i = length( objList ): - 1:1
depth =  - 1;
parent = subsref( objList, substruct( subsrefType, { i } ) );
if isa( parent, "Stateflow.Object" )
while ~isempty( parent ) && ~isa( parent, "Simulink.BlockDiagram" )
try 
parent = parent.up;
depth = depth + 1;
catch ex %#ok<NASGU>
parent = [  ];
end 
end 
else 
while ~isempty( parent )
try 
parent = get_param( parent, "Parent" );
depth = depth + 1;
catch ex %#ok<NASGU>
parent = [  ];
end 
end 
end 
value( i, 1 ) = depth;
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpliWTEw.p.
% Please follow local copyright laws when handling this file.


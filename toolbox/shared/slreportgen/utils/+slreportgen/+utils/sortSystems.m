function sortedList = sortSystems( inList, sortByOption )



























R36
inList
sortByOption string{ matlab.system.mustBeMember( sortByOption,  ...
[ "alphabetical", "systemAlpha", "numBlocks", "depth", "none" ] ) } = "alphabetical"
end 

sortedList = inList;
if isempty( inList )
return ;
end 

if isa( inList, "mlreportgen.finder.Result" )


sList = { inList.Object };
else 
sList = inList;
end 

switch lower( sortByOption )
case { "numblocks", "blocks" }

sfIdx = cellfun( @( x )isa( x, "Stateflow.Object" ), sList );
sfPaths = mlreportgen.utils.safeGet( sList( sfIdx ), "Path" );
sList( sfIdx ) = sfPaths;


[ blockList, badIdx ] = mlreportgen.utils.safeGet( sList, 'blocks', 'get_param' );
blockList( badIdx ) = [  ];
inList( badIdx ) = [  ];

blockList = cellfun( 'length', blockList );
[ ~, sortIndex ] = sort( blockList );
inList = inList( sortIndex( end : - 1:1 ) );
case "systemalpha"

inList = slreportgen.utils.sortObjects( inList, "alphabetical" );
case { "alphabetical", "depth" }

inList = slreportgen.utils.sortObjects( inList, sortByOption );
otherwise 

end 
sortedList = inList( : );

end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpderuoQ.p.
% Please follow local copyright laws when handling this file.


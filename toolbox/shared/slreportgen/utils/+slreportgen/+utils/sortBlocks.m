function sortedList = sortBlocks( inList, sortByOption )

arguments
    inList
    sortByOption string{ matlab.system.mustBeMember( sortByOption,  ...
        [ "alphabetical", "systemAlpha", "fullPathAlpha", "blockType",  ...
        "depth", "leftToRight", "topToBottom", "runtime", "none" ] ) } = "alphabetical"
end

if isempty( inList )
    sortedList = inList;
    return ;
end

if isa( inList, "mlreportgen.finder.Result" )
    bList = { inList.Object };
else
    bList = inList;
    if ~iscell( bList )
        bList = num2cell( bList );
    end
end


sfIdx = cellfun( @( x )isa( x, "Stateflow.Object" ), bList );
sfPaths = mlreportgen.utils.safeGet( bList( sfIdx ), "Path" );
bList( sfIdx ) = sfPaths;

switch lower( sortByOption )
    case { "alphabetical", "systemalpha", "depth" }
        sortedList = slreportgen.utils.sortObjects( inList, sortByOption );
    case "fullpathalpha"

        [ ~, badIdx ] = mlreportgen.utils.safeGet( bList, 'blocktype', 'get_param' );
        bList( badIdx ) = [  ];
        inList( badIdx ) = [  ];

        [ ~, nameIndex ] = sort( lower( getfullname( bList ) ) );
        sortedList = inList( nameIndex );
    case "blocktype"

        [ typeList, badIdx ] = mlreportgen.utils.safeGet( bList, 'blocktype', 'get_param' );
        typeList( badIdx ) = [  ];
        inList( badIdx ) = [  ];

        [ ~, typeIndex ] = sort( lower( typeList ) );
        sortedList = inList( typeIndex );
    case "lefttoright"
        [ sortIdx, badIdx ] = locSortByPosition( bList, "lefttoright" );
        inList( badIdx ) = [  ];
        sortedList = inList( sortIdx );
    case "toptobottom"
        [ sortIdx, badIdx ] = locSortByPosition( bList, "toptobottom" );
        inList( badIdx ) = [  ];
        sortedList = inList( sortIdx );
    case "runtime"

        [ blkHandles, badIdx ] = mlreportgen.utils.safeGet( bList, 'handle', 'get_param' );
        blkHandles( badIdx ) = [  ];
        inList( badIdx ) = [  ];
        blkHandles = [ blkHandles{ : } ];


        parentSys = get_param( blkHandles( 1 ), "Parent" );
        while ~strcmp( get_param( parentSys, "type" ), "block_diagram" ) ...
                && strcmp( get_param( parentSys, "Virtual" ), "on" )
            parentSys = get_param( parentSys, "Parent" );
        end


        taskSortedBlks = {  };
        sortedTasks = slreportgen.utils.internal.getTaskSortedLists( parentSys );

        nTasks = numel( sortedTasks );
        for taskIdx = 1:nTasks
            task = sortedTasks( taskIdx );



            taskSortedBlks = [ taskSortedBlks, { task.SortedBlocks.BlockPath } ];%#ok<AGROW>
        end

        blkPaths = mlreportgen.utils.normalizeString( string( getfullname( blkHandles ) ) );
        [ ~, ~, sortedBlksIdx ] = intersect( taskSortedBlks, blkPaths, "stable" );
        sortedList = inList( sortedBlksIdx );


        inList( sortedBlksIdx ) = [  ];
        if ~isempty( inList )
            warning( message( "slreportgen:utils:warning:unsortedBlocksRuntime" ) )
            sortedList = [ sortedList( : );inList( : ) ];
        end
    otherwise
        sortedList = inList;

end
sortedList = sortedList( : );

end

















function [ sortIdx, badIdx ] = locSortByPosition( bList, type )


if ( strcmpi( type, 'lefttoright' ) || strcmpi( type, 'ltr' ) )
    majorValue = 1;
    minorValue = 2;
else
    majorValue = 2;
    minorValue = 1;
end

[ allPositions, badIdx ] = mlreportgen.utils.safeGet( bList, 'Position', 'get_param' );
allPositions( badIdx ) = [  ];





newPositions = zeros( length( allPositions ), 3 );


newPositions( :, 1 ) = cellfun( @( x )x( majorValue ), allPositions );



newPositions( :, 2 ) = locCreatePartition( allPositions, minorValue );


minVal = min( [ newPositions( :, 1 );newPositions( :, 2 ) ] );
if minVal < 0
    newPositions = newPositions + minVal *  - 1;
end




maxMajorVal = max( newPositions( :, 1 ) );
newPositions( :, 3 ) = maxMajorVal * newPositions( :, 2 ) + newPositions( :, 1 );


[ ~, sortIdx ] = sort( newPositions( :, 3 ) );
end












function newPositions = locCreatePartition( allPositions, partitionAxis )









partition = [  ];
positionMap = zeros( length( allPositions ), 1 );
numPartitions = 0;



avgSize = mean( cellfun( @( x )x( partitionAxis + 2 ) - x( partitionAxis ), allPositions ) );


for i = 1:length( allPositions )


    curPosMin = allPositions{ i }( partitionAxis );
    curPosMax = curPosMin + avgSize;


    for j = 1:numPartitions

        partitionMin = partition( j, 1 );
        partitionMax = partition( j, 2 );



        if ( ( curPosMin >= partitionMin && curPosMin <= partitionMax ) ||  ...
                ( curPosMax >= partitionMin && curPosMax <= partitionMax ) ||  ...
                ( partitionMin >= curPosMin && partitionMin <= curPosMax ) ||  ...
                ( partitionMax >= curPosMin && partitionMax <= curPosMax ) )


            positionMap( i ) = j;


            partition( j, 1 ) = min( partitionMin, curPosMin );%#ok<AGROW>
            partition( j, 2 ) = max( partitionMax, curPosMax );%#ok<AGROW>

            break ;
        end
    end


    if ( positionMap( i ) <= 0 )

        numPartitions = numPartitions + 1;
        positionMap( i ) = numPartitions;
        partition( numPartitions, : ) = [ curPosMin, curPosMax ];%#ok - This is not growing at a


    end
end

newPositions = partition( positionMap, 1 );

end

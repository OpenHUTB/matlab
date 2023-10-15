classdef ExecutionOrder < slreportgen.report.Reporter




































































































    properties




        Object{ mlreportgen.report.validators.mustBeInstanceOfMultiClass(  ...
            { 'numeric', 'slreportgen.finder.DiagramResult', 'slreportgen.finder.BlockResult', 'string', 'char' },  ...
            Object ) };








        ShowTaskDetails( 1, 1 )logical = true;















        ShowBlockExecutionOrder( 1, 1 )logical = true;

















        TaskProperties{ mlreportgen.report.validators.mustBeVectorOf( [ "string", "char" ], TaskProperties ) } = [ "Order", "Name", "Type", "Trigger", "TaskID", "SourceBlock" ];








        ShowEmptyColumns( 1, 1 )logical = false;








        ShowBlockType( 1, 1 )logical = true;











        ShowHiddenBlocks( 1, 1 )logical = true;












        IncludeSubsystemBlocks( 1, 1 )logical = true;















        SubsystemBlocksDisplayPolicy = "Link";




































        TaskFilterFcn = [  ];












        TableReporter








        ListFormatter
    end

    properties ( Access = public, Hidden )

        ObjectPath = [  ];



        HashLinkIDs = true;
    end

    properties ( Access = private )

        ObjectHandle = [  ];


        SortedLists = [  ];







        SLFunctionKey =  - 1;


        SimulinkFunctionsInfo;
        SimulinkFunctionBlockNames;
    end

    methods
        function this = ExecutionOrder( varargin )

            if nargin == 1
                varObj = varargin{ 1 };
                varargin = { "Object", varObj };
            end

            this = this@slreportgen.report.Reporter( varargin{ : } );


            p = inputParser;




            p.KeepUnmatched = true;




            addParameter( p, "TemplateName", "ExecutionOrder" );

            ol = mlreportgen.dom.OrderedList;
            ol.StyleName = "ExecutionOrderList";
            addParameter( p, "ListFormatter", ol );


            tbl = mlreportgen.report.BaseTable(  );
            tbl.TableStyleName = "ExecutionOrderTable";
            addParameter( p, "TableReporter", tbl );


            parse( p, varargin{ : } );


            results = p.Results;
            this.TemplateName = results.TemplateName;
            this.ListFormatter = results.ListFormatter;
            this.TableReporter = results.TableReporter;
        end

        function impl = getImpl( this, rpt )
            arguments
                this( 1, 1 )
                rpt( 1, 1 ){ validateReport( this, rpt ) }
            end

            if ~rpt.CompileModelBeforeReporting


                warning( message( "slreportgen:report:warning:executionOrderNotCompiled" ) );
                impl = [  ];
            elseif isempty( this.Object )

                error( message( "slreportgen:report:error:noSourceObjectSpecified", class( this ) ) );
            else

                resolveObject( this );
                objHandle = this.ObjectHandle;


                if ~isempty( this.ListFormatter.Children )
                    error( message( "slreportgen:report:error:nonemptyListFormatter" ) );
                end


                if isempty( this.LinkTarget )
                    this.LinkTarget = slreportgen.report.ExecutionOrder.getLinkTargetID(  ...
                        objHandle, "Hash", this.HashLinkIDs );
                end


                modelH = slreportgen.utils.getModelHandle( objHandle );
                compileModel( rpt, modelH );


                prepareTaskData( this, rpt, objHandle, modelH );

                impl = getImpl@slreportgen.report.Reporter( this, rpt );
            end
        end

        function set.SubsystemBlocksDisplayPolicy( this, value )


            mustBeNonempty( value );

            mlreportgen.report.validators.mustBeString( value );

            mustBeMember( lower( value ), [ "link", "nestedlist" ] );

            this.SubsystemBlocksDisplayPolicy = value;
        end

        function set.TableReporter( this, value )

            mustBeNonempty( value );

            mlreportgen.report.validators.mustBeInstanceOf( "mlreportgen.report.BaseTable", value );

            this.TableReporter = value;
        end

        function set.ListFormatter( this, value )


            mustBeNonempty( value );

            mlreportgen.report.validators.mustBeInstanceOfMultiClass(  ...
                { 'mlreportgen.dom.UnorderedList', 'mlreportgen.dom.OrderedList' }, value )


            if ~isempty( value.Children )
                error( message( "slreportgen:report:error:nonemptyListFormatter" ) );
            end

            this.ListFormatter = value;
        end
    end


    methods ( Access = { ?mlreportgen.report.ReportForm } )

        function content = getTasksContent( this, rpt )


            content = {  };
            if this.ShowTaskDetails

                tasks = this.SortedLists;


                propNames = this.TaskProperties;
                nProps = numel( propNames );


                nTasks = numel( tasks );
                tableData = cell( nTasks, nProps );
                for taskIdx = 1:nTasks
                    currTask = tasks( taskIdx );
                    taskName = currTask.TaskName;


                    for propIdx = 1:nProps
                        prop = propNames{ propIdx };
                        switch prop
                            case "Order"


                                if currTask.IsScheduleTask
                                    data = taskIdx;
                                else
                                    data = "N/A";
                                end
                            case "Name"


                                if this.ShowBlockExecutionOrder
                                    linkID = getBlockListLinkTargetID( this, this.ObjectHandle, taskName );
                                    data = mlreportgen.dom.InternalLink( linkID, taskName );
                                else
                                    data = taskName;
                                end
                            case "TaskID"
                                data = "TID" + string( currTask.TaskIndex );
                            case "SourceBlock"
                                data = makeSourceBlockDOM( currTask.SourceBlock );
                            case { "Type", "Trigger" }
                                data = currTask.( prop );
                            otherwise
                                data = [  ];
                        end
                        tableData{ taskIdx, propIdx } = data;
                    end

                end

                if ~isempty( tableData )

                    if ~this.ShowEmptyColumns
                        empty = cellfun( @( x )isempty( x ) || isstring( x ) && isscalar( x ) && ( x == "" ), tableData );
                        emptyCols = all( empty, 1 );
                        tableData( :, emptyCols ) = [  ];
                        propNames( emptyCols ) = [  ];
                    end

                    tbl = copy( this.TableReporter );
                    ft = mlreportgen.dom.FormalTable( propNames, tableData );

                    if rpt.isdocx
                        setSourceBlockColWidth( ft, propNames, tbl );
                    end

                    tbl.Content = ft;


                    tbl.LinkTarget = getTaskDetailsLinkTargetID( this );
                    tbl.appendTitle( getString( message( "slreportgen:report:ExecutionOrder:tasks" ) ) );

                    content = tbl;
                end
            end
        end

        function content = getBlockListsContent( this, ~ )


            content = {  };


            tasks = this.SortedLists;
            nTasks = numel( tasks );
            if this.ShowBlockExecutionOrder && ( nTasks > 0 )
                label = mlreportgen.dom.Paragraph( getString( message( "slreportgen:report:ExecutionOrder:blockExecutionOrder" ) ) );
                label.StyleName = "ExecutionOrderLabel";


                content = cell.empty( 0, nTasks * 3 + 1 );
                content{ 1 } = label;
                contentIdx = 2;

                for idx = 1:nTasks
                    task = tasks( idx );



                    taskLabel = mlreportgen.dom.Text( task.TaskName );
                    taskLabel.Bold = true;
                    if this.ShowTaskDetails
                        taskLabel = mlreportgen.dom.InternalLink( getTaskDetailsLinkTargetID( this ), taskLabel );
                    end



                    taskLinkTarget = mlreportgen.dom.LinkTarget(  ...
                        getBlockListLinkTargetID( this, this.ObjectHandle, task.TaskName ) );


                    triggerMap = containers.Map( 'KeyType', 'double', 'ValueType', 'any' );


                    this.SimulinkFunctionsInfo = slreportgen.utils.internal.getSimulinkFunctions( bdroot( this.ObjectPath ) );
                    if ~isempty( this.SimulinkFunctionsInfo )

                        this.SimulinkFunctionBlockNames = string( { this.SimulinkFunctionsInfo.FunctionBlock } );

                        callerBlkNames = unique( [ this.SimulinkFunctionsInfo.CallerBlocks ] );
                        if isempty( callerBlkNames )
                            callerBlkMap = containers.Map(  );
                        else
                            callerBlkMap = containers.Map( callerBlkNames, zeros( numel( callerBlkNames ), 1 ) - 1, 'UniformValues', false );
                        end
                    else
                        callerBlkMap = containers.Map(  );
                    end


                    blockListDOM = createTaskBlockList( this, task, this.ObjectPath, triggerMap, callerBlkMap );


                    if ~this.ShowHiddenBlocks && isempty( blockListDOM )
                        msgString = getString( message( "slreportgen:report:ExecutionOrder:onlyHiddenBlocks" ) );
                        blockListDOM = mlreportgen.dom.Paragraph( "(" + msgString + ")" );
                    end

                    content( contentIdx:contentIdx + 2 ) = { taskLinkTarget, taskLabel, blockListDOM };
                    contentIdx = contentIdx + 3;

                    condTable = createConditionalExecutionTable( this, task, triggerMap, callerBlkMap );
                    if ~isempty( condTable )
                        content( contentIdx ) = { condTable };
                        contentIdx = contentIdx + 1;
                    end
                end
            end
        end
    end

    methods ( Access = protected, Hidden )

        result = openImpl( reporter, impl, varargin );
    end

    methods ( Access = private )
        function resolveObject( this )



            try
                objHandle = slreportgen.utils.getSlSfHandle( this.Object );
                if ~isnumeric( objHandle )


                    objHandle = slreportgen.utils.getSlSfHandle( objHandle.Path );
                end
            catch
                error( message( "slreportgen:report:error:invalidNonVirtualSystem" ) );
            end

            if ~slreportgen.utils.isModel( objHandle )
                isVirtual = mlreportgen.utils.safeGet( objHandle, 'IsSubsystemVirtual' );
                if ~strcmpi( isVirtual, "off" )
                    error( message( "slreportgen:report:error:invalidNonVirtualSystem" ) );
                end
            end
            this.ObjectHandle = objHandle;
            this.ObjectPath = getfullname( objHandle );
        end

        function prepareTaskData( this, rpt, objectH, modelH )






            schedMap = getContext( rpt, "ScheduleMap" );
            if isempty( schedMap )
                schedMap = containers.Map( 'KeyType', 'double', 'ValueType', 'any' );
            end
            if isKey( schedMap, modelH )

                eoTable = schedMap( modelH );
                sortedTaskList = slreportgen.utils.internal.getTaskSortedLists( objectH, eoTable );
            else

                [ sortedTaskList, eoTable ] = slreportgen.utils.internal.getTaskSortedLists( objectH );
                schedMap( modelH ) = eoTable;
                setContext( rpt, "ScheduleMap", schedMap );
            end


            filteredIdx = arrayfun(  ...
                @( task )isFilteredTask( this.TaskFilterFcn, task.TaskName, task.Type, task.Trigger, task.SourceBlock ),  ...
                sortedTaskList );
            this.SortedLists = sortedTaskList( ~filteredIdx );
        end

        function blockList = createTaskBlockList( this, task, parentPath, triggerMap, callerBlkMap )



            blockList = clone( this.ListFormatter );
            blocks = task.SortedBlocks;
            nBlocks = numel( blocks );
            allTriggeredBlksIdx = false( 1, nBlocks );

            isConstantTask = strcmp( task.TaskName, "Constant" );



            callerBlkNames = callerBlkMap.keys;

            for blkIdx = 1:nBlocks
                blk = blocks( blkIdx );
                isHidden = blk.IsHidden;
                blk.SimulinkFunction = [  ];


                if this.ShowHiddenBlocks || ~isHidden


                    if isConstantTask


                        isConditional = false;
                    else





                        updateCallerBlkMap( callerBlkMap, callerBlkNames, blk, blkIdx );

                        triggeredBlksIdx =  ...
                            findTriggeredBlocks( blkIdx, blocks, triggerMap );


                        allTriggeredBlksIdx = allTriggeredBlksIdx | triggeredBlksIdx;



                        isConditional = allTriggeredBlksIdx( blkIdx ) ||  ...
                            ( ~isAlwaysExecutedInExportedTask( blocks, blkIdx, task ) &&  ...
                            hasUnconnectedTrigger( this, blkIdx, blocks, isHidden, triggerMap ) );
                    end



                    if ~isConditional


                        listPara = mlreportgen.dom.Paragraph(  );
                        listPara.WhiteSpace = "preserve";
                        listItem = mlreportgen.dom.ListItem( listPara );


                        addBlockNameAndDetails( this, listPara, blk, parentPath );



                        blkType = get_param( blk.BlockHandle, "BlockType" );
                        if this.IncludeSubsystemBlocks && strcmpi( blkType, "Subsystem" )
                            addSubsystemBlocksRef( this, listPara, listItem, blk, task, isHidden );
                        end


                        append( blockList, listItem );
                    end
                end
            end

            if isempty( blockList.Children )
                blockList = [  ];
            end
        end

        function addSubsystemBlocksRef( this, listPara, listItem, blk, task, isHidden )
            switch lower( this.SubsystemBlocksDisplayPolicy )
                case "link"



                    if ~isHidden ...
                            && ~ismember( get_param( blk.BlockHandle, "SFBlockType" ), [ "MATLAB Function", "Chart" ] )
                        linkID = getBlockListLinkTargetID( this, blk.BlockPath, task.TaskName );
                        append( listPara, " [" );
                        append( listPara, mlreportgen.dom.InternalLink( linkID,  ...
                            getString( message( "slreportgen:report:ExecutionOrder:blockExecutionOrder" ) ) ) );
                        append( listPara, "]" );
                    end
                case "nestedlist"


                    subsystemTask = slreportgen.utils.internal.getTaskSortedLists(  ...
                        blk.BlockHandle, task.TaskIndex );



                    if ~isempty( subsystemTask )
                        subsystemTask.TaskName = task.TaskName;
                        nestedTriggerMap = containers.Map( 'KeyType', 'double', 'ValueType', 'any' );
                        nestedCallerMap = containers.Map( 'KeyType', 'char', 'ValueType', 'double' );
                        nestedList = createTaskBlockList( this, subsystemTask, getfullname( blk.BlockHandle ), nestedTriggerMap, nestedCallerMap );
                        if nestedTriggerMap.Count > 0




                            removedBlksStr = strcat( "(", getString( message( "slreportgen:report:ExecutionOrder:blocksNotIncluded" ) ), ")" );
                            append( listItem, mlreportgen.dom.Paragraph( removedBlksStr ) );
                        end
                        if ~isempty( nestedList )
                            append( listItem, nestedList );
                        end
                    end
            end
        end

        function condTable = createConditionalExecutionTable( this, task, triggerMap, callerBlkMap )


            condTable = [  ];
            uncalledFcnBlks = {  };
            blkList = task.SortedBlocks;
            if isKey( triggerMap, this.SLFunctionKey )




                slFcnInfoStructs = cell2mat( triggerMap( this.SLFunctionKey ) );
                remove( triggerMap, this.SLFunctionKey );




                callerMapVals = callerBlkMap.values;
                mdlBlks = ~cellfun( @isscalar, callerMapVals );
                mdlBlkNames = callerBlkMap.keys;
                mdlBlkNames = mdlBlkNames( mdlBlks );
                mdlBlkValues = callerMapVals( mdlBlks );
                remove( callerBlkMap, mdlBlkNames );



                nSimFcns = numel( slFcnInfoStructs );
                for fcnIdx = 1:nSimFcns
                    fcnInfo = slFcnInfoStructs( fcnIdx );
                    fcnBlkIdx = fcnInfo.BlkIdx;



                    blkList( fcnBlkIdx ).SimulinkFunction = getSimulinkFunctionName( fcnInfo, this.Object );
                    fcnBlk = blkList( fcnBlkIdx );





                    if isempty( fcnInfo.CallerBlocks )
                        uncalledFcnBlks = [ uncalledFcnBlks, fcnBlk ];%#ok<AGROW>
                    else
                        addFcnToTriggerMap( triggerMap, callerBlkMap, fcnInfo, fcnBlk );
                    end
                end


                updateModelBlockTriggers( triggerMap, mdlBlkNames, mdlBlkValues, slFcnInfoStructs, blkList );
            end

            if triggerMap.Count > 0 || ~isempty( uncalledFcnBlks )

                triggers = triggerMap.keys;

                tableData = mlreportgen.dom.FormalTable;

                for triggerIdx = [ triggers{ : } ]
                    blk = blkList( triggerIdx );

                    triggerDOM = mlreportgen.dom.Paragraph;
                    triggerDOM.StyleName = "ExecutionOrderConditionalExecutionPara";
                    triggerDOM.WhiteSpace = "preserve";

                    addBlockNameAndDetails( this, triggerDOM, blk, this.ObjectPath );
                    if isfield( blk, "SimulinkFunction" ) && ~isempty( blk.SimulinkFunction )

                        fcnString = strcat( { newline },  ...
                            getString( message( "slreportgen:report:ExecutionOrder:simulinkFunctionLabel" ) ),  ...
                            ": ", blk.SimulinkFunction );
                        append( triggerDOM, fcnString );
                    end


                    triggeredBlks = triggerMap( triggerIdx );
                    triggeredBlksEntry = makeTriggeredBlksTableEntry( this, task, blk, triggeredBlks );



                    tr = mlreportgen.dom.TableRow;
                    append( tr, mlreportgen.dom.TableEntry( triggerDOM ) );
                    append( tr, triggeredBlksEntry );
                    append( tableData, tr );
                end



                if ~isempty( uncalledFcnBlks )

                    slFcnDOM = mlreportgen.dom.Paragraph;
                    slFcnDOM.Style = [ slFcnDOM.Style, { mlreportgen.dom.Hyphenate } ];
                    append( slFcnDOM, getString( message( "slreportgen:report:ExecutionOrder:simulinkFunctionBlocks" ) ) );


                    triggeredBlksEntry = makeTriggeredBlksTableEntry( this, task, [  ], uncalledFcnBlks );


                    tr = mlreportgen.dom.TableRow;
                    append( tr, mlreportgen.dom.TableEntry( slFcnDOM ) );
                    append( tr, triggeredBlksEntry );
                    append( tableData, tr );
                end


                headTR = mlreportgen.dom.TableRow;
                append( headTR, mlreportgen.dom.TableHeaderEntry(  ...
                    getString( message( "slreportgen:report:ExecutionOrder:trigger" ) ) ) );
                append( headTR, mlreportgen.dom.TableHeaderEntry(  ...
                    getString( message( "slreportgen:report:ExecutionOrder:blocksExecuted" ) ) ) );
                append( tableData.Header, headTR );


                condTable = mlreportgen.report.BaseTable(  );
                condTable.TableStyleName = "ExecutionOrderConditionalExecutionTable";
                condTable.Content = tableData;
                condTable.Title = getString( message( "slreportgen:report:ExecutionOrder:conditionalExecution" ) );
            end
        end

        function triggeredBlksEntry = makeTriggeredBlksTableEntry( this, task, trigBlk, triggeredBlks )



            nTriggered = numel( triggeredBlks );
            triggeredBlksEntry = mlreportgen.dom.TableEntry;
            if ~isempty( trigBlk ) && strcmp( trigBlk.BlockType, "If" )







                portHandles = get_param( trigBlk.BlockHandle, 'PortHandles' );


                ifExpr = get_param( trigBlk.BlockHandle, "IfExpression" );
                expressions = strcat( "if(", ifExpr, "): " );


                elseifExpr = get_param( trigBlk.BlockHandle, "ElseIfExpressions" );
                if ~isempty( elseifExpr )

                    elseifPat = optionalPattern( whitespacePattern ) + characterListPattern( "," ) + optionalPattern( whitespacePattern );
                    elseifExpr = split( elseifExpr, elseifPat );
                    elseifExpr = strcat( "elseif(", elseifExpr, "): " );
                    expressions = [ expressions;elseifExpr ];
                end

                if strcmp( get_param( trigBlk.BlockHandle, "ShowElse" ), "on" )
                    expressions = [ expressions;"else: " ];
                end


                nExpr = numel( expressions );
                currTriggeredIdx = 1;
                for exprIdx = 1:nExpr
                    line = get_param( portHandles.Outport( exprIdx ), 'Line' );
                    if line ~=  - 1


                        triggeredBlk = triggeredBlks{ currTriggeredIdx };
                        currTriggeredIdx = currTriggeredIdx + 1;
                        exprPara = makeConditionalExecBlockPara( this, expressions( exprIdx ), task, triggeredBlk, this.ObjectPath );
                    else

                        exprPara = mlreportgen.dom.Paragraph(  ...
                            strcat( expressions( exprIdx ), "(unconnected)" ) );
                    end

                    append( triggeredBlksEntry, exprPara );
                end
            elseif nTriggered > 1



                triggeredBlksList = mlreportgen.dom.UnorderedList;
                for triggeredIdx = 1:nTriggered
                    currTriggered = triggeredBlks{ triggeredIdx };






                    nCurrTriggered = numel( currTriggered );
                    for idx = 1:nCurrTriggered

                        triggeredDOM = makeConditionalExecBlockPara( this, [  ], task, currTriggered( idx ), this.ObjectPath );
                        append( triggeredBlksList,  ...
                            triggeredDOM );
                    end

                end


                eoUndeterminedStr = strcat( "(", getString( message( "slreportgen:report:ExecutionOrder:undeterminedExecOrder" ) ), ")" );
                append( triggeredBlksEntry, eoUndeterminedStr );
                append( triggeredBlksEntry, triggeredBlksList );
            elseif numel( triggeredBlks{ 1 } ) > 1



                triggeredBlksList = mlreportgen.dom.OrderedList;
                currTriggered = triggeredBlks{ 1 };
                nCurrTriggered = numel( currTriggered );
                for idx = 1:nCurrTriggered

                    triggeredDOM = makeConditionalExecBlockPara( this, [  ], task, currTriggered( idx ), this.ObjectPath );
                    append( triggeredBlksList,  ...
                        triggeredDOM );
                end

                append( triggeredBlksEntry, triggeredBlksList );
            else


                triggeredDOM = makeConditionalExecBlockPara( this, [  ], task, triggeredBlks{ 1 }, this.ObjectPath );
                append( triggeredBlksEntry, triggeredDOM );
            end
        end

        function triggeredDOM = makeConditionalExecBlockPara( this, prefix, task, blk, parentPath )





            triggeredDOM = mlreportgen.dom.Paragraph;
            triggeredDOM.StyleName = "ExecutionOrderConditionalExecutionPara";
            triggeredDOM.WhiteSpace = "preserve";

            if ~isempty( prefix )
                append( triggeredDOM, prefix );
            end


            addBlockNameAndDetails( this, triggeredDOM, blk, parentPath );


            blkType = get_param( blk.BlockHandle, "BlockType" );
            if this.IncludeSubsystemBlocks && strcmp( blkType, "SubSystem" ) ...
                    && ~strcmpi( this.SubsystemBlocksDisplayPolicy, "NestedList" ) ...
                    && ~slreportgen.utils.isMATLABFunction( blk.BlockHandle )
                linkID = getBlockListLinkTargetID( this, blk.BlockPath, task.TaskName );
                append( triggeredDOM, " [" );
                append( triggeredDOM, mlreportgen.dom.InternalLink( linkID,  ...
                    getString( message( "slreportgen:report:ExecutionOrder:blockExecutionOrder" ) ) ) );
                append( triggeredDOM, "]" );
            end


            if isfield( blk, "SimulinkFunction" ) && ~isempty( blk.SimulinkFunction )
                fcnString = strcat( { newline },  ...
                    getString( message( "slreportgen:report:ExecutionOrder:simulinkFunctionLabel" ) ),  ...
                    ": ", blk.SimulinkFunction );
                append( triggeredDOM, fcnString );
            end
        end

        function addBlockNameAndDetails( this, blockDOM, blk, parentPath )











            blkPath = blk.BlockPath;
            blkName = extractAfter( blkPath, parentPath + "/" );
            if isempty( blkName )
                [ ~, blkName, ~ ] = fileparts( blkPath );
            end

            blkName = mlreportgen.utils.makeSingleLineText( blkName );



            if ~blk.IsHidden
                blkName = mlreportgen.dom.InternalLink( slreportgen.utils.getObjectID( blk.BlockPath ), blkName );
            end
            append( blockDOM, blkName );


            if this.ShowBlockType
                detailsStr = " (" + get_param( blk.BlockHandle, "BlockType" ) + ")";
            else
                detailsStr = "";
            end





            portStr = "";
            inPorts = blk.InputPorts;
            nInPorts = numel( inPorts );
            outPorts = blk.OutputPorts;
            nOutPorts = numel( outPorts );
            portNums = get_param( blk.BlockHandle, "Ports" );
            if ( nInPorts + nOutPorts ) ~= sum( portNums )
                if nInPorts > 0
                    portStr = " Input Ports: " + num2str( inPorts, "%i " );
                end
                if nOutPorts > 0
                    if portStr ~= ""
                        portStr = portStr + ",";
                    end
                    portStr = portStr + " Output Ports: " + num2str( outPorts, "%i " );
                end
            end


            detailsStr = detailsStr + portStr;
            if detailsStr ~= ""
                append( blockDOM, detailsStr );
            end
        end

        function isConditional = hasUnconnectedTrigger( this, blkIdx, blkList, isHidden, triggerMap )











            blkInfo = blkList( blkIdx );
            blk = blkInfo.BlockHandle;

            isConditional = false;
            slFcnInfo = [  ];

            if strcmp( blkInfo.BlockType, "SubSystem" )

                portHandles = get_param( blk, "PortHandles" );
                if isempty( portHandles.Trigger )


                    fcnIdx = strcmp( this.SimulinkFunctionBlockNames, blkInfo.BlockPath );
                    slFcnInfo = this.SimulinkFunctionsInfo( fcnIdx );
                end
            elseif strcmp( blkInfo.BlockType, "ModelReference" ) &&  ...
                    startsWith( blkInfo.PortGroup, "F" )


                slFcnInfoMatches = this.SimulinkFunctionsInfo(  ...
                    strcmp( this.SimulinkFunctionBlockNames, blkInfo.BlockPath ) );
                if isempty( slFcnInfoMatches )





                    splitPath = strsplit( blkInfo.BlockPath, "/" );
                    if strcmp( splitPath( end  ), splitPath( end  - 1 ) )
                        splitPath( end  ) = [  ];
                        slFcnInfoMatches = this.SimulinkFunctionsInfo(  ...
                            strcmp( this.SimulinkFunctionBlockNames, strjoin( splitPath, "/" ) ) );
                    end
                end



                portGroup = sscanf( blkInfo.PortGroup, "F%d" );
                for currSlFcnInfo = slFcnInfoMatches
                    if ismember( portGroup, currSlFcnInfo.PortGroup )
                        slFcnInfo = currSlFcnInfo;
                        break ;
                    end
                end

                if isempty( slFcnInfo )
                    ph = get_param( blk, "PortHandles" );
                    inports = ph.Inport( blkInfo.InputPorts );
                    portTypes = get_param( inports, "CompiledPortDataType" );
                    fcnCallPort = inports( strcmp( portTypes, "fcn_call" ) );
                    if ~isempty( fcnCallPort ) && get_param( fcnCallPort, "Line" ) ==  - 1











                        isConditional = ~isHidden;
                    end
                end

            end


            if ~isempty( slFcnInfo )
                isConditional = true;
                slFcnInfo.BlkIdx = blkIdx;
                addToMap( triggerMap, this.SLFunctionKey, slFcnInfo );
            end

        end

        function linkID = getBlockListLinkTargetID( this, parentSystem, taskName )






            parentID = slreportgen.utils.getObjectID( parentSystem, "Hash", false );
            linkID = compose( "ExecutionOrder-%s-%s", parentID, taskName );

            if this.HashLinkIDs
                linkID = mlreportgen.utils.normalizeLinkID( linkID );
            end
        end

        function linkID = getTaskDetailsLinkTargetID( this )




            parentID = slreportgen.utils.getObjectID( this.ObjectHandle, "Hash", false );
            linkID = compose( "ExecutionOrder-TaskDetails-%s", parentID );

            if this.HashLinkIDs
                linkID = mlreportgen.utils.normalizeLinkID( linkID );
            end
        end
    end

    methods ( Static )
        function path = getClassFolder(  )


            [ path ] = fileparts( mfilename( 'fullpath' ) );
        end

        function template = createTemplate( templatePath, type )







            path = slreportgen.report.ExecutionOrder.getClassFolder(  );
            template = mlreportgen.report.ReportForm.createFormTemplate(  ...
                templatePath, type, path );
        end

        function classFile = customizeReporter( toClasspath )









            classFile = mlreportgen.report.ReportForm.customizeClass(  ...
                toClasspath, "slreportgen.report.ExecutionOrder" );
        end

    end

    methods ( Static, Hidden )
        function linkID = getLinkTargetID( object, varargin )



            objectID = slreportgen.utils.getObjectID( object, "Hash", false );
            linkID = compose( "ExecutionOrder-%s", objectID );

            p = inputParser(  );
            addParameter( p, "Hash", true, @( x )isempty( x ) || islogical( x ) );
            parse( p, varargin{ : } );
            args = p.Results;

            if args.Hash
                linkID = mlreportgen.utils.normalizeLinkID( linkID );
            end
        end

    end

end

function srcBlockDOM = makeSourceBlockDOM( srcBlocks )



if srcBlocks == ""
    srcBlockDOM = [  ];
else
    nSrc = numel( srcBlocks );
    srcBlockLinks = mlreportgen.dom.InternalLink.empty( 0, nSrc );
    for k = 1:nSrc
        blkPath = srcBlocks( k );
        srcBlockLinks( k ) = mlreportgen.dom.InternalLink(  ...
            slreportgen.utils.getObjectID( blkPath ), blkPath );
    end

    if nSrc > 1
        srcBlockDOM = mlreportgen.dom.UnorderedList( srcBlockLinks );
        srcBlockDOM.StyleName = "ExecutionOrderSourceBlockList";
    else
        srcBlockDOM = srcBlockLinks;
    end
end
end

function isFiltered = isFilteredTask( taskFilterFcn, taskName, taskType, trigger, sourceBlock )


isFiltered = false;
if ~isempty( taskFilterFcn )
    try
        if isa( taskFilterFcn, 'function_handle' )
            isFiltered = taskFilterFcn( taskName, taskType, trigger, sourceBlock );
        else



            eval( taskFilterFcn );
        end

    catch me
        warning( message( "mlreportgen:report:warning:filterFcnError", "TaskFilterFcn", me.message ) );
    end
end

end

function allTriggeredIdx = findTriggeredBlocks( blkIdx, blkList, triggerMap )














nBlks = numel( blkList );
allTriggeredIdx = false( 1, nBlks );
outportsToTrace = [  ];
blkInfo = blkList( blkIdx );
blkHandle = blkInfo.BlockHandle;
type = blkInfo.BlockType;
if strcmp( type, "If" )


    portHandles = get_param( blkHandle, 'PortHandles' );
    outportsToTrace = portHandles.Outport;
elseif ismember( type, [ "SubSystem", "S-Function" ] )



    portHandles = get_param( blkHandle, 'PortHandles' );
    portTypes = get_param( portHandles.Outport, 'CompiledPortDataType' );
    outportsToTrace = portHandles.Outport( strcmpi( portTypes, "fcn_call" ) );
end


lines = mlreportgen.utils.safeGet( outportsToTrace, "Line", "get_param" );
lines = [ lines{ : } ];
if ~isempty( outportsToTrace ) && any( lines ~=  - 1 )

    lines( lines ==  - 1 ) = [  ];


    nLines = numel( lines );
    triggeredBlkStructs = {  };
    for lineIdx = 1:nLines
        currLine = lines( lineIdx );



        triggeredPorts = get_param( currLine, 'NonVirtualDstPorts' );
        triggeredBlocks = mlreportgen.utils.safeGet( triggeredPorts, 'Parent', 'get_param' );


        nTriggered = numel( triggeredBlocks );
        triggeredByLine = false( 1, nBlks );
        for currIdx = 1:nTriggered
            currTriggered = strrep( triggeredBlocks{ currIdx }, newline, ' ' );
            if strcmp( get_param( currTriggered, 'BlockType' ), 'ModelReference' )






                currPortNum = get_param( triggeredPorts( currIdx ), 'PortNumber' );

                currTriggeredIdx = arrayfun(  ...
                    @( x )strcmp( x.BlockPath, currTriggered ) && ismember( currPortNum, x.InputPorts ),  ...
                    blkList' );

            else

                currTriggeredIdx = strcmp( { blkList.BlockPath }, currTriggered );
            end



            triggeredByLine = triggeredByLine | currTriggeredIdx;
        end

        if any( triggeredByLine )


            triggeredBlkStructs{ end  + 1 } = blkList( triggeredByLine );%#ok<AGROW>
            allTriggeredIdx = allTriggeredIdx | triggeredByLine;
        end
    end

    if ~isempty( triggeredBlkStructs )

        triggerMap( blkIdx ) = triggeredBlkStructs;%#ok<NASGU>
    end
end
end

function setSourceBlockColWidth( ft, propNames, tableRptr )




srcBlkIdx = find( strcmpi( "SourceBlock", propNames ) );
if ~isempty( srcBlkIdx )
    colSpecGrps = mlreportgen.dom.TableColSpecGroup;
    colSpecGrps.Span = srcBlkIdx;


    specs = mlreportgen.dom.TableColSpec;
    specs.Span = 1;
    specs.Style = { mlreportgen.dom.Width( "40%" ) };

    if srcBlkIdx > 1


        otherSpecs = mlreportgen.dom.TableColSpec;
        otherSpecs.Span = srcBlkIdx - 1;
        specs = [ otherSpecs, specs ];
    end

    colSpecGrps.ColSpecs = specs;
    ft.ColSpecGroups = colSpecGrps;
    ft.Style = [ ft.Style,  ...
        { mlreportgen.dom.ResizeToFitContents( false ) } ];

    if isempty( tableRptr.TableWidth )
        ft.Width = "100%";
    end
end
end

function fullName = getSimulinkFunctionName( fcnInfo, reportedObj )








fcnName = fcnInfo.FunctionName;
fcnNamePrefix = fcnInfo.FullPathToFunction;
if ~isempty( fcnNamePrefix )


    fcnNamePrefix = extractAfter( bdroot( reportedObj ) + "/" + fcnNamePrefix, getfullname( reportedObj ) + "/" );
    if ismissing( fcnNamePrefix )


        fcnNamePrefix = [  ];
    elseif ~isempty( fcnNamePrefix )
        fcnNamePrefix = fcnNamePrefix + ".";
    end
end
fullName = strcat( fcnNamePrefix, fcnName );
end

function addToMap( mapObj, key, val )

if isKey( mapObj, key )
    mapObj( key ) = [ mapObj( key ), val ];%#ok<NASGU>
else
    mapObj( key ) = { val };%#ok<NASGU>
end
end

function tf = isAlwaysExecutedInExportedTask( blkList, blkIdx, task )

tf = false;

if ( blkIdx == 1 ) || ( blkIdx == 2 && ~ismember( blkList( 1 ).BlockType, [ "SubSystem", "ModelReference" ] ) )

    if isfield( task, 'Type' ) &&  ...
            ( strcmp( task.Type, "SimulinkFunction" ) || startsWith( task.Type, "Exported" ) )
        tf = true;
    end
end
end


function updateCallerBlkMap( callerBlkMap, callerBlkNames, blk, blkIdx )

if startsWith( blk.PortGroup, "F" )


    callerBlkIdx = strcmp( callerBlkNames, blk.BlockPath );
    if ~any( callerBlkIdx )
        splitPath = strsplit( blk.BlockPath, "/" );
        if strcmp( splitPath( end  ), splitPath( end  - 1 ) )

            splitPath( end  ) = [  ];
            newBlkPath = strjoin( splitPath, "/" );
            callerBlkIdx = strcmp( callerBlkNames, newBlkPath );
        end
    end
    if any( callerBlkIdx )
        currCallerBlks = callerBlkNames( callerBlkIdx );

        blksIdxArray = callerBlkMap( currCallerBlks{ 1 } );
        portGroup = sscanf( blk.PortGroup, "F%d" );
        blksIdxArray( portGroup + 1 ) = blkIdx;
        callerBlkMap( currCallerBlks{ 1 } ) = blksIdxArray;%#ok<NASGU>
    end
else
    callerBlkIdx = strcmp( callerBlkNames, blk.BlockPath );
    if any( callerBlkIdx )
        currCallerBlks = callerBlkNames( callerBlkIdx );


        callerBlkMap( currCallerBlks{ 1 } ) = blkIdx;%#ok<NASGU>
    else



        currCallerBlks = callerBlkNames( startsWith( callerBlkNames, blk.BlockPath + "/" ) );
        nCallerBlks = numel( currCallerBlks );


        for callerBlkIdx = 1:nCallerBlks
            callerBlkMap( currCallerBlks{ callerBlkIdx } ) = blkIdx;
        end
    end
end
end


function addFcnToTriggerMap( triggerMap, callerBlkMap, fcnInfo, fcnBlk )

callerBlks = fcnInfo.CallerBlocks;


nCallers = numel( callerBlks );
for callerNameIdx = 1:nCallers
    if isKey( callerBlkMap, callerBlks{ callerNameIdx } )
        callerStructIdx = callerBlkMap( callerBlks{ callerNameIdx } );

        if callerStructIdx > 0
            if isKey( triggerMap, callerStructIdx )
                calledBlkStructs = triggerMap( callerStructIdx );




                matchingIdx = cellfun(  ...
                    @( x )isscalar( x ) && strcmp( x.SimulinkFunction, fcnBlk.SimulinkFunction ), calledBlkStructs );
                if ~any( matchingIdx )
                    triggerMap( callerStructIdx ) = [ triggerMap( callerStructIdx ), fcnBlk ];
                end
            else
                triggerMap( callerStructIdx ) = { fcnBlk };
            end
        end
    end
end

end

function updateModelBlockTriggers( triggerMap, mdlBlkNames, mdlBlkValues, slFcnInfoStructs, blkList )

slFcnInfoPaths = { slFcnInfoStructs.FullPathToFunction };
scopedFcnIdx = ~cellfun( @isempty, slFcnInfoPaths );
slFcnInfoNames = { slFcnInfoStructs.FunctionName };
slFcnInfoNames( scopedFcnIdx ) = strcat( slFcnInfoPaths( scopedFcnIdx ), '.', slFcnInfoNames( scopedFcnIdx ) );

nMdlBlks = numel( mdlBlkNames );
for mdlIdx = 1:nMdlBlks
    blkVals = mdlBlkValues{ mdlIdx };
    nBlkVals = numel( blkVals );

    mdlBlkHandle = blkList( blkVals( end  ) ).BlockHandle;
    portInfo = get_param( mdlBlkHandle, "PortGroupInfo" );

    fcnCallPortGroups = portInfo.FcnCallPortGroups;
    nPorts = numel( fcnCallPortGroups );
    for portIdx = 1:nPorts
        if nBlkVals >= portIdx && blkVals( portIdx ) > 0


            fcnCallers = fcnCallPortGroups( portIdx ).MoreDetails.FunctionCallersInside;
            if ~isempty( fcnCallers )

                calledFcns = slFcnInfoStructs( ismember( slFcnInfoNames, fcnCallers ) );
                for currFcn = calledFcns
                    addToMap( triggerMap, blkVals( portIdx ), blkList( currFcn.BlkIdx ) );
                end
            end
        end
    end
end
end


function createObjects( objectType, ~ )

arguments
    objectType{ mustBeMember( objectType, { 'Parameter', 'Struct' } ) }
    ~
end

ed = Simulink.typeeditor.app.Editor.getInstance;
if ~isempty( ed )
    st = ed.getStudio;
    ts = st.getToolStrip;

    switch objectType
        case 'Parameter'
            act = ts.getAction( 'createSimulinkParameterAction' );
        case 'Struct'
            act = ts.getAction( 'createMATLABStructAction' );
    end
    valid = act.enabled;

    readyMsg = DAStudio.message( 'Simulink:busEditor:BusEditorReadyStatusMsg' );
    resetTreeViewNode = false;

    curTreeNode = ed.getCurrentTreeNode;
    assert( length( curTreeNode ) == 1 && isvalid( curTreeNode{ 1 } ) );
    curTreeNode = curTreeNode{ 1 };

    if valid
        createObjectStatusMsg = DAStudio.message( 'Simulink:busEditor:BusEditorCreateAndEditObjectStatusMsg' );
        st.setStatusBarMessage( createObjectStatusMsg );

        st.setStatusBarMessage( DAStudio.message( 'Simulink:busEditor:BusEditorWaitingForUserInputStatusMsg' ) );
        [ fileName, pathName, ~ ] = uiputfile( { '*.m', DAStudio.message( 'Simulink:busEditor:MATLABFiles' ) } );


        if isequal( fileName, 0 ) || isequal( pathName, 0 )
            st.setStatusBarMessage( readyMsg );
            return ;
        end

        tempFile = fullfile( pathName, fileName );

        act.enabled = false;

        if ~isequal( curTreeNode, curTreeNode.getRoot )
            selectedBusObjectName = curTreeNode.Name;
        else

            listNodes = Simulink.typeeditor.app.Editor.getInstance.getCurrentListNode;


            assert( length( listNodes ) == 1 );
            selectedBusObjectName = listNodes{ 1 }.Name;
        end

        try
            cellArrOfAssociatedObjects = {  };


            if strcmp( objectType, 'Parameter' ) == 1
                cellArrOfAssociatedObjects = getListOfAssociatedObjects( selectedBusObjectName, objectType );
            end

            if isempty( cellArrOfAssociatedObjects )

                serializeObjects( selectedBusObjectName, '', tempFile, objectType, curTreeNode.getRoot );
                resetTreeViewNode = true;
            else

                assert( strcmp( objectType, 'Parameter' ) == 1 );
                dlgNewObjectStr = DAStudio.message( 'Simulink:busEditor:BusEditorCreateAndEditParameterNewDlg' );
                dlgNameStr = DAStudio.message( 'Simulink:busEditor:BusEditorCreateAndEditParameterNameDlg' );
                dlgPromptStr = DAStudio.message( 'Simulink:busEditor:BusEditorCreateAndEditParameterPromptDlg' );
                cellArrOfAssociatedObjects = [ dlgNewObjectStr, cellArrOfAssociatedObjects ];
                st.setStatusBarMessage( DAStudio.message( 'Simulink:busEditor:BusEditorWaitingForUserInputStatusMsg' ) );

                [ selectedIdx, ok ] = listdlg( 'ListString', cellArrOfAssociatedObjects,  ...
                    'SelectionMode', 'single',  ...
                    'InitialValue', 1,  ...
                    'Name', dlgNameStr,  ...
                    'PromptString', dlgPromptStr,  ...
                    'ListSize', [ 500, 200 ] );

                if ok == 1
                    assert( length( selectedIdx ) == 1 );
                    st.setStatusBarMessage( createObjectStatusMsg );
                    if selectedIdx == 1

                        serializeObjects( selectedBusObjectName, '',  ...
                            tempFile, objectType, curTreeNode.getRoot );
                        resetTreeViewNode = true;
                    else

                        serializeObjects( selectedBusObjectName,  ...
                            cellArrOfAssociatedObjects{ selectedIdx },  ...
                            tempFile, objectType, curTreeNode.getRoot );
                    end
                end
            end
        catch ME
            st.setStatusBarMessage( readyMsg );
            ed.update;
            if exist( tempFile, 'file' )

                delete( tempFile );
            end
            errmsg = formatError( ME, selectedBusObjectName, objectType );
            Simulink.typeeditor.utils.reportError( errmsg );
            return ;
        end

        st.setStatusBarMessage( readyMsg );

        if resetTreeViewNode


            ed.onFocus;
            selectedNode = Simulink.typeeditor.utils.getNodeFromPath( curTreeNode.getRoot, selectedBusObjectName );
            ed.getListComp.view( selectedNode );
        end

        ed.update;
    end
end


function serializeObjects( busObjectName, dataObjectName, tempFile, objectType, root )
redirectParamValue = false;
structVarName = '';
paramVarName = '';
if isempty( dataObjectName )
    assert( ~isempty( busObjectName ) );
    scope = root.NodeConnection;
    if root.hasDictionaryConnection
        scopeForEval = Simulink.data.dictionary.open( scope.filespec );
        cleanupObj = onCleanup( @(  )scopeForEval.close );
    else
        scopeForEval = scope;
    end
    tempStructValue = Simulink.Bus.createMATLABStruct( busObjectName, [  ], [ 1, 1 ], scopeForEval );%#ok
    structVarName = getUniqueName( busObjectName, 'MATLABStruct' );
    eval( [ structVarName, ' = tempStructValue;' ] );
    matlab.io.saveVariablesToScript( tempFile, structVarName, 'SaveMode', 'create' );

    if strcmp( objectType, 'Parameter' ) == 1
        tempParam = Simulink.Parameter;
        tempParam.Value = [  ];
        tempParam.DataType = [ 'Bus: ', busObjectName ];
        paramVarName = getUniqueName( busObjectName, 'Param' );
        eval( [ paramVarName, ' = tempParam;' ] );
        matlab.io.saveVariablesToScript( tempFile, paramVarName, 'SaveMode', 'append' );
        redirectParamValue = true;
    end
else
    assert( strcmp( objectType, 'Parameter' ) == 1 );

    objID = root.NodeDataAccessor.identifyByName( dataObjectName );
    if root.hasDictionaryConnection
        numVarIDs = length( objID );
        if numVarIDs > 1
            [ ~, ddName, ~ ] = fileparts( root.NodeConnection.filespec );
            ddName = [ ddName, '.sldd' ];
            for j = 1:numVarIDs
                if strcmp( objID( j ).getDataSourceFriendlyName, ddName )
                    objID = objID( j );
                    break ;
                end
            end
        end
    end
    tmpObject = root.NodeDataAccessor.getVariable( objID );%#ok<NASGU>
    eval( [ dataObjectName, ' = tmpObject;' ] );
    matlab.io.saveVariablesToScript( tempFile, dataObjectName, 'SaveMode', 'create' );
    paramVarName = dataObjectName;
end


postProcessGeneratedFile( structVarName, paramVarName, tempFile,  ...
    objectType, redirectParamValue );


edit( tempFile );


function postProcessGeneratedFile( structVarName, paramVarName,  ...
    tempFile, objectType, redirectParamValue )


fid = fopen( tempFile );
txtSerializedVars = textscan( fid, '%s', 'delimiter', '\n' );
fclose( fid );
assert( iscell( txtSerializedVars ) && ( length( txtSerializedVars ) == 1 ) );
txtSerializedVars = txtSerializedVars{ 1 };


assert( regexp( txtSerializedVars{ 1 }, '% --' ) == 1 );
txtSerializedVars{ 1 } = regexprep( txtSerializedVars{ 1 }, '% -', '%% ' );


if strcmp( objectType, 'Struct' ) == 1
    tempMsg =  ...
        textscan( DAStudio.message( 'Simulink:busEditor:FileCreateAndEditStructComments',  ...
        structVarName ), '%s', 'delimiter', '\n' );
    assert( iscell( tempMsg ) && ( length( tempMsg ) == 1 ) );
    customizedComments = tempMsg{ 1 };
    assert( iscell( customizedComments ) );
elseif strcmp( objectType, 'Parameter' ) == 1
    if redirectParamValue

        for idx = 1:length( txtSerializedVars )
            if ~isempty( regexp( txtSerializedVars{ idx }, [ paramVarName, '.Value = ' ], 'once' ) )
                txtSerializedVars{ idx } = [ paramVarName, '.Value = ', structVarName, ';' ];
                break ;
            end
        end
        txtSerializedVars{ end  + 1 } = [ 'clear ', structVarName, ';' ];
    else
        assert( isempty( structVarName ) );
        assert( ~isempty( paramVarName ) );
        structVarName = [ paramVarName, '.Value' ];
    end

    tempMsg =  ...
        textscan( DAStudio.message( 'Simulink:busEditor:FileCreateAndEditParameterComments',  ...
        structVarName, paramVarName ), '%s', 'delimiter', '\n' );
    assert( iscell( tempMsg ) && ( length( tempMsg ) == 1 ) );
    customizedComments = tempMsg{ 1 };
    assert( iscell( customizedComments ) );
end


newSerializedVars = {  };
newSerializedVars{ 1 } = txtSerializedVars{ 1 };
for idx = 1:length( customizedComments )
    newSerializedVars{ end  + 1 } = customizedComments{ idx };%#ok
end
for idx = 4:length( txtSerializedVars )
    newSerializedVars{ end  + 1 } = txtSerializedVars{ idx };%#ok
end

fid = fopen( tempFile, 'w' );
for idx = 1:length( newSerializedVars )
    fprintf( fid, '%s\n', newSerializedVars{ idx } );
end
fclose( fid );


function retVal = getUniqueName( name, suffix )
ed = Simulink.typeeditor.app.Editor.getInstance;
root = ed.getCurrentTreeNode{ 1 };

retVal = [ name, '_', suffix ];
idx = 1;
while true
    if isvarname( retVal ) && ~root.NodeDataAccessor.hasVariable( retVal )
        return ;
    else
        retVal = [ name, '_', suffix, num2str( idx ) ];
        idx = idx + 1;
    end
end


function errmsg = formatError( ME, busname, objectType )
errmsg = ME.message;
if strcmp( objectType, 'Struct' ) == 1
    errmsg = [ DAStudio.message( 'Simulink:busEditor:BusEditorCreateAndEditStructErrmsgPrefix',  ...
        busname ), sprintf( '\n\n' ), errmsg ];
elseif strcmp( objectType, 'Parameter' ) == 1
    errmsg = [ DAStudio.message( 'Simulink:busEditor:BusEditorCreateAndEditParameterErrmsgPrefix',  ...
        busname ), sprintf( '\n\n' ), errmsg ];
end
errmsg = collectAllErrorCauses( ME.cause, errmsg );


function errmsg = collectAllErrorCauses( causes, errmsg )
if isempty( causes )
    return ;
end
if ~iscell( causes )
    causes = { causes };
end
for idx = 1:length( causes )
    errmsg = [ errmsg, sprintf( '\n\n' ), causes{ idx }.message ];%#ok

    if ~isempty( causes{ idx }.cause )
        errmsg = collectAllErrorCauses( causes{ idx }.cause, errmsg );
    end
end


function cellArrOfAssociatedObjects = getListOfAssociatedObjects( busname, objectType )
assert( strcmp( objectType, 'Parameter' ) == 1 );
cellArrOfAssociatedObjects = {  };
ed = Simulink.typeeditor.app.Editor.getInstance;
root = ed.getCurrentTreeNode{ 1 };
paramVarIDs = root.NodeDataAccessor.identifyVisibleVariablesByClass( 'Simulink.Parameter' );
for idx = 1:length( paramVarIDs )
    paramObj = root.NodeDataAccessor.getVariable( paramVarIDs( idx ) );
    if isempty( busname )
        if ~isempty( regexp( paramObj.DataType, 'Bus:', 'once' ) )
            cellArrOfAssociatedObjects{ end  + 1 } = paramVarIDs( idx ).Name;%#ok
        end
    else
        if strcmp( paramObj.DataType, [ 'Bus: ', busname ] ) == 1
            cellArrOfAssociatedObjects{ end  + 1 } = paramVarIDs( idx ).Name;%#ok
        end
    end
end

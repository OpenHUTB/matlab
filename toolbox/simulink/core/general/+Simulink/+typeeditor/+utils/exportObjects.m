function success = exportObjects( objectNames, type )

arguments
    objectNames cell
    type{ mustBeMember( type, { 'MAT', 'Cell', 'Object' } ) }
end

switch type
    case 'MAT'
        fileExt = '*.mat';
        fileStr = DAStudio.message( 'Simulink:busEditor:MATFiles' );
    case 'Cell'
        fileExt = '*.m';
        fileStr = DAStudio.message( 'Simulink:busEditor:MATLABFiles' );
        exportFormat = 'cell';
    case 'Object'
        fileExt = '*.m';
        fileStr = DAStudio.message( 'Simulink:busEditor:MATLABFiles' );
        exportFormat = 'object';
end

assert( ~isempty( objectNames ) && iscell( objectNames ) );

ed = Simulink.typeeditor.app.Editor.getInstance;
st = ed.getStudio;
curRoot = ed.getTreeComp.getSelection{ 1 };

st.setStatusBarMessage( DAStudio.message( 'Simulink:busEditor:BusEditorWaitingForUserInputStatusMsg' ) );
[ fileName, pathname, ~ ] = uiputfile( { fileExt, fileStr }, DAStudio.message( 'Simulink:busEditor:CustomExportTitle' ) );


if isequal( fileName, 0 ) || isequal( pathname, 0 )
    success = false;
    return ;
end

exportFile = fullfile( pathname, fileName );

success = false;
[ ~, name, ext ] = fileparts( exportFile );

try
    if strcmpi( ext, '.m' )
        if ~isvarname( name )
            errorstr = DAStudio.message( 'Simulink:busEditor:InvalidMATLABFileNameForExport', name );
            Simulink.typeeditor.utils.reportError( errorstr );
            return ;
        end

        scope = curRoot.NodeConnection;
        isBus = cellfun( @( obj )curRoot.find( obj ).IsBus, objectNames );
        numObjNames = length( objectNames );
        isConnectionBus = false( 1, numObjNames );
        for i = 1:numObjNames
            objVarID = curRoot.NodeDataAccessor.identifyByName( objectNames{ i } );
            objVar = curRoot.NodeDataAccessor.getVariable( objVarID );
            isConnectionBus( i ) = isa( objVar, Simulink.typeeditor.app.Editor.AdditionalBaseType );
        end
        haveConnectionBuses = any( isConnectionBus );
        haveNonBusTypes = any( ~isBus );

        if exist( exportFile, 'file' )
            delete( exportFile );
        end



        if ( ( slfeature( 'CUSTOM_BUSES' ) == 1 ) && haveConnectionBuses ) ||  ...
                ( ( slfeature( 'TypeEditorStudio' ) == 1 ) && haveNonBusTypes )
            fileMode = 'wt';
            for i = 1:numObjNames
                if isBus( i )
                    if ~isConnectionBus( i )
                        Simulink.Bus.save( exportFile, exportFormat, objectNames( i ), scope, fileMode );
                    else
                        Simulink.ConnectionBus.save( exportFile, objectNames( i ), scope, fileMode );
                    end
                else
                    saveNonBusType( exportFile, objectNames{ i }, curRoot, fileMode );
                end
                if i == 1
                    fileMode = 'at';
                end
            end
        else
            Simulink.Bus.save( exportFile, exportFormat, objectNames( ~isConnectionBus ), scope );
        end
    elseif strcmpi( ext, '.mat' )
        if exist( exportFile, 'file' )
            delete( exportFile );
        end
        objectstosave = '';
        for idx = 1:length( objectNames )
            objectstosave = [ objectstosave, ',''', objectNames{ idx }, '''' ];%#ok
        end
        exportFile = strrep( exportFile, '''', '''''' );
        curRoot.NodeConnection.evalin( [ 'save(''', exportFile, '''', objectstosave, ');' ] );
    end
    success = true;
catch ME
    Simulink.typeeditor.utils.reportError( ME.message );
    delete( fileName );
end
end

function saveNonBusType( fileName, objectName, root, fileMode )

nodeConn = root.NodeConnection;
if ~( isa( nodeConn, 'Simulink.data.BaseWorkspace' ) || nodeConn( root, 'Simulink.dd.Connection' ) )
    DAStudio.error( 'Simulink:tools:slbusInvalidScope' );
end

[ pathStr, fcnName, ~ ] = fileparts( fileName );


if ~isempty( pathStr ) && ~exist( pathStr, 'dir' )
    DAStudio.error( 'Simulink:tools:slbusSaveDirDoesNotExist' );
end

[ fID, ~ ] = fopen( fileName, fileMode );
if ~strcmpi( fileMode, 'at' )
    fprintf( fID, 'function %s() \n', fcnName );
    tmpStr = 'initializes a set of type objects in the MATLAB base workspace';
    fprintf( fID, '%% %s %s \n\n', upper( fcnName ), tmpStr );
end

objectID = root.NodeDataAccessor.identifyByName( objectName );
objectSrc = root.NodeDataAccessor.getVariable( objectID );

if isa( objectSrc, 'Simulink.Bus' )
    typeName = 'Bus';
elseif isa( objectSrc, 'Simulink.AliasType' )
    typeName = 'Alias Type';
elseif isa( objectSrc, 'Simulink.NumericType' )
    typeName = 'Numeric Type';
elseif isa( objectSrc, 'Simulink.ValueType' )
    typeName = 'Value Type';
else
    assert( isa( objectSrc, 'Simulink.data.dictionary.EnumTypeDefinition' ) );
    if fID ~=  - 1
        fclose( fID );
    end
    return ;
end

fprintf( fID, '%% %s object: %s \n', typeName, objectName );
fprintf( fID, '%s = %s;\n', objectName, class( objectSrc ) );
props = properties( objectSrc );
for i = 1:length( props )
    propVal = objectSrc.( props{ i } );
    if ischar( propVal ) || isstring( propVal )
        formattedVal = escapeForSprintf( propVal );
    elseif islogical( propVal ) || isnumeric( propVal )
        doublePrecision = 16;
        formattedVal = mat2str( propVal, doublePrecision );
    else
        assert( false );
    end
    fprintf( fID, [ objectName, '.', props{ i }, ' = ', formattedVal, ';\n' ] );
end

fprintf( fID, 'assignin(''base'', ''%s'', %s);\n', objectName, objectName );
fprintf( fID, '\n' );

if fID ~=  - 1
    fclose( fID );
end
end

function outStr = escapeForSprintf( str )

if isempty( str )
    outStr = '''''';
else
    outStr = strrep( str, '\', '\\' );
    outStr = strrep( outStr, '''', '''''' );
    outStr = strrep( outStr, '%', '%%' );
    if ischar( outStr )
        outStr = [ '''', strrep( outStr, newline, '\n' ), '''' ];
    elseif isstring( outStr )
        outStr = [ '"', strrep( char( outStr ), newline, '\n' ), '"' ];
    end
end
end

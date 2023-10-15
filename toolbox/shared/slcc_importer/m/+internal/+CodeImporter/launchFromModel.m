function launchFromModel( hModel )
arguments
    hModel( 1, 1 )double
end

objMdl = get_param( hModel, 'Object' );
mdlName = objMdl.Name;
persistent m;
if isempty( m )
    m = containers.Map( 'KeyType', 'char', 'ValueType', 'any' );
end


for k = keys( m )

    if ~bdIsLoaded( k )
        remove( m, k );
    end
end
if isKey( m, mdlName )
    importObj = m( mdlName );
    if isa( importObj, 'Simulink.CodeImporter' ) && isvalid( importObj )
        importObj.view;
        return ;
    else
        remove( m, mdlName );
    end
end


libraryFileName = mdlName;
if ~bdIsLibrary( mdlName )
    libraryFileName = 'untitled';
elseif isempty( objMdl.FileName )
    errmsg = MException( message( 'Simulink:CodeImporter:SaveTheNewLibraryModel' ) );
    throw( errmsg );
end

obj = Simulink.CodeImporter( libraryFileName );
if ~isempty( objMdl.FileName )
    filePath = objMdl.FileName;
    obj.OutputFolder = fileparts( filePath );
end
m( obj.LibraryFileName ) = obj;
obj.view;
end


function copyExampleCacheFiles( appName, relCacheDir, options )

arguments
    appName{ mustBeTextScalar, mustBeNonempty }
    relCacheDir{ mustBeTextScalar, mustBeNonempty }
    options.DestFolder{ mustBeTextScalar } = fullfile( pwd, 'Work' )
    options.ModelRefs( 1, : ){ mustBeText, mustBeVector } = {  }
end

cacheLeafFolder = Simulink.ModelReference.getSLXCCacheLeafFolder(  );

if isempty( cacheLeafFolder )
    return ;
end


srcFolder = fullfile( relCacheDir, cacheLeafFolder );
if ~isfolder( srcFolder )
    return ;
end

if ~isempty( options.ModelRefs )
    mdlrefs = options.ModelRefs;
else

    jsonFile = fullfile( srcFolder, [ appName, '.json' ] );
    if ~isfile( jsonFile )
        return ;
    end
    mdlrefs = jsondecode( fileread( jsonFile ) );
end


for i = 1:length( mdlrefs )

    slxcFile = Simulink.packagedmodel.constructPackagedFile( mdlrefs{ i } );
    srcFile = fullfile( srcFolder, slxcFile );
    dstFile = fullfile( options.DestFolder, slxcFile );

    if ~isempty( options.ModelRefs ) && ~isfile( srcFile )
        continue ;
    end

    copyfile( srcFile, dstFile, 'f' );

    if ispc
        fileattrib( dstFile, '+w' );
    else
        fileattrib( dstFile, '+w', 'a' );
    end
end

end



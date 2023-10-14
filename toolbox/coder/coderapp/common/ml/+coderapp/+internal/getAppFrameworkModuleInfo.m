function modDefJson = getAppFrameworkModuleInfo( opts )

arguments
    opts.Assert( 1, 1 )logical = false
end

file = fullfile( matlabroot(  ), 'toolbox/coder/coderapp/core/web/coderFrameworkProvider/coderModuleDef.json' );

if isfile( file )
    modDef = coderapp.internal.util.parseCoderModuleDef( file );
    modDefJson = jsonencode( modDef );
else
    modDefJson = '';
end

if opts.Assert && isempty( modDefJson )
    error( 'App Framework unavailable' );
end
end



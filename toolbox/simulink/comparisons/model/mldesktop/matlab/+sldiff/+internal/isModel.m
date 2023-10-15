function tf = isModel( file )

arguments
    file{ mustBeTextScalar }
end

if ~isfile( file )
    tf = false;
    return ;
end

fmt = Simulink.loadsave.identifyFileFormat( file );
tf = any( strcmpi( fmt, [ "slx", "mdl", "opcmdl" ] ) );
end


function ext = getModelExt( file )

arguments
    file{ mustBeTextScalar }
end

ext = Simulink.loadsave.identifyFileFormat( file );
if ( strcmpi( ext, "opcmdl" ) )
    ext = 'mdl';
end
end

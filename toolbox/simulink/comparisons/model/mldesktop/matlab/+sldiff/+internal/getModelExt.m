function ext = getModelExt( file )




R36
file{ mustBeTextScalar }
end 

ext = Simulink.loadsave.identifyFileFormat( file );
if ( strcmpi( ext, "opcmdl" ) )
ext = 'mdl';
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpnfn_Sh.p.
% Please follow local copyright laws when handling this file.


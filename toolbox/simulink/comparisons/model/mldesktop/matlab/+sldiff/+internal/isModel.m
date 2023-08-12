function tf = isModel( file )




R36
file{ mustBeTextScalar }
end 

if ~isfile( file )
tf = false;
return ;
end 

fmt = Simulink.loadsave.identifyFileFormat( file );
tf = any( strcmpi( fmt, [ "slx", "mdl", "opcmdl" ] ) );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpwufwQn.p.
% Please follow local copyright laws when handling this file.


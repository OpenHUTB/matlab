function msg = newmodelfile( filename )






start_simulink;
[ ~, modelname ] = slfileparts( filename );
try 
new_system( modelname );
save_system( modelname, filename );
msg = '';
catch E
msg = E.message;
end 
close_system( modelname, 0 );

end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpmHFJxV.p.
% Please follow local copyright laws when handling this file.


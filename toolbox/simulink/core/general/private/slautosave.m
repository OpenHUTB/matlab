function slautosave( command, filename )





mlock;
persistent autosave_object_instance;


if strcmp( command, 'tofront' )

if ~isempty( autosave_object_instance )
if ( autosave_object_instance.numFiles(  ) ~= 0 )
autosave_object_instance.toFront(  );
end 
end 
end 

if strcmp( command, 'add' )
if isempty( autosave_object_instance )
autosave_object_instance = Simulink.autosave;
end 
autosave_object_instance.newFile( filename );
end 

if strcmp( command, 'remove' )
if ~isempty( autosave_object_instance )
if ( autosave_object_instance.numFiles(  ) ~= 0 )
autosave_object_instance.removeFile( filename );
end 
end 
end 

if strcmp( command, 'close' )

if ~isempty( autosave_object_instance )
delete( autosave_object_instance );
autosave_object_instance = [  ];
end 
end 

if strcmp( command, 'release' )


autosave_object_instance = [  ];
end 

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp6K69Wq.p.
% Please follow local copyright laws when handling this file.


function notify_save( filename, newFile )




if ~usejava( 'jvm' ) ...
 || ~exist( filename, 'file' )

return ;
end 

fileSystemNotifier = com.mathworks.util.FileSystemUtils.getFileSystemNotifier(  );
javaFile = java.io.File( filename );
if ( newFile )
fileSystemNotifier.created( javaFile );
else 
fileSystemNotifier.changed( javaFile );
end 

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpArUvN7.p.
% Please follow local copyright laws when handling this file.


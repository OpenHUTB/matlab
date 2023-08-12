function taskName = updateTaskNameMappingFile( modelName, taskName, numTaskBlocks )




if isequal( numTaskBlocks, 1 ), mode = 'w';else , mode = 'a';end 
if codertarget.utils.isESBEnabled( modelName )
bdir = RTW.getBuildDir( modelName );
fName = [ modelName, '_mapping.txt' ];
mapFileFullPath = fullfile( bdir.BuildDirectory, fName );
try 
fid = fopen( mapFileFullPath, mode );
aliasTaskName = [ '_socbAT', num2str( numTaskBlocks ) ];
fprintf( fid, 'ActualName = %s, AliasName = %s\n',  ...
taskName, aliasTaskName );
fclose( fid );
taskName = aliasTaskName;
catch me %#ok<NASGU>
fclose( fid );
end 
end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmp7cfo0M.p.
% Please follow local copyright laws when handling this file.


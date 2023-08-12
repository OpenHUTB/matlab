function outputPath = replaceToken( inputPath, boardName )




tgtFolder = soc.internal.getTargetFolder( boardName );
outputPath = strrep( inputPath, '$(TARGET_ROOT)', tgtFolder );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpvKvCQ6.p.
% Please follow local copyright laws when handling this file.


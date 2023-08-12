
function validateSharedUtils( modelName, dstDir, topSharedUtilsDir )






dstSharedUtilsChecksumFile = fullfile( dstDir, 'checksummap.mat' );
topSharedUtilsChecksumFile = fullfile( topSharedUtilsDir, 'checksummap.mat' );
if exist( dstSharedUtilsChecksumFile, 'file' ) == 2 &&  ...
exist( topSharedUtilsChecksumFile, 'file' ) == 2
tflChecksumDst = load( dstSharedUtilsChecksumFile );
tflChecksumTop = load( topSharedUtilsChecksumFile );
diff = coder.internal.compareStructures( tflChecksumDst.hashTbl.targetInfoStruct, tflChecksumTop.hashTbl.targetInfoStruct );

if ~isempty( diff )

err = coder.internal.SharedUtilsException( 'RTW:buildProcess:infoMATFileMgrBuildDirInconsistent',  ...
modelName,  ...
topSharedUtilsDir,  ...
tflChecksumDst.hashTbl.targetInfoStruct,  ...
tflChecksumTop.hashTbl.targetInfoStruct,  ...
diff,  ...
'',  ...
modelName,  ...
topSharedUtilsDir );
throw( err );
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpdolBaL.p.
% Please follow local copyright laws when handling this file.


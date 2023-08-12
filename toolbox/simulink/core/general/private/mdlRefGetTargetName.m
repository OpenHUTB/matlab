



function [ oTgtShortName, oTgtLongName ] = mdlRefGetTargetName(  ...
iMdl, iTargetType, anchorDir, infoStruct, protected )






if strcmp( iTargetType, 'SIM' )
tgt = coder.internal.modelRefUtil( iMdl, 'getSimTargetName', protected );
file = which( tgt );
if isempty( file )
file = tgt;
end 
oTgtShortName = tgt;
oTgtLongName = file;
else 
oTgtLongName = loc_get_target_file_name( iMdl, infoStruct,  ...
anchorDir, iTargetType );

[ ~, name, ext ] = fileparts( oTgtLongName );
assert( ~isempty( ext ) );
oTgtShortName = [ name, ext ];
end 
end 





function targetFile = loc_get_target_file_name( iMdl, infoStruct,  ...
anchorDir, iTargetType )
fileExt = loc_get_file_extension( infoStruct );
targetFile = fullfile( infoStruct.srcDir, [ iMdl, fileExt ] );



parallelAnchorDir = coder.internal.infoMATFileMgr(  ...
'getParallelAnchorDir',  ...
iTargetType );
if isempty( parallelAnchorDir )
targetFile = fullfile( anchorDir, targetFile );
else 
targetFile = fullfile( parallelAnchorDir, targetFile );
end 
end 




function fileExt = loc_get_file_extension( infoStruct )
tgtLang = infoStruct.targetLanguage;
assert( strcmp( tgtLang, 'C' ) || strcmp( tgtLang, 'C++' ) );

if strcmp( tgtLang, 'C' )
fileExt = '.c';
elseif isfield( infoStruct, 'IsGPUCodegen' ) && infoStruct.IsGPUCodegen
fileExt = '.cu';
else 
fileExt = '.cpp';
end 
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpyv5PgO.p.
% Please follow local copyright laws when handling this file.


function [ forceRebuild, oReasonMdlRef ] = rebuild_check_globalvars_csc( binfo_cache, iTargetType, iMdl, tgtShortName )







forceRebuild = false;
if nargout > 1
assert( strcmp( iTargetType, 'SIM' ) || strcmp( iTargetType, 'RTW' ) )
oReasonMdlRef = '';
else 
assert( strcmp( iTargetType, 'NONE' ) )
end 

isCSCEq = true;

globalParamInfo = binfo_cache.globalsInfo.GlobalParamInfo;
packageList = globalParamInfo.CSCPackageList;

if ~isempty( packageList )



isCSCEq = loc_csc_compatible( packageList, binfo_cache );
end 

if ~isCSCEq
forceRebuild = true;
if ~strcmp( iTargetType, 'NONE' )
globalVarList = globalParamInfo.VarList;
oReasonMdlRef = sl( 'construct_modelref_message',  ...
'Simulink:slbuild:customStorageClassChangedCoder',  ...
'Simulink:slbuild:customStorageClassChangedSIM',  ...
iTargetType, tgtShortName, iMdl, globalVarList );
end 
end 
end 


function isEqual = loc_csc_compatible( packageList, binfo_cache )


sOldChecksums = binfo_cache.cscChecksums;
sNewChecksums = processcsc( 'GetCSCChecksums', packageList );
sNewChecksums = sNewChecksums.Checksum;

isEqual = isequal( sOldChecksums, sNewChecksums );

end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmp4OcWM1.p.
% Please follow local copyright laws when handling this file.


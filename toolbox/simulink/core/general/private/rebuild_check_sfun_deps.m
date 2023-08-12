function [ forceRebuild, oReasonMdlRef, oBSCause ] =  ...
rebuild_check_sfun_deps( binfo_cache, iTargetType,  ...
tgtShortName, iMdl, iVerbose, iBuildArgs )





forceRebuild = false;

oReasonMdlRef = '';
oBSCause = '';

sfcnInfo = binfo_cache.sfcnInfo;
sfcnSourceFileMap = binfo_cache.rebuildChecksums.sfcnSourceFileMap;

rapidAcceleratorIsActive = iBuildArgs.IsRapidAccelerator;

[ sfunDeps, missingSFcns ] =  ...
mdlRefComputeSFcnChecksums( sfcnInfo,  ...
sfcnSourceFileMap,  ...
iVerbose,  ...
iTargetType,  ...
rapidAcceleratorIsActive ...
 );

if ( ~isempty( missingSFcns ) )
forceRebuild = true;

oReasonMdlRef = '';
if ~strcmp( iTargetType, 'NONE' )
for i = 1:length( missingSFcns )
thisReason = sl( 'construct_modelref_message',  ...
'Simulink:slbuild:sfunctionDoesNotExistCoder',  ...
'Simulink:slbuild:sfunctionDoesNotExistSIM',  ...
iTargetType, tgtShortName, iMdl,  ...
missingSFcns{ i }.sfcn,  ...
missingSFcns{ i }.block );

oReasonMdlRef = [ oReasonMdlRef, thisReason, fprintf( '\n' ) ];%#ok<AGROW>
end 
end 
oBSCause = DAStudio.message( 'Simulink:slbuild:bs3MissingSFunction', missingSFcns{ 1 }.sfcn );
return ;
end 



prevChecksums = containers.Map( 'KeyType', 'char', 'ValueType', 'any' );
for i = 1:length( binfo_cache.rebuildChecksums.sfcnDepChecksums )
sfunction = binfo_cache.rebuildChecksums.sfcnDepChecksums( i ).SFunction;
dependency = binfo_cache.rebuildChecksums.sfcnDepChecksums( i ).Dependency;
checksum = binfo_cache.rebuildChecksums.sfcnDepChecksums( i ).Checksum;

if ( prevChecksums.isKey( sfunction ) )
detail = prevChecksums( sfunction );
else 
detail = containers.Map( 'KeyType', 'char', 'ValueType', 'char' );
end 

detail( dependency ) = checksum;
prevChecksums( sfunction ) = detail;
end 



for i = 1:length( sfunDeps )
sfcnName = sfunDeps( i ).SFunction;
dep = sfunDeps( i ).Dependency;
[ ~, name, ext ] = fileparts( dep );
key = [ name, ext ];

if ( prevChecksums.isKey( sfcnName ) )
detail = prevChecksums( sfcnName );
if ( detail.isKey( key ) )
prevChecksum = detail( key );
currChecksum = sfunDeps( i ).Checksum;

outOfDate = ~isequal( prevChecksum, currChecksum );
else 


outOfDate = true;
end 
else 


outOfDate = true;
end 

if ( outOfDate )
forceRebuild = true;
if ~strcmp( iTargetType, 'NONE' )
block = sfunDeps( i ).Block;

oReasonMdlRef = sl( 'construct_modelref_message',  ...
'Simulink:slbuild:sfunctionFileUpdatedCoder',  ...
'Simulink:slbuild:sfunctionFileUpdatedSIM',  ...
iTargetType, tgtShortName, iMdl, dep, sfcnName, block );
end 
oBSCause = DAStudio.message( 'Simulink:slbuild:bs3SFunctionDependencyChange',  ...
dep, sfcnName );
return ;
end 
end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpJPMLEr.p.
% Please follow local copyright laws when handling this file.


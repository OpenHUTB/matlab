function [ forceRebuild, oReason, oChangedType ] = rebuild_check_dynamic_enum_type( binfo_cache, iTargetType, iMdl, tgtShortName )




forceRebuild = false;
oReason = '';
oChangedType = '';

if slfeature( 'ModelRefDynamicEnumRebuildCheck' ) == 0
return ;
end 

prevChecksums = binfo_cache.dynamicEnumTypeChecksums;
if isempty( prevChecksums )
return ;
end 

currentChecksums = slInternal( 'compute_dynamic_enum_type_checksum', { prevChecksums.name } );
checksumMatch = isequal( prevChecksums, currentChecksums );

if ~checksumMatch
mdlsLoaded = load_model( iMdl );

if ~isempty( mdlsLoaded )
currentChecksums = slInternal( 'compute_dynamic_enum_type_checksum', { prevChecksums.name } );
checksumMatch = isequal( prevChecksums, currentChecksums );

if checksumMatch
close_models( mdlsLoaded );
end 
end 
end 

if ~checksumMatch
forceRebuild = true;

mismatch = any( [ prevChecksums.checksum ] ~= [ currentChecksums.checksum ], 1 );

changedChecksums = prevChecksums( mismatch );
sortedNames = sort( { changedChecksums.name } );
oChangedType = sortedNames{ 1 };

names = strjoin( sortedNames, ', ' );
oReason = sl( 'construct_modelref_message',  ...
'Simulink:slbuild:incompatibleDynamicEnumTypeCoder',  ...
'Simulink:slbuild:incompatibleDynamicEnumTypeSIM',  ...
iTargetType, tgtShortName, iMdl, names );
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmphtFCL6.p.
% Please follow local copyright laws when handling this file.


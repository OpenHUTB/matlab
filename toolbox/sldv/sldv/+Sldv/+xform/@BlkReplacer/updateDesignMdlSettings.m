function updateDesignMdlSettings( obj )






topMdlH = [  ];
if obj.MdlInlinerOnlyMode



topMdlH = obj.MdlInfo.ModelH;
else 


topMdlH = obj.MdlInfo.OrigModelH;
end 
isTopCompiled = Sldv.xform.MdlInfo.isMdlCompiled( topMdlH );
assert( ~isTopCompiled );

if ~Sldv.utils.isValidContainerMap( obj.SettingsCacheMdlRefMap )
obj.SettingsCacheMdlRefMap =  ...
containers.Map( 'KeyType', 'char', 'ValueType', 'any' );
else 
keys = obj.SettingsCacheMdlRefMap.keys;
obj.SettingsCacheMdlRefMap.remove( keys );
end 

modelQueue = {  };
modelQueue{ end  + 1 } = topMdlH;
mdlIdx = 1;
while mdlIdx <= length( modelQueue )
mdlH = modelQueue{ mdlIdx };
mdlName = get_param( mdlH, 'Name' );

if ~obj.SettingsCacheMdlRefMap.isKey( mdlName ) &&  ...
~isCompiled( mdlH )

origDirty = get_param( mdlH, 'Dirty' );

settingsCache = [  ];




if ~obj.MdlInlinerOnlyMode || mdlH ~= topMdlH
settingsCache.OldConfigSet = getActiveConfigSet( mdlH );

enableAllProps = true;
Sldv.utils.replaceConfigSetRefWithCopy( mdlH, enableAllProps );
end 

settingsCache = updateMdlRefBuildSettings( mdlH, settingsCache );


if ~obj.MdlInlinerOnlyMode
settingsCache = configSingleTaskingSettings( mdlH, settingsCache );
end 

set_param( mdlH, 'Dirty', origDirty );

obj.SettingsCacheMdlRefMap( mdlName ) = settingsCache;
end 




skipInactiveVariants = false;
mdlBlks = Sldv.utils.findModelBlocks( mdlName, skipInactiveVariants );

for i = 1:length( mdlBlks )
blockH = get_param( mdlBlks{ i }, 'Handle' );
refMdlH = obj.MdlInfo.deriveReferencedModelH( blockH );
modelQueue{ end  + 1 } = refMdlH;%#ok<AGROW>
end 
mdlIdx = mdlIdx + 1;
end 

end 

function out = isCompiled( modelH )
simStatus = get_param( modelH, 'SimulationStatus' );
out = strcmp( simStatus, 'paused' ) || strcmp( simStatus, 'compiled' );
end 

function settingsCache = updateMdlRefBuildSettings( modelH, settingsCache )
settingsCache.params.UpdateModelReferenceTargets = get_param( modelH, 'UpdateModelReferenceTargets' );
settingsCache.params.SignalResolutionControl = get_param( modelH, 'SignalResolutionControl' );

if any( strcmp( settingsCache.params.UpdateModelReferenceTargets, { 'IfOutOfDateOrStructuralChange', 'Force' } ) )
set_param( modelH, 'UpdateModelReferenceTargets', 'IfOutOfDate' );
else 
settingsCache.params = rmfield( settingsCache.params, 'UpdateModelReferenceTargets' );
end 

if strncmp( settingsCache.params.SignalResolutionControl, 'TryResolve', 10 )
set_param( modelH, 'SignalResolutionControl', 'UseLocalSettings' );
else 
settingsCache.params = rmfield( settingsCache.params, 'SignalResolutionControl' );
end 
end 

function settingsCache = configSingleTaskingSettings( modelH, settingsCache )
paramConfig = [  ];
paramConfig = sldvprivate( 'get_single_tasking_params', modelH, paramConfig );
if ~isempty( paramConfig )
paramNames = fieldnames( paramConfig );
for i = 1:length( paramNames )
settingsCache.params.( paramNames{ i } ) = get_param( modelH, paramNames{ i } );
set_param( modelH, paramNames{ i }, paramConfig.( paramNames{ i } ) );
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp0h1fbA.p.
% Please follow local copyright laws when handling this file.


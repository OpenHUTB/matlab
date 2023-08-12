function supportedModes = getSupportedAdapterModes( blkHdl )




component = systemcomposer.utils.getArchitecturePeer( blkHdl );
if isempty( component )
return ;
end 
assert( component.isAdapterComponent );

modeEnum = systemcomposer.internal.adapter.ModeEnums;

archName = bdroot( getfullname( blkHdl ) );
isSWArch = strcmp( get_param( archName, 'SimulinkSubDomain' ), 'SoftwareArchitecture' );
isAUTOSARArch = strcmp( get_param( archName, 'SimulinkSubDomain' ), 'AUTOSARArchitecture' );

supportedModes{ 1 } = modeEnum.None;
if isSWArch
supportedModes{ end  + 1 } = modeEnum.Merge;
elseif isAUTOSARArch
if slfeature( 'AutosarArchModelMergeBlock' ) > 0
supportedModes{ end  + 1 } = modeEnum.Merge;
end 
else 
supportedModes{ end  + 1 } = modeEnum.UnitDelay;
supportedModes{ end  + 1 } = modeEnum.RateTransition;
if slfeature( 'ArchitectureModelMergeSupport' )
supportedModes{ end  + 1 } = modeEnum.Merge;
end 
end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpTdehTo.p.
% Please follow local copyright laws when handling this file.


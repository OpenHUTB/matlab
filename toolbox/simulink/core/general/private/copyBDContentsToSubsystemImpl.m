function copyBDContentsToSubsystemImpl( bd, subsys )


















if nargin ~= 2
DAStudio.error( 'Simulink:modelReference:slBDCopyContentsToSSInvalidNumInputs' );
end 


try 
isBd = strcmpi( get_param( bd, 'type' ), 'block_diagram' );
catch 
isBd = false;
end 

if ~isBd
DAStudio.error( 'Simulink:modelReference:slBDCopyContentsToSSIn1Invalid' );
end 


try 
ssType = Simulink.SubsystemType( subsys );
isSubsys = ( ssType.isSubsystem && ~ssType.isStateflowSubsystem ) || ssType.isSubsystemBD;
catch 
isSubsys = false;
end 

if ~isSubsys
DAStudio.error( 'Simulink:modelReference:slBDCopyContentsToSSIn2Invalid' );
end 


ssBd = bdroot( subsys );
ssBdName = get_param( ssBd, 'name' );
ssBdSimStatus = get_param( ssBd, 'SimulationStatus' );
if ~strcmpi( ssBdSimStatus, 'stopped' )
DAStudio.error( 'Simulink:modelReference:slBadSimStatus', ssBdName, ssBdSimStatus );
end 


bdName = get_param( bd, 'name' );
if strcmpi( ssBdName, bdName )
DAStudio.error( 'Simulink:modelReference:slBDCopyContentsToSSInvalidInputs' );
end 


bdObj = get_param( bd, 'object' );
ssH = get_param( subsys, 'handle' );
bdObj.copyContentsToSS( ssH );






end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpJ6XsZv.p.
% Please follow local copyright laws when handling this file.


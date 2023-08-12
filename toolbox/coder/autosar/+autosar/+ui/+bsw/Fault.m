classdef Fault < handle






properties 
FaultName = '';
FaultType{ mustBeMember( FaultType, { 'Override', 'Inject', 'Custom' } ) } = 'Override';

OverrideSetting uint8 = 0b00000000;
InjectSetting double = 0;


TriggerType double = 0;
StartTime = '0';
end 

properties ( Constant )
triggerTypeOptions = { 'Always On', 'Timed', 'Condition' };
end 

methods ( Access = private )
function this = Fault(  )

end 

function loadFromSlFault( this, fault )
R36
this
fault Simulink.fault.Fault
end 
this.FaultName = fault.Name;


this.FaultType = "Custom";

if ~fault.hasBehavior

return ;
end 
this.TriggerType = find( strcmp( fault.TriggerType, this.triggerTypeOptions ) ) - 1;
if strcmp( fault.TriggerType, 'Timed' )
this.StartTime = num2str( fault.StartTime );
end 

faultPath = autosar.bsw.rte.FaultInjector.findFaultBlkInFaultMdl( fault );
if isempty( faultPath )

return ;
end 

overrideBlk = find_system( faultPath, 'MaskType', 'DemFaultOverride' );
if ~isempty( overrideBlk )
this.FaultType = "Override";
this.OverrideSetting = bitset( this.OverrideSetting, 1, uint8( strcmp( get_param( overrideBlk{ 1 }, 'TF_Value' ), 'on' ) ) );
this.OverrideSetting = bitset( this.OverrideSetting, 2, uint8( strcmp( get_param( overrideBlk{ 1 }, 'TFTOC_Value' ), 'on' ) ) );
this.OverrideSetting = bitset( this.OverrideSetting, 3, uint8( strcmp( get_param( overrideBlk{ 1 }, 'PDTC_Value' ), 'on' ) ) );
this.OverrideSetting = bitset( this.OverrideSetting, 4, uint8( strcmp( get_param( overrideBlk{ 1 }, 'CDTC_Value' ), 'on' ) ) );
this.OverrideSetting = bitset( this.OverrideSetting, 5, uint8( strcmp( get_param( overrideBlk{ 1 }, 'TNCSLC_Value' ), 'on' ) ) );
this.OverrideSetting = bitset( this.OverrideSetting, 6, uint8( strcmp( get_param( overrideBlk{ 1 }, 'TFSLC_Value' ), 'on' ) ) );
this.OverrideSetting = bitset( this.OverrideSetting, 7, uint8( strcmp( get_param( overrideBlk{ 1 }, 'TNCTOC_Value' ), 'on' ) ) );
this.OverrideSetting = bitset( this.OverrideSetting, 8, uint8( strcmp( get_param( overrideBlk{ 1 }, 'WIR_Value' ), 'on' ) ) );
return ;
end 

injectBlk = find_system( faultPath, 'MaskType', 'DemFaultInject' );
if ~isempty( injectBlk )
this.FaultType = "Inject";
faultType = get_param( injectBlk{ 1 }, 'FaultType' );
this.InjectSetting = find( strcmp( faultType, autosar.ui.bsw.FaultSpreadsheet.faultInjectOptions ) ) - 1;
return ;
end 
end 
end 

methods ( Static )
function uiFault = create( nameOrSlFault )
uiFault = autosar.ui.bsw.Fault;
if isa( nameOrSlFault, 'Simulink.fault.Fault' )
uiFault.loadFromSlFault( nameOrSlFault );
else 
uiFault.FaultName = nameOrSlFault;
end 
end 
end 
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmp7ExEJt.p.
% Please follow local copyright laws when handling this file.


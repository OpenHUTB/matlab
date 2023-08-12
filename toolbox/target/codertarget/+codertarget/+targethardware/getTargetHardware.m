function tgtHWInfo = getTargetHardware( inArg, product )




validateattributes( inArg, { 'char', 'Simulink.ConfigSet', 'Simulink.ConfigSetRef',  ...
'Simulink.CustomCC', 'coder.CodeConfig' }, {  } );
if nargin < 2
product = 'simulink';
end 
validatestring( product, { 'matlab', 'simulink' }, '', '''product''' );

tgtHWInfo = [  ];
if ischar( inArg )
tgtHWName = inArg;
tgtHWInfo = codertarget.targethardware.getTargetHardwareFromName( tgtHWName, product );
elseif isa( inArg, 'coder.CodeConfig' )
cfg = inArg;
if isprop( cfg, 'Hardware' ) && ~isempty( cfg.Hardware )



tgtHWName = cfg.Hardware.Name;
tgtHWInfo = codertarget.targethardware.getTargetHardwareFromName( tgtHWName, 'matlab' );
if numel( tgtHWInfo ) > 1
tgtHWInfo = codertarget.targethardware.getTargetHardwareFromNameForEC( tgtHWName, 'matlab' );
end 
end 
else 
cs = inArg.getConfigSet(  );
data = codertarget.data.getData( cs );
if ~isempty( data )
tgtHWName = data.TargetHardware;
switch get_param( cs, 'HardwareBoardFeatureSet' )
case 'EmbeddedCoderHSP'
tgtHWInfo = codertarget.targethardware.getTargetHardwareFromNameForEC( tgtHWName, product );
case 'SoCBlockset'
tgtHWInfo = codertarget.targethardware.getTargetHardwareFromNameForSoC( tgtHWName, product );
end 
end 
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpUySM2M.p.
% Please follow local copyright laws when handling this file.


function targetHardwareInfo = getTargetHardwareFromNameForSoC( targetHardwareName, product )







validateattributes( targetHardwareName, { 'char' }, {  } );
if nargin < 2
product = 'simulink';
end 
validatestring( product, { 'matlab', 'simulink' }, '', '''product''' );

targetHardwareInfo = codertarget.targethardware.getTargetHardwareFromName( targetHardwareName, product );
if numel( targetHardwareInfo ) == 1
if targetHardwareInfo.BaseProductID ~= codertarget.targethardware.BaseProductID.SOC



if ~codertarget.utils.isBoardSoCCompatible( targetHardwareName )
targetHardwareInfo = [  ];
end 
end 
elseif numel( targetHardwareInfo ) > 1


for i = 1:numel( targetHardwareInfo )
if targetHardwareInfo( i ).BaseProductID == codertarget.targethardware.BaseProductID.SOC
targetHardwareInfo = targetHardwareInfo( i );
break ;
end 
end 
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpnFfW46.p.
% Please follow local copyright laws when handling this file.


function res = isESBCompatible( hObj, varargin )






















if isa( hObj, 'Simulink.ConfigSet' ) ||  ...
isa( hObj, 'Simulink.ConfigSetRef' )
hCS = hObj;
elseif isa( hObj, 'CoderTarget.SettingsController' )
hCS = hObj.getConfigSet;
else 

hCS = getActiveConfigSet( hObj );
end 

res = false;

if codertarget.data.isParameterInitialized( hCS, 'TargetHardware' )
board = codertarget.data.getParameterValue( hCS, 'TargetHardware' );
if ~isequal( board, 'None' )
info = codertarget.targethardware.getTargetHardware( hCS );
if nargin == 1
reqcaps = 1;
else 
reqcaps = varargin{ 1 };
end 
res = ~isempty( info ) && ( bitand( info.ESBCompatible, reqcaps ) == reqcaps );
if ~isempty( info ) && isequal( info.ESBCompatible, 1 ) && res


res = ismember( board, codertarget.internal.getHardwareBoardsForInstalledSpPkgs( 'soc' ) );
end 
end 
end 
end 




% Decoded using De-pcode utility v1.2 from file /tmp/tmpGZL9P_.p.
% Please follow local copyright laws when handling this file.


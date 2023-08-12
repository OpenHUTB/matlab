function [ runID, dispNotification ] = private_sl_sdi( bd, metadata, stepping )



try 
[ runID, dispNotification ] = Simulink.sdi.internal.invokeSDI( bd, metadata, stepping );
catch me
if isempty( metadata ) || ~isfield( metadata, 'MenuSim' ) || ~metadata.MenuSim
throwAsCaller( me );
else 
titleStr = getString( message( 'SDI:sdi:ToolName' ) );
errordlg( me.message, titleStr );
end 
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpQoJzPv.p.
% Please follow local copyright laws when handling this file.


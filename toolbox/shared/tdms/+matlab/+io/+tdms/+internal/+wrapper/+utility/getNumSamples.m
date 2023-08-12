function dataType = getNumSamples( info, channelGroupName, channelName )




R36
info( 1, 1 )matlab.io.tdms.TdmsInfo
channelGroupName string
channelName string = string.empty
end 
import matlab.io.tdms.internal.wrapper.utility.*
dataType = find( info, channelGroupName, channelName ).NumSamples';
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpX_8Egx.p.
% Please follow local copyright laws when handling this file.


function writeNoTimeData( filePath, data, channelGroupName )



R36
filePath( 1, 1 )string
data table
channelGroupName( 1, 1 )string
end 
import matlab.io.tdms.internal.*
chNames = string( data.Properties.VariableNames );
for chName = chNames
wrapper.mex.writeData( filePath, wrapper.utility.formatMexWriteData( data.( chName ) ), channelGroupName, chName );
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmp6bAIek.p.
% Please follow local copyright laws when handling this file.


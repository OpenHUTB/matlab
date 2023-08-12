function writeProp( filePath, properties, channelGroupName, channelName )



R36
filePath( 1, 1 )string
properties table
channelGroupName( 1, 1 )string = ""
channelName( 1, 1 )string = ""
end 
import matlab.io.tdms.internal.wrapper.*
mex.writeProp( filePath, table2struct( utility.formatMexWriteProp( properties ) ), channelGroupName, channelName );
end 




% Decoded using De-pcode utility v1.2 from file /tmp/tmpHo67S6.p.
% Please follow local copyright laws when handling this file.


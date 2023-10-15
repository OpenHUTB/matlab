function writeProp( filePath, properties, channelGroupName, channelName )

arguments
    filePath( 1, 1 )string
    properties table
    channelGroupName( 1, 1 )string = ""
    channelName( 1, 1 )string = ""
end
import matlab.io.tdms.internal.wrapper.*
mex.writeProp( filePath, table2struct( utility.formatMexWriteProp( properties ) ), channelGroupName, channelName );
end


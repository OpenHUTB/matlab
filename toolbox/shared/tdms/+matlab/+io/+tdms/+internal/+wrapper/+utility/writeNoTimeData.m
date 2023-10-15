function writeNoTimeData( filePath, data, channelGroupName )

arguments
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

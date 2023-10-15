function dataType = getNumSamples( info, channelGroupName, channelName )

arguments
    info( 1, 1 )matlab.io.tdms.TdmsInfo
    channelGroupName string
    channelName string = string.empty
end
import matlab.io.tdms.internal.wrapper.utility.*
dataType = find( info, channelGroupName, channelName ).NumSamples';
end

function dataType = getMatlabDataType( info, channelGroupName, channelName )

arguments
    info( 1, 1 )matlab.io.tdms.TdmsInfo
    channelGroupName string
    channelName string = string.empty
end
import matlab.io.tdms.internal.wrapper.utility.*
dataType = toMatlabDataType( find( info, channelGroupName, channelName ).DataType );
end

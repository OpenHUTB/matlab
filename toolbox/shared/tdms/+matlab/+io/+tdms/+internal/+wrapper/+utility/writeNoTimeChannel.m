function writeNoTimeChannel( filePath, data, channelGroupName )

arguments
    filePath( 1, 1 )string
    data{ matlab.io.tdms.internal.validator.mustBeRegularTimeTable }
    channelGroupName( 1, 1 )string
end

import matlab.io.tdms.internal.*

wrapper.utility.writeNoTimeData( filePath, timetable2table( data, ConvertRowTimes = false ), channelGroupName );

[ propertyNames, propertyValues ] = wrapper.utility.getWaveformProperties( data );
chNames = string( data.Properties.VariableNames );
for chName = chNames
    tdmswriteprop( filePath, propertyNames, propertyValues,  ...
        ChannelGroupName = channelGroupName, ChannelName = chName );
end

end


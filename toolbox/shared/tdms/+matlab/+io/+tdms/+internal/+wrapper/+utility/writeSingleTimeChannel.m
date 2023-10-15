function writeSingleTimeChannel( filePath, data, channelGroupName )

arguments
    filePath( 1, 1 )string
    data timetable
    channelGroupName( 1, 1 )string
end

import matlab.io.tdms.internal.wrapper.*
utility.writeNoTimeData( filePath, timetable2table( data ), channelGroupName )
end

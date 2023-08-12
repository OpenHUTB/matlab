function writeSingleTimeChannel( filePath, data, channelGroupName )



R36
filePath( 1, 1 )string
data timetable
channelGroupName( 1, 1 )string
end 

import matlab.io.tdms.internal.wrapper.*
utility.writeNoTimeData( filePath, timetable2table( data ), channelGroupName )
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpBcCuuz.p.
% Please follow local copyright laws when handling this file.


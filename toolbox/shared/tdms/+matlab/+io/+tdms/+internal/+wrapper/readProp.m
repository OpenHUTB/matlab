function prop = readProp( filePath, channelGroupName, channelName )



R36
filePath( 1, 1 )string
channelGroupName( 1, 1 )string = ""
channelName( 1, 1 )string = ""
end 
import matlab.io.tdms.internal.wrapper.*
prop = utility.formatMexProp( struct2table( mex.readProp( filePath, channelGroupName, channelName ), AsArray = true ) );
end 




% Decoded using De-pcode utility v1.2 from file /tmp/tmpEIA3zw.p.
% Please follow local copyright laws when handling this file.


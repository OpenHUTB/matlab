function prop = readProp( filePath, channelGroupName, channelName )

arguments
    filePath( 1, 1 )string
    channelGroupName( 1, 1 )string = ""
    channelName( 1, 1 )string = ""
end
import matlab.io.tdms.internal.wrapper.*
prop = utility.formatMexProp( struct2table( mex.readProp( filePath, channelGroupName, channelName ), AsArray = true ) );
end


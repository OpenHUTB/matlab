classdef FullFileTdmsReader<matlab.io.tdms.internal.reader.FileOffsetTdmsReader

    methods
        function obj=FullFileTdmsReader(location,options,selectedChannelGroup,selectedChannels)
            obj@matlab.io.tdms.internal.reader.FileOffsetTdmsReader(location,options,selectedChannelGroup,selectedChannels,0);
        end
    end

    methods(Access=protected)
        function readSize=getActualReadSize(obj)
            readSize=obj.MaxReadSize;
        end
    end

end

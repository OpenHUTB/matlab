classdef(ConstructOnLoad)PublishEventData<event.EventData




    properties

Filepath
PublishFormat
SliceRangeStart
SliceRangeEnd

        Screenshot3D=[]
        SliceDirection=medical.internal.app.labeler.enums.SliceDirection.Transverse;

    end

    methods

        function data=PublishEventData(filepath,publishFormat,rangeStart,rangeEnd)

            data.Filepath=filepath;
            data.PublishFormat=publishFormat;
            data.SliceRangeStart=rangeStart;
            data.SliceRangeEnd=rangeEnd;

        end

    end

end
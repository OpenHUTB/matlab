classdef(ConstructOnLoad)UpdateThumbnailEventData<event.EventData





    properties

Show
Location

    end

    methods

        function data=UpdateThumbnailEventData(TF,pos)

            data.Show=TF;
            data.Location=pos;

        end

    end

end
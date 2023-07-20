classdef(ConstructOnLoad)RecentFileEventData<event.EventData




    properties

DataSource
DataFormat

    end

    methods

        function data=RecentFileEventData(source,formats)

            data.DataSource=source;
            data.DataFormat=formats;

        end

    end

end
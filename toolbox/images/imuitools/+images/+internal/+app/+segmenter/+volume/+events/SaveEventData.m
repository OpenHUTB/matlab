classdef(ConstructOnLoad)SaveEventData<event.EventData





    properties

Name
SaveAsLogical
SaveAsMATFile

    end

    methods

        function data=SaveEventData(name,isLogical,asMATFile)

            data.Name=name;
            data.SaveAsLogical=isLogical;
            data.SaveAsMATFile=asMATFile;

        end

    end

end
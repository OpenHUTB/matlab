classdef(ConstructOnLoad)DataDictionaryEventData<event.EventData


    properties
ddFile
ddChangeName
    end

    methods
        function obj=DataDictionaryEventData(file,name)

            obj.ddFile=file;
            obj.ddChangeName=name;
        end
    end
end


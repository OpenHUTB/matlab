classdef TargetNameData<event.EventData




    properties
oldName
newName
    end

    methods
        function data=TargetNameData(oldName,newName)
            data.oldName=oldName;
            data.newName=newName;
        end
    end
end

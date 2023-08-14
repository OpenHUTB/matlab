classdef DefaultTargetData<event.EventData




    properties
oldName
newName
    end

    methods
        function data=DefaultTargetData(oldName,newName)
            data.oldName=oldName;
            data.newName=newName;
        end
    end
end

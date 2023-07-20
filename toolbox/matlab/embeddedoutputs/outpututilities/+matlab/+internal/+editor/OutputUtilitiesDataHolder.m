classdef OutputUtilitiesDataHolder<handle



    properties
        editorId=''
        filePath=''
    end

    methods
        function set(obj,id,fPath)
            obj.editorId=id;
            obj.filePath=fPath;
        end

        function reset(obj)
            obj.editorId='';
            obj.filePath='';
        end
    end
end


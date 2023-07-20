classdef UniqueNameService<handle


    properties(Access=private)
        NameMap;
    end

    methods
        function obj=UniqueNameService
            obj.NameMap=containers.Map('KeyType','char','ValueType','int32');
        end

        function reset(obj)
            obj.NameMap.remove(obj.NameMap.keys());
        end

        function uniqueName=registerName(obj,baseName)



















            if obj.NameMap.isKey(baseName)
                count=obj.NameMap(baseName);
            else
                count=0;
            end






            uniqueName=join([baseName,num2str(count)],'');
            while obj.NameMap.isKey(uniqueName)
                count=count+1;
                uniqueName=join([baseName,num2str(count)],'');
            end


            obj.NameMap(baseName)=count;





            obj.NameMap(uniqueName)=0;
        end
    end
end
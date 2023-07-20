



classdef DistinctNameService<handle
    properties
        name_map;
    end
    methods

        function obj=DistinctNameService(names)
            if nargin<1
                names={};
            end
            obj.name_map=containers.Map('KeyType','char','ValueType','int32');
            obj.addNames(names);
        end
        function reset(obj)
            if(obj.name_map.Count>0)
                obj.name_map.remove(obj.name_map.keys());
            end
        end

        function uniq_id=distinguishName(obj,id)
            count=0;
            if(~obj.name_map.isKey(id))

                obj.name_map(id)=count;
                uniq_id=id;
            else

                count=1+obj.name_map(id);
                obj.name_map(id)=count;


                uniq_id=obj.distinguishName([id,num2str(count)]);
            end
            return;
        end

        function isuniq=isDistinguishName(obj,id)

            isuniq=~obj.name_map.isKey(id);
        end

        function addNames(obj,names)
            cellfun(@(n)obj.distinguishName(n),names,'UniformOutput',false);
        end
    end
end

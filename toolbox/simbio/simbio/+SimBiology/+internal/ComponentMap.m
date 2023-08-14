







classdef ComponentMap<handle
    properties(Access=public)
Map
    end

    methods
        function obj=ComponentMap(optionalComponents,optionalValues)
            if nargin==0
                obj.Map=containers.Map('KeyType','uint64','ValueType','any');
            else
                obj.Map=containers.Map({optionalComponents.SessionID},optionalValues);
            end
        end

        function tf=isKey(obj,componentKeys)
            if isempty(componentKeys)
                tf=false(size(componentKeys));
            else
                keys={componentKeys.SessionID};
                tf=isKey(obj.Map,keys);
            end
        end

        function vals=find(obj,componentKeys)
            if isempty(componentKeys)
                vals=[];
            else
                keys=reshape({componentKeys.SessionID},size(componentKeys));
                vals=values(obj.Map,keys);
                vals=cell2mat(vals);
            end
        end

        function n=getNumElements(obj)
            n=obj.Map.Count;
        end

        function insert(obj,componentKeys,values)
            keys={componentKeys.SessionID};
            if isscalar(keys)
                obj.Map(keys{1})=values;
            else
                map2=containers.Map(keys,values);
                obj.Map=[obj.Map;map2];
            end
        end

        function removeElement(obj,componentKeys)
            obj.Map.remove({componentKeys.SessionID});
        end
    end
end
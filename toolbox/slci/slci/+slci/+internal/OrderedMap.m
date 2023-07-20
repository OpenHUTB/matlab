


classdef OrderedMap<handle


    properties(Access=private,Transient)
        fMap=[];
        fOrderedKeys=[];
    end

    methods

        function obj=OrderedMap
            obj.fMap=containers.Map('KeyType','double','ValueType','any');
        end

        function out=keys(aObj)
            out=aObj.fOrderedKeys;
        end

        function out=isKey(aObj,aKey)
            out=aObj.fMap.isKey(aKey);
        end

        function out=value(aObj,aKey)
            out=aObj.fMap(aKey);
        end

        function out=values(aObj)
            out=aObj.fMap.values;
        end

        function AddEntryToMap(aObj,aKey,aValue)
            if aObj.fMap.isKey(aKey)
                tmp=aObj.fMap(aKey);
                tmp{end+1}=aValue;
                aObj.fMap(aKey)=tmp;
            else
                aObj.fMap(aKey)={aValue};
                aObj.fOrderedKeys(end+1)=aKey;
            end
        end

        function remove(aObj,aKey)
            aObj.fMap.remove(aKey);
            for i=1:numel(aObj.fOrderedKeys)
                if aObj.fOrderedKeys(i)==aKey
                    aObj.fOrderedKeys(i)=[];
                    return
                end
            end
        end

        function replace(aObj,aOldKey,aNewKey,aNewValue)
            if aObj.fMap.isKey(aNewKey)
                aObj.remove(aOldKey);
                aObj.AddEntryToMap(aNewKey,aNewValue);
            else
                aObj.fMap.remove(aOldKey);
                for i=1:numel(aObj.fOrderedKeys)
                    if aObj.fOrderedKeys(i)==aOldKey
                        aObj.fOrderedKeys(i)=aNewKey;
                        aObj.fMap(aNewKey)={aNewValue};
                        return
                    end
                end
            end
        end

    end
end

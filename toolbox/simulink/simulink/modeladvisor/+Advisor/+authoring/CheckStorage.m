classdef(Sealed=true)CheckStorage<handle




    properties(Access=private)
        DataMap;
    end

    methods(Access=private)
        function this=CheckStorage()
            this.DataMap=containers.Map('KeyType','char','ValueType','any');
        end
    end

    methods
        function data=getData(this,key)
            if this.DataMap.isKey(key)
                data=this.DataMap(key);
            else
                data=[];
            end
        end

        function setData(this,key,data)
            this.DataMap(key)=data;
        end
    end

    methods(Static)
        function this=getInstance()
            persistent SingleInstance;

            if isempty(SingleInstance)||~isvalid(SingleInstance)
                SingleInstance=Advisor.authoring.CheckStorage();
            end

            this=SingleInstance;
        end
    end
end


classdef MapStore<codergui.internal.util.Store




    properties(GetAccess=private,SetAccess=immutable)
        Data containers.Map
    end

    methods
        function this=MapStore()
            this.Data=containers.Map('KeyType','char','ValueType','any');
        end

        function value=read(this,key)
            value=this.Data(key);
        end

        function exists=has(this,key)
            exists=this.Data.isKey(key);
        end

        function write(this,key,value)
            this.Data(key)=value;
        end

        function remove(this,key)
            if this.has(key)
                this.Data.remove(key);
            end
        end

        function flush(~)
        end
    end
end

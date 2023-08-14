classdef Registrator<handle




    properties(SetAccess=private,GetAccess=private)
        map containers.Map
    end

    methods
        function this=Registrator()
            this.map=containers.Map('KeyType','double','ValueType','any');
        end


        function put(this,obj,entry)

            if isempty(entry)
                return
            end

            if this.map.isKey(double(obj))

                if~ismember(entry,this.map(double(obj)))
                    this.map(double(obj))=[this.map(double(obj)),entry];
                end
            else
                this.map(double(obj))=cellstr(entry);
            end
        end



        function ret=hasEntry(this,obj,entry)
            ret=false(numel(obj),1);
            for i=1:numel(ret)
                if this.map.isKey(double(obj(i)))
                    ret(i)=ismember(entry,this.map(double(obj(i))));
                end
            end
        end


        function removeKey(this,obj)
            for i=1:numel(obj)
                if this.map.isKey(double(obj(i)))
                    this.map.remove(double(obj(i)));
                end
            end
        end


        function ret=get(this,obj)
            ret=[];
            if this.map.isKey(double(obj))
                ret=this.map(double(obj));
            end
        end


        function ret=isKey(this,obj)
            ret=this.map.isKey(double(obj));
        end


        function removeEntry(this,obj,entry)
            if this.map.isKey(double(obj))
                entries=this.map(double(obj));
                this.map(double(obj))=entries(~strcmpi(entries,entry));
            end
        end


        function clear(this)
            keys=this.map.keys;
            for i=1:length(keys)
                this.map.remove(keys(i));
            end
        end
    end
end


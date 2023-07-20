


classdef AddData<handle&matlab.mixin.Copyable
    properties
        data={};
        type={};
    end
    methods
        function clear(obj)
            if numel(obj)==1
                one=obj(1);
                one.data={};
                one.type={};
            else
                for i=1:numel(obj)
                    one=obj(i);
                    one.clear();
                end
            end
        end
        function init(obj,value)
            if numel(obj)==1
                obj.data=value;
                obj.type=class(value);
            else
                for i=1:numel(obj)
                    one=obj(i);
                    one.init(value);
                end
            end
        end
        function set.data(obj,value)
            if isempty(value)
                obj.data={};
                obj.type={};
            elseif isempty(obj.type)
                obj.data=value;
                obj.type=class(value);
            else
                try
                    obj.data=cast(value,obj.type);
                catch
                    obj.data=value;
                end
            end
        end
    end
end


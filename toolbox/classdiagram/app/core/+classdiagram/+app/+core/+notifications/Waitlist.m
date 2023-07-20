classdef Waitlist<handle

    properties(Access=private)
        Items;
    end

    methods
        function obj=Waitlist()
            obj.Items=containers.Map;
        end

        function add(obj,key,val)
            obj.Items(key)=val;
        end

        function items=getAllAndClear(obj)
            items=values(obj.Items);
            obj.Items=containers.Map;
        end

        function remove(obj,key)
            if obj.Items.isKey(key)
                remove(obj.Items,key);
            end
        end
    end
end
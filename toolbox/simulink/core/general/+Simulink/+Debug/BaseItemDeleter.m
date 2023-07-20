




classdef BaseItemDeleter<handle
    properties
        item=[];
    end

    methods
        function obj=BaseItemDeleter(item)
            obj.item=item;
        end

        function execute(obj)
            obj.item.prepareForDeletion();
            delete(obj.item);
            obj.item=[];
        end
    end
end


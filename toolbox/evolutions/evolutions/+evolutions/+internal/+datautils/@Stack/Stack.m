classdef Stack<handle




    properties(Access=private)
Data
    end

    methods(Access=public)
        function obj=Stack(class)
            obj.Data=eval(sprintf('%s.empty(1,0)',class));
        end

        element=top(obj)

        push(obj,element)

        pop(obj)

        tf=isempty(obj)

        num=size(obj)

    end
end






classdef Node<handle


    properties
in
out
    end

    methods(Access=public)
        function addOutEdge(obj,edgeHdl)
            obj.out=[obj.out;edgeHdl];
        end
        function addInEdge(obj,edgeHdl)
            obj.in=[obj.in;edgeHdl];
        end

        function yesno=equals(obj1,obj2)



            yesno=isequal(obj1,obj2);
        end
    end
end
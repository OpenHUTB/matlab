




classdef Edge<handle



    properties
source
sink
    end








    methods(Access=public)

        function yesno=equals(obj1,obj2)

            yesno=(obj1.source==obj2.source)&&...
            (obj1.sink==obj2.sink);
        end

        function obj=Edge(src,sink)
            obj.source=src;
            obj.sink=sink;
        end
    end

end
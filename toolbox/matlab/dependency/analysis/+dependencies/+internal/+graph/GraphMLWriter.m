classdef GraphMLWriter<dependencies.internal.graph.GraphWriter




    properties(Constant)
        Extensions=".graphml";
    end

    methods

        function write(~,graph,file,root)
            dependencies.internal.graph.writeGraphML(file,root,graph);
        end

    end

end

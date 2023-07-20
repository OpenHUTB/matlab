classdef SimulinkNodeHandler<dependencies.internal.action.NodeHandler




    properties(Constant)
        NodeFilter=dependencies.internal.graph.NodeFilter.fileExtension([".mdl",".slx"]);
        DefaultDependencyHandler=dependencies.internal.action.dependency.HiliteBlockHandler;
    end

    methods

        function open(~,node)
            if length(node.Location)>2
                open_system(node.Location{2});
                open(Simulink.BlockPath(node.Location(3:end)));
            else
                open_system(node.Location{1});
            end
        end

        function restore=edit(~,node)
            [wasLoaded,handle]=checkIfLoadedThenLoadSystem(node.Location{1});
            if wasLoaded
                restore=@()[];
            else
                restore=@()close_system(handle);
            end

            [~,name]=fileparts(node.Location{1});
            if strcmp(get_param(name,'BlockDiagramType'),'library')
                set_param(name,'Lock','off');
            end
        end

        function save(~,node)
            [~,model]=fileparts(node.Location{1});
            save_system(model);
        end

        function close(~,node)
            [~,model]=fileparts(node.Location{1});
            close_system(model);
        end

    end

end

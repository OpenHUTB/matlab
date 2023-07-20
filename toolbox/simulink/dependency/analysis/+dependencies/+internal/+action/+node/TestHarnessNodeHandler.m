classdef TestHarnessNodeHandler<dependencies.internal.action.NodeHandler




    properties(Constant)
        NodeFilter=dependencies.internal.graph.NodeFilter.nodeType(...
        dependencies.internal.analysis.simulink.TestHarnessAnalyzer.TestHarnessType);
        DefaultDependencyHandler=dependencies.internal.action.dependency.HiliteBlockHandler;
    end

    methods

        function open(~,node)
            open_system(node.Location{1});
            sltest.harness.open(node.Location{2:3});
        end

        function restore=edit(~,node)
            [systemWasLoaded,handle]=checkIfLoadedThenLoadSystem(node.Location{1});
            harnessOwner=node.Location{2};
            harnessName=node.Location{3};
            harnessList=sltest.harness.find(harnessOwner,"Name",harnessName);
            harnessWasLoaded=~isempty(harnessList)&&harnessList(1).isOpen;
            sltest.harness.load(harnessOwner,harnessName);
            function restoreClosure()
                if~harnessWasLoaded
                    sltest.harness.close(harnessOwner,harnessName);
                end
                if~systemWasLoaded
                    close_system(handle);
                end
            end
            restore=@()restoreClosure();
        end

        function save(~,node)
            save_system(node.Location{1});
        end

        function close(~,node)
            close_system(node.Location{1});
        end

    end

end

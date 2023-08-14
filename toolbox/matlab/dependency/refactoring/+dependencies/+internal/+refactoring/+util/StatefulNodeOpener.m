classdef StatefulNodeOpener<handle




    properties(SetAccess=immutable)
        Node(1,:)dependencies.internal.graph.Node;
    end

    properties
        cleanUpCallback(1,1)function_handle=@()[];
    end

    methods
        function this=StatefulNodeOpener(node)
            this.Node=node;
        end

        function edit(this)
            this.cleanUpCallback=dependencies.internal.action.edit(this.Node);
        end

        function saveAndClose(this)
            dependencies.internal.action.save(this.Node);
            this.cleanUpCallback();
        end
    end
end

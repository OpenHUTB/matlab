





classdef ResultsExplorerModel<handle

    properties(SetAccess=private)

        Node(1,1)



        Path(1,:)cell


VarName
    end

    methods

        function this=ResultsExplorerModel(node,path,varName)
            this.Node=node;
            this.Path=path;
            this.VarName=varName;
        end

        function updateMdlNode(this,newNode,newVarName)
            this.Node=newNode;
            this.VarName=newVarName;
        end

    end
end
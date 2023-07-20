classdef Scope<internal.ml2pir.scope.AbstractScope




    properties(GetAccess=public,SetAccess=immutable)
        Parent(1,1)internal.ml2pir.scope.AbstractScope=internal.ml2pir.scope.ScopeTail;
    end

    properties(GetAccess=protected,SetAccess=immutable)
        VarMap containers.Map;
        GraphBuilder;
    end

    methods(Access=public)

        function this=Scope(parent,builder)
            this.Parent=parent;
            this.VarMap=containers.Map;
            this.GraphBuilder=builder;
        end



        function names=getVariables(this)
            names=this.VarMap.keys;
        end

    end

    methods(Access=protected)

        function[foundNode,nodeInfo]=getNodeInfo(this,name)
            foundNode=this.VarMap.isKey(name);

            if foundNode
                nodeInfo=this.VarMap(name);
            else
                [foundNode,nodeInfo]=this.Parent.getNodeInfo(name);
            end
        end

        function setNodeInfo(this,name,nodeInfo)
            this.VarMap(name)=nodeInfo;
            if~isa(nodeInfo,'internal.ml2pir.scope.FromSubGraphNodeInfo')
                this.GraphBuilder.setSignalName(nodeInfo.node,name);
            end
        end

    end

end

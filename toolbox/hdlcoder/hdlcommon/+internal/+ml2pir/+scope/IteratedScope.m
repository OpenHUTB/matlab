classdef IteratedScope<internal.ml2pir.scope.Scope









    properties(GetAccess=private,SetAccess=immutable)
ParentGraphNode
IterGraphNode
IterNode
        StreamInfo(1,1)internal.ml2pir.utils.LoopStreamInfo=...
        internal.ml2pir.utils.LoopStreamInfo('','',1,1,'')
        VarsFromParentMap containers.Map
        VarsToFeedbackMap containers.Map
    end

    methods(Access=public)

        function this=IteratedScope(parent,builder,...
            parentGraphNode,iterGraphNode,iterNode,streamInfo)
            this=this@internal.ml2pir.scope.Scope(parent,builder);
            this.ParentGraphNode=parentGraphNode;
            this.IterGraphNode=iterGraphNode;
            this.IterNode=iterNode;
            this.StreamInfo=streamInfo;
            this.VarsFromParentMap=containers.Map;
            this.VarsToFeedbackMap=containers.Map;
        end

        function[iterNode,iterType,iterStart,iterStep]=getIterNode(this)
            iterNode=this.IterNode;
            iterType=this.StreamInfo.iterType;
            iterStart=this.StreamInfo.start;
            iterStep=this.StreamInfo.step;
        end



        function finalizeAndPropagateToParent(this)
            this.GraphBuilder.setSubGraph(this.IterGraphNode);

            varNames=this.VarMap.keys;

            for i=1:numel(varNames)
                name=varNames{i};
                nodeInfo=this.VarMap(name);

                if this.VarsFromParentMap.isKey(name)




                    assert(~this.VarsToFeedbackMap.isKey(name));

                    inp=this.VarsFromParentMap(name).inp;
                    dummyNode=this.VarsFromParentMap(name).node;
                    this.GraphBuilder.connect(inp,dummyNode);
                else
                    if this.VarsToFeedbackMap.isKey(name)


                        currNode=nodeInfo.node;
                        delayNode=this.VarsToFeedbackMap(name);
                        this.GraphBuilder.connect(currNode,delayNode);

                        this.VarsToFeedbackMap.remove(name);
                    end



                    sgNodeInfo=internal.ml2pir.scope.FromSubGraphNodeInfo(...
                    nodeInfo,name,this.GraphBuilder,this.IterGraphNode);

                    this.Parent.setNodeInfo(name,sgNodeInfo);
                end
            end


            assert(isempty(this.VarsToFeedbackMap));

            this.GraphBuilder.endSubGraph;
        end

    end

    methods(Access=protected)

        function[foundNode,nodeInfo]=getNodeInfo(this,name)

            foundNode=this.VarMap.isKey(name);

            if foundNode
                nodeInfo=this.VarMap(name);
            else

                [foundNode,parentNodeInfo]=this.Parent.getNodeInfo(name);

                if foundNode



                    [nodeInfo,fromParentMapStruct]=this.importVarFromParent(name,parentNodeInfo);


                    this.setNodeInfo(name,nodeInfo);


                    this.VarsFromParentMap(name)=fromParentMapStruct;
                else

                    nodeInfo=parentNodeInfo;
                end
            end
        end

        function setNodeInfo(this,name,nodeInfo)



            if this.VarsFromParentMap.isKey(name)
                this.createDelayForVarFromParent(name,nodeInfo.type);
            end

            this.setNodeInfo@internal.ml2pir.scope.Scope(name,nodeInfo);
        end

    end

    methods(Access=private)

        function createDelayForVarFromParent(this,name,nodeType)
            assert(this.VarsFromParentMap.isKey(name));
            inpNode=this.VarsFromParentMap(name).inp;
            dummyNode=this.VarsFromParentMap(name).node;

            this.GraphBuilder.setSubGraph(this.IterGraphNode);



            delayNode=this.GraphBuilder.createUnitDelayNode('',...
            internal.mtree.NodeTypeInfo(nodeType,nodeType));



            switchNode=internal.ml2pir.utils.switchOnIterations(...
            this.GraphBuilder,this,{inpNode,delayNode},nodeType);




            this.GraphBuilder.connect(switchNode,dummyNode);

            this.GraphBuilder.endSubGraph;



            this.VarsFromParentMap.remove(name);
            this.VarsToFeedbackMap(name)=delayNode;
        end

        function[nodeInfo,mapStruct]=importVarFromParent(this,name,parentNodeInfo)
            parentNode=parentNodeInfo.node;
            nodeType=parentNodeInfo.type;

            this.GraphBuilder.setSubGraph(this.IterGraphNode);

            if isa(parentNode,'internal.mtree.Constant')


                inp=parentNode;
            else



                [inp,inpIdx]=this.GraphBuilder.addInput(name,...
                internal.mtree.NodeTypeInfo([],nodeType));

                this.GraphBuilder.setSubGraph(this.ParentGraphNode);
                this.GraphBuilder.connect(parentNode,{this.IterGraphNode,inpIdx});
                this.GraphBuilder.endSubGraph;
            end





            node=this.GraphBuilder.createNoopNode('',...
            internal.mtree.NodeTypeInfo(nodeType,nodeType));

            this.GraphBuilder.endSubGraph;

            nodeInfo=internal.ml2pir.scope.NodeInfo(node,nodeType);
            mapStruct=struct('inp',{inp},'node',{node});
        end

    end

end



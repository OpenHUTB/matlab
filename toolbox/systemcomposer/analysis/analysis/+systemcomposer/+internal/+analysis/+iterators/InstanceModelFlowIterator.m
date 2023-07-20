classdef InstanceModelFlowIterator<internal.systemcomposer.AbstractIterator




    properties(Access=protected)
        Root;
        CurrentElement;
        sortedList;
        index;
        incoming=[];
        outgoing=[];
        IncludePorts=false;
        IncludeConnectors=false;
        graph=[];
        elements;
        Algorithm;
        Recurse=true;
    end
    methods(Access='private')
        function graph=addGraph(this,instance,graph)

            nodeList={};
            nodeUUID={};
            if instance.isArchitecture


                portArray=instance.Ports;
                for pi=1:length(portArray)
                    nodeList{pi}=portArray(pi).QualifiedName;
                    nodeUUID{pi}=portArray(pi).getUUID;
                end
            end


            nodeArray=instance.Components;

            for pi=1:length(nodeArray)
                nodeList{end+1}=nodeArray(pi).QualifiedName;
                nodeUUID{end+1}=nodeArray(pi).getUUID;
            end

            nodeTable=table(nodeList',nodeUUID','VariableNames',{'Name','UUID'});

            graph=addnode(graph,nodeTable);


            for pi=1:length(nodeArray)
                node=nodeArray(pi);
                nodeIdx=node.QualifiedName;

                nodePorts=node.Ports;
                for cpi=1:length(nodePorts)
                    port=nodePorts(cpi);
                    newEdges=table({port.QualifiedName}',{port.getUUID}',1',...
                    'VariableNames',{'QualifiedName','UUID','Weight'});
                    portTable=table({port.QualifiedName}',{port.getUUID}','VariableNames',{'Name','UUID'});
                    graph=addnode(graph,portTable);
                    if port.Specification.Direction==systemcomposer.arch.PortDirection.Output
                        graph=addedge(graph,nodeIdx,port.QualifiedName,newEdges);
                    else
                        graph=addedge(graph,port.QualifiedName,nodeIdx,newEdges);
                    end
                end
            end


            connectors=instance.Connectors;
            for c=1:length(connectors)
                connector=connectors(c);
                ports=connector.Ports;
                if numel(ports)>1
                    newEdges=table({connector.QualifiedName}',{connector.QualifiedName}',1',...
                    'VariableNames',{'QualifiedName','UUID','Weight'});
                    sourceIdx=ports{1}.QualifiedName;
                    for pIdx=2:numel(ports)
                        destIdx=ports{pIdx}.QualifiedName;
                        graph=addedge(graph,sourceIdx,destIdx,newEdges);
                    end
                end
            end
        end

        function fullVisit(this,instance,varargin)

            if strcmp(instance.getUUID,this.Root.getUUID)||this.Recurse
                if~isempty(instance.Components)
                    this.graph=this.addGraph(instance,this.graph);
                    this.graph=rmnode(this.graph,instance.QualifiedName);
                end
            end
        end
    end
    methods

        function w=begin(this,startNode,source,dest,weightProperty)
            this.Root=startNode;


            this.graph=digraph();
            this.Root.iterate('topdown',@this.fullVisit,...
            'IncludePorts',false,'IncludeConnectors',false,'Recurse',this.Recurse);

            if~(isempty(weightProperty)||isempty(this.graph.Edges))

                for e=1:length(this.graph.Edges.QualifiedName)
                    element=this.Root.lookup('Path',this.graph.Edges.QualifiedName(e));
                    if element.isConnector
                        this.graph.Edges.Weight(e)=element.getValue(weightProperty);
                    else
                        this.graph.Edges.Weight(e)=element.getValue(weightProperty)/2;
                    end
                end
            end

            if this.Algorithm==systemcomposer.FlowAlgorithm.ShortestPath
                [order,w,edgepath]=shortestpath(this.graph,source.QualifiedName,dest.QualifiedName);
                if~isempty(order)
                    UUID=order(1);
                    path={this.Root.lookup('Path',UUID{1})};
                    for i=2:length(order)
                        UUID=order(i);
                        edgeUUID=this.graph.Edges.QualifiedName(edgepath(i-1));
                        edgeElement=this.Root.lookup('Path',edgeUUID{1});
                        if edgeElement.isConnector
                            path{end+1}=edgeElement;
                        end
                        path{end+1}=this.Root.lookup('Path',UUID{1});
                    end
                    this.elements=path;
                else
                    this.elements={};
                    w=0;
                end
            elseif this.Algorithm==systemcomposer.FlowAlgorithm.MaximumFlow
                [w,flowGraph,cs,ct]=maxflow(this.graph,source.QualifiedName,dest.QualifiedName);
            elseif this.Algorithm==systemcomposer.FlowAlgorithm.All
                [e,edge_indices]=dfsearch(this.graph,1,'edgetodiscovered','Restart',true);
                aCyclicGraph=rmedge(this.graph,edge_indices);
                order=toposort(aCyclicGraph);
                if~isempty(order)
                    UUID=this.graph.Nodes.Name(order(1));
                    path={this.Root.lookup('Path',UUID)};
                    for i=2:length(order)
                        UUID=this.graph.Nodes.Name(order(i));
                        node=this.Root.lookup('Path',UUID);
                        if node.isPort
                            ci=inedges(this.graph,UUID);
                            if isempty(ci)
                                edgeElement=[];
                            else
                                edgeUUID=this.graph.Edges.QualifiedName(ci);
                                edgeElement=this.Root.lookup('Path',edgeUUID);
                            end

                            if~isempty(edgeElement)&&edgeElement.isConnector
                                path{end+1}=edgeElement;
                            end
                        end
                        path{end+1}=node;
                    end
                    this.elements=path;
                else
                    this.elements={};
                end
                w=0;
            end
            this.index=1;
            this.next;
        end

        function elem=getElement(this)

            elem=this.CurrentElement;
        end

        function next(this)
            if this.index>length(this.elements)
                this.CurrentElement=[];
            else
                this.CurrentElement=this.elements{this.index};
                this.index=this.index+1;
            end


































        end

        function this=InstanceModelFlowIterator(direction,algorithm,recurse,includePorts,includeConnectors)
            this@internal.systemcomposer.AbstractIterator(direction);
            narginchk(2,5);
            this.Algorithm=algorithm;
            if nargin>2
                this.Recurse=recurse;

                if nargin>3
                    this.IncludePorts=includePorts;
                    if nargin>4
                        this.IncludeConnectors=includeConnectors;

                    end
                end
            end
        end
    end
    methods(Access='protected')

        function actualStartNode=validateStartNode(this,startNode)
            actualStartNode=startNode;
        end
    end
end

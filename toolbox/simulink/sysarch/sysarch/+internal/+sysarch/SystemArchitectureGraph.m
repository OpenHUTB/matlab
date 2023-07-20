


classdef SystemArchitectureGraph<handle

    properties(GetAccess=public,SetAccess=private)
SystemModel
ArchGraph
    end

    methods(Access=public)
        function obj=SystemArchitectureGraph(systemModel,graphType)

            obj.SystemModel=systemModel;

            if(strcmpi(graphType,'Block'))
                obj.ArchGraph=blockConnGraph(obj,obj.SystemModel);
            elseif(strcmpi(graphType,'Port'))
                obj.ArchGraph=portConnGraph(obj,obj.SystemModel);
            else
                error('Invalid graphType parameter');
            end
        end



        function varargout=addedge(obj,varargin)
            [varargout{1:nargout}]=slprivate('addedge',obj.ArchGraph,varargin{:});
        end


        function varargout=rmedge(obj,varargin)
            [varargout{1:nargout}]=slprivate('rmedge',obj.ArchGraph,varargin{:});
        end


        function varargout=flipedge(obj,varargin)
            [varargout{1:nargout}]=slprivate('flipedge',obj.ArchGraph,varargin{:});
        end


        function varargout=addnode(obj,varargin)
            [varargout{1:nargout}]=slprivate('addnode',obj.ArchGraph,varargin{:});
        end


        function varargout=rmnode(obj,varargin)
            [varargout{1:nargout}]=slprivate('rmnode',obj.ArchGraph,varargin{:});
        end


        function varargout=numnodes(obj,varargin)
            [varargout{1:nargout}]=slprivate('numnodes',obj.ArchGraph,varargin{:});
        end


        function varargout=numedges(obj,varargin)
            [varargout{1:nargout}]=slprivate('numedges',obj.ArchGraph,varargin{:});
        end


        function varargout=findnode(obj,varargin)
            [varargout{1:nargout}]=slprivate('findnode',obj.ArchGraph,varargin{:});
        end


        function varargout=findedge(obj,varargin)
            [varargout{1:nargout}]=slprivate('findedge',obj.ArchGraph,varargin{:});
        end


        function varargout=reordernodes(obj,varargin)
            [varargout{1:nargout}]=slprivate('reordernodes',obj.ArchGraph,varargin{:});
        end


        function varargout=subgraph(obj,varargin)
            [varargout{1:nargout}]=slprivate('subgraph',obj.ArchGraph,varargin{:});
        end



        function varargout=bfsearch(obj,varargin)
            [varargout{1:nargout}]=slprivate('bfsearch',obj.ArchGraph,varargin{:});
        end


        function varargout=dfsearch(obj,varargin)
            [varargout{1:nargout}]=slprivate('dfsearch',obj.ArchGraph,varargin{:});
        end


        function varargout=centrality(obj,varargin)
            [varargout{1:nargout}]=slprivate('centrality',obj.ArchGraph,varargin{:});
        end


        function varargout=maxflow(obj,varargin)
            [varargout{1:nargout}]=slprivate('maxflow',obj.ArchGraph,varargin{:});
        end


        function varargout=conncomp(obj,varargin)
            [varargout{1:nargout}]=slprivate('conncomp',obj.ArchGraph,varargin{:});
        end


        function varargout=biconncomp(obj,varargin)
            [varargout{1:nargout}]=slprivate('biconncomp',obj.ArchGraph,varargin{:});
        end


        function varargout=condensation(obj,varargin)
            [varargout{1:nargout}]=slprivate('condensation',obj.ArchGraph,varargin{:});
        end


        function varargout=bctree(obj,varargin)
            [varargout{1:nargout}]=slprivate('bctree',obj.ArchGraph,varargin{:});
        end


        function varargout=minspantree(obj,varargin)
            [varargout{1:nargout}]=slprivate('minspantree',obj.ArchGraph,varargin{:});
        end


        function varargout=toposort(obj,varargin)
            [varargout{1:nargout}]=slprivate('toposort',obj.ArchGraph,varargin{:});
        end


        function varargout=isdag(obj,varargin)
            [varargout{1:nargout}]=slprivate('isdag',obj.ArchGraph,varargin{:});
        end


        function varargout=transclosure(obj,varargin)
            [varargout{1:nargout}]=slprivate('transclosure',obj.ArchGraph,varargin{:});
        end


        function varargout=transreduction(obj,varargin)
            [varargout{1:nargout}]=slprivate('transreduction',obj.ArchGraph,varargin{:});
        end


        function varargout=isisomorphic(obj,varargin)
            [varargout{1:nargout}]=slprivate('isisomorphic',obj.ArchGraph,varargin{:});
        end


        function varargout=isomorphism(obj,varargin)
            [varargout{1:nargout}]=slprivate('isomorphism',obj.ArchGraph,varargin{:});
        end



        function varargout=shortestpath(obj,varargin)
            [varargout{1:nargout}]=slprivate('shortestpath',obj.ArchGraph,varargin{:});
        end


        function varargout=shortestpathtree(obj,varargin)
            [varargout{1:nargout}]=slprivate('shortestpathtree',obj.ArchGraph,varargin{:});
        end


        function varargout=distances(obj,varargin)
            [varargout{1:nargout}]=slprivate('distances',obj.ArchGraph,varargin{:});
        end



        function varargout=adjacency(obj,varargin)
            [varargout{1:nargout}]=slprivate('adjacency',obj.ArchGraph,varargin{:});
        end


        function varargout=incidence(obj,varargin)
            [varargout{1:nargout}]=slprivate('incidence',obj.ArchGraph,varargin{:});
        end


        function varargout=laplacian(obj,varargin)
            [varargout{1:nargout}]=slprivate('laplacian',obj.ArchGraph,varargin{:});
        end



        function varargout=degree(obj,varargin)
            [varargout{1:nargout}]=slprivate('degree',obj.ArchGraph,varargin{:});
        end


        function varargout=neighbors(obj,varargin)
            [varargout{1:nargout}]=slprivate('neighbors',obj.ArchGraph,varargin{:});
        end


        function varargout=nearest(obj,varargin)
            [varargout{1:nargout}]=slprivate('nearest',obj.ArchGraph,varargin{:});
        end


        function varargout=indegree(obj,varargin)
            [varargout{1:nargout}]=slprivate('indegree',obj.ArchGraph,varargin{:});
        end


        function varargout=outdegree(obj,varargin)
            [varargout{1:nargout}]=slprivate('outdegree',obj.ArchGraph,varargin{:});
        end


        function varargout=predecessors(obj,varargin)
            [varargout{1:nargout}]=slprivate('predecessors',obj.ArchGraph,varargin{:});
        end


        function varargout=successors(obj,varargin)
            [varargout{1:nargout}]=slprivate('successors',obj.ArchGraph,varargin{:});
        end



        function varargout=plot(obj,varargin)
            [varargout{1:nargout}]=slprivate('plot',obj.ArchGraph,varargin{:});
        end


        function varargout=labelnode(~,varargin)
            [varargout{1:nargout}]=slprivate('labelnode',varargin{:});
        end


        function varargout=labeledge(~,varargin)
            [varargout{1:nargout}]=slprivate('labeledge',varargin{:});
        end


        function varargout=layout(~,varargin)
            [varargout{1:nargout}]=slprivate('layout',varargin{:});
        end


        function varargout=highlight(~,varargin)
            [varargout{1:nargout}]=slprivate('highlight',varargin{:});
        end

    end

    methods(Access=private)

        function G=blockConnGraph(~,systemModel)

            rootGraph=systemModel;

            blockNames=rootGraph.getComponentNames;
            rootPortNames=rootGraph.getPortNames;

            connections=rootGraph.getConnectors;

            G=digraph;
            G=G.addnode(blockNames);
            G=G.addnode(rootPortNames);

            for idx=1:numel(connections)

                srcPort=connections(idx).getSource;
                dstPort=connections(idx).getDestination;
                if(isa(srcPort,'systemcomposer.architecture.model.design.ArchitecturePort'))
                    srcBlkName=srcPort.getName;
                else
                    srcBlkName=srcPort.getComponent.getName;
                end
                if(isa(dstPort,'systemcomposer.architecture.model.design.ArchitecturePort'))
                    dstBlkName=dstPort.getName;
                else
                    dstBlkName=dstPort.getComponent.getName;
                end

                if(~G.findedge(srcBlkName,dstBlkName))
                    G=G.addedge(srcBlkName,dstBlkName,1);
                end

            end

        end

        function G=portConnGraph(~,systemModel)



            rootGraph=systemModel;

            blocks=rootGraph.getComponents;
            blockNames=rootGraph.getComponentNames;
            rootPortNames=rootGraph.getPortNames;

            connections=rootGraph.getConnectors;


            G=digraph;


            G=G.addnode(blockNames);
            G=G.addnode(rootPortNames);



            for idx=1:numel(blocks)
                if(numel(blocks(idx).getPorts)>0)

                    ports=blocks(idx).getPorts;
                    portNames=cell(1,numel(ports));
                    for portIdx=1:numel(ports)
                        portNames{portIdx}=[blocks(idx).getName,'_',ports(portIdx).getName];
                    end



                    G=G.addnode(portNames);

                    for portIdx=1:numel(ports)
                        currPort_name=[blocks(idx).getName,'_',ports(portIdx).getName];

                        if(ports(portIdx).getPortAction==systemcomposer.internal.arch.REQUEST&&...
                            ~G.findedge(currPort_name,blocks(idx).getName))

                            G=G.addedge(currPort_name,blocks(idx).getName);

                        elseif(ports(portIdx).getPortAction==systemcomposer.internal.arch.PROVIDE&&...
                            ~G.findedge(blocks(idx).getName,currPort_name))

                            G=G.addedge(blocks(idx).getName,currPort_name);
                        end

                    end
                end
            end



            for idx=1:numel(connections)
                srcPort=connections(idx).getSource;
                dstPort=connections(idx).getDestination;

                srcPortName=srcPort.getName;
                dstPortName=dstPort.getName;

                if(isa(srcPort,'systemcomposer.architecture.model.design.ArchitecturePort'))
                    srcPortFullName=srcPortName;
                else
                    srcPortCompName=srcPort.getComponent.getName;
                    srcPortFullName=[srcPortCompName,'_',srcPortName];
                end
                if(isa(dstPort,'systemcomposer.architecture.model.design.ArchitecturePort'))
                    dstPortFullName=dstPortName;
                else
                    dstPortCompName=dstPort.getComponent.getName;
                    dstPortFullName=[dstPortCompName,'_',dstPortName];
                end
                if(~G.findedge(srcPortFullName,dstPortFullName))
                    G=G.addedge(srcPortFullName,dstPortFullName);
                end

            end
        end
    end
end







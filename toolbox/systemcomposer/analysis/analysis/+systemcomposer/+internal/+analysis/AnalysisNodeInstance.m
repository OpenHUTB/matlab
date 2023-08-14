classdef AnalysisNodeInstance<systemcomposer.internal.analysis.AnalysisInstance



    properties

    end

    methods

        function clearDirtyFlag(obj)
            obj.mfObject.dirty=false;
        end
    end

    methods(Static)

        function filtered=filter(original,class)
            filtered={};
            for o=1:length(original)
                if isa(original(o),class)
                    filtered{end+1}=original(o);
                end
            end
        end

        function index=getIndex(source,node)
            index=-1;
            for n=1:length(source)
                if(source{n}==node)
                    index=n;
                    break;
                end
            end
        end

        function list=addIndex(list,index)
            if(index>0)
                list(end+1)=index;
            end
        end
    end

    methods
        function list=getOrderedList(this)

            children=this.mfObject.children.toArray;
            nodes=this.filter(children,'systemcomposer.internal.analysis.NodeInstance');

            connectors=this.filter(children,'systemcomposer.internal.analysis.ConnectorInstance');

            sources=[];
            dests=[];

            for c=1:length(connectors)
                connector=connectors{c};
                sourceIdx=this.getIndex(nodes,connector.source);
                destIdx=this.getIndex(nodes,connector.dest);

                if destIdx>=0&&sourceIdx>=0
                    sources=this.addIndex(sources,sourceIdx);
                    dests=this.addIndex(dests,destIdx);
                end
            end


            DG=sparse(sources,dests,true,length(nodes),length(nodes));
            bg=biograph(DG);
            bg.LayoutScale=3;
            order=bg.topoorder;
            dolayout(bg);
            list=[];
            for l=1:length(order)
                list=this.addNode(list,nodes{order(l)},bg.getnodesbyid(['Node ',num2str(order(l))]));
            end
        end

        function layoutChildren(this)

            children=this.mfObject.children.toArray;
            nodes=this.filter(children,'systemcomposer.internal.analysis.NodeInstance');

            connectors=this.filter(children,'systemcomposer.internal.analysis.ConnectorInstance');

            sources=[];
            dests=[];

            for c=1:length(connectors)
                connector=connectors{c};
                sourceIdx=this.getIndex(nodes,connector.source);
                destIdx=this.getIndex(nodes,connector.dest);

                if destIdx>=0&&sourceIdx>=0
                    sources=this.addIndex(sources,sourceIdx);
                    dests=this.addIndex(dests,destIdx);
                end
            end


            DG=sparse(sources,dests,true,length(nodes),length(nodes));
            bg=biograph(DG);
            bg.LayoutScale=3;
            order=bg.topoorder;
            dolayout(bg);

            for l=1:length(order)
                proxy=systemcomposer.internal.analysis.AnalysisNodeInstance(nodes{order(l)},this.model);
                proxy.setGeometry(bg.getnodesbyid(['Node ',num2str(order(l))]));
            end
        end

        function obj=AnalysisNodeInstance(mfObject,model)


            obj=obj@systemcomposer.internal.analysis.AnalysisInstance(mfObject,model);
        end

        function proxy=createProxy(obj,source)
            if isa(source,'systemcomposer.internal.analysis.NodeInstance')
                proxy=systemcomposer.internal.analysis.AnalysisNodeInstance(source,obj.model);
            else
                proxy=systemcomposer.internal.analysis.AnalysisConnectorInstance(source,obj.model);
            end
        end


        function children=getChildren(obj)
            if obj.mfObject.children.Size>0
                mfChildren=obj.mfObject.children.toArray;

                children=[];
                for i=1:length(mfChildren)
                    children=obj.addNode(children,mfChildren(i));
                end
            else
                children=[];
            end
        end

        function links=getOutgoingLinks(obj)
            if~obj.isSink()
                outgoing=obj.mfObject.outgoing.toArray;
                links=systemcomposer.internal.analysis.AnalysisConnectorInstance(outgoing(1),obj.model);
                for o=2:length(outgoing)
                    links(end+1)=systemcomposer.internal.analysis.AnalysisConnectorInstance(outgoing(o),obj.model);
                end
            else
                links=[];
            end
        end

        function links=getIncomingLinks(obj)
            if~obj.isSource()
                incoming=obj.mfObject.incoming.toArray;

                links=systemcomposer.internal.analysis.AnalysisNodeInstance(incoming(1),obj.model);
                for o=2:length(incoming)
                    links(end+1)=systemcomposer.internal.analysis.AnalysisNodeInstance(incoming(o),obj.model);
                end
            else
                links=[];
            end
        end

        function res=isSource(obj)

            res=obj.mfObject.incoming.Size==0;

        end

        function res=isSink(obj)
            res=obj.mfObject.outgoing.Size==0;
        end
    end
end


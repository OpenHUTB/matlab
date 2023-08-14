classdef(Sealed)SLTopoWithMdlRefContainer<fxptopo.internal.CompositeTopologyContainer






    methods
        function this=SLTopoWithMdlRefContainer()
            this.ChildContainer=fxptopo.internal.SLTopoContainer();
        end
    end

    methods(Access=protected)
        function createGraph(this)


            this.ChildContainer.ModelName=this.ModelName;
            this.ChildContainer.CurrentSystem=this.CurrentSystem;
            this.ChildContainer.createGraph();
            this.ModelGraph=this.ChildContainer.ModelGraph;
            this.Graph=this.ChildContainer.Graph;




            this.ModelRefs=find_mdlrefs(this.ModelName,'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices);
            for ii=1:numel(this.ModelRefs)
                load_system(this.ModelRefs{ii});
            end


            g=this.Graph;
            mdlRefNodes=find(g.Nodes.Type=="ModelReference");
            mdlRefHandles=g.Nodes.Handle(mdlRefNodes);
            commentedMdlRef=get_param(mdlRefHandles,'Commented')~="off";
            mdlRefHandles(commentedMdlRef)=[];
            nMdlRef=numel(mdlRefHandles);
            mdlRefs=cell(nMdlRef,1);
            for ii=1:nMdlRef
                mdlRefs{ii}=get_param(mdlRefHandles(ii),'ModelName');
            end


            mdlRefGraphs=cell(nMdlRef,1);
            for ii=1:nMdlRef

                mdlRefGraphs{ii}=fxptopo.internal.SLTopoWithMdlRefContainer().buildGraph(mdlRefs{ii});


                g=g.addnode(mdlRefGraphs{ii}.Graph.Nodes);


                containingObjects=arrayfun(@(x)get(x,'Object'),mdlRefGraphs{ii}.Graph.Nodes.Handle,'UniformOutput',false);
                inports=containingObjects(cellfun(@(x)isa(x,'Simulink.Inport'),containingObjects,'UniformOutput',true));
                inports=inports(cellfun(@(x)str2double(x.Port),inports,'UniformOutput',true));
                outports=containingObjects(cellfun(@(x)isa(x,'Simulink.Outport'),containingObjects,'UniformOutput',true));
                outports=outports(cellfun(@(x)str2double(x.Port),outports,'UniformOutput',true));

                modelRefPortHandles=get(mdlRefHandles(ii),'PortHandles');


                for kk=1:numel(modelRefPortHandles.Inport)
                    portNode=find(g.Nodes.Handle==modelRefPortHandles.Inport(kk));
                    inPortNode=find(g.Nodes.Handle==inports{kk}.Handle);
                    edgeTable=table(fxptopo.internal.EdgeType.InterfaceOut,'VariableNames',{'Type'});
                    g=g.addedge(portNode,inPortNode,edgeTable);
                end

                for kk=1:numel(modelRefPortHandles.Outport)
                    portNode=find(g.Nodes.Handle==modelRefPortHandles.Outport(kk));
                    outPortNode=find(g.Nodes.Handle==outports{kk}.Handle);
                    edgeTable=table(fxptopo.internal.EdgeType.InterfaceIn,'VariableNames',{'Type'});
                    g=g.addedge(outPortNode,portNode,edgeTable);
                end



                blockHandles=mdlRefGraphs{ii}.Graph.Nodes.Handle;
                cellOfChildNodes=cell(size(blockHandles));
                for iHandle=1:numel(blockHandles)
                    cellOfChildNodes{iHandle}=find(g.Nodes.Handle==blockHandles(iHandle));
                end
                childNodes=cell2mat(cellOfChildNodes);
                childNodes=unique(childNodes);
                edgeTable=mdlRefGraphs{ii}.Graph.Edges;
                edgeTable.EndNodes=reshape(childNodes(edgeTable.EndNodes),size(edgeTable.EndNodes));
                if any(strcmp(edgeTable.Properties.VariableNames,'EndNodeNames'))
                    edgeTable.EndNodeNames=[];
                end
                g=g.addedge(edgeTable);

                mdlRefNode=find(g.Nodes.Handle==mdlRefHandles(ii));
                for jj=childNodes
                    edgeTable=table(fxptopo.internal.EdgeType.Contain,'VariableNames',{'Type'});
                    g=g.addedge(mdlRefNode,childNodes,edgeTable);
                end
            end

            this.Graph=g;
        end
    end
end

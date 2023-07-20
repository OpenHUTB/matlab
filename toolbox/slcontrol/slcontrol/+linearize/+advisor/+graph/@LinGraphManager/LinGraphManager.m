classdef LinGraphManager

















    properties(Access=private)

StructPortData
NumPortData
StructuralHighlighter
NumericalHighlighter
    end
    properties(GetAccess=public,SetAccess=private)

MdlHierInfo
        Model;

ChannelGraph
RedChannelGraph
MinimalChannelGraph
BlockGraph
RedBlockGraph

        JStructuralBlocks=[]
        JNumericalBlocks=[]


        GenerateStructuralHLData logical
    end
    methods
        this=updateIOs(this,J,iostruct)

        function this=LinGraphManager(J,mdl,mdlHierInfo,generatestructHL)
            if nargin<4
                generatestructHL=true;
            end

            this.Model=mdl;
            this.MdlHierInfo=mdlHierInfo;
            this.GenerateStructuralHLData=generatestructHL;

            this=updateGraphs(this,...
            linearize.advisor.graph.ChannelGraph(J,mdl,mdlHierInfo),...
            false);


            if this.GenerateStructuralHLData
                sPortEdges=getPortConnectivity(this.ChannelGraph);

                this.StructPortData=generatePortData(this,sPortEdges);
            end
            nPortEdges=getPortConnectivity(this.RedChannelGraph);

            this.NumPortData=generatePortData(this,nPortEdges);

            this.StructuralHighlighter=[];
            this.NumericalHighlighter=[];
        end
        function val=ready2Highlight(this)
            if this.GenerateStructuralHLData
                val=~isempty(this.StructuralHighlighter)&&~isempty(this.NumericalHighlighter);
            else
                val=~isempty(this.NumericalHighlighter);
            end
        end
        function h=getHighlighters(this)
            if ready2Highlight(this)
                h=[this.StructuralHighlighter,this.NumericalHighlighter];
            else
                ctrlMsgUtils.error('Slcontrol:linadvisor:LGANotReady2Highlight');
            end
        end
        function this=updateGraphs(this,channelGraph,buildBlockGraphs)
            if nargin<3
                buildBlockGraphs=false;
            end
            this.ChannelGraph=channelGraph;
            this.RedChannelGraph=reduce(channelGraph);
            if this.GenerateStructuralHLData&&buildBlockGraphs
                this.BlockGraph=linearize.advisor.graph.BlockGraph(channelGraph);
                this.RedBlockGraph=linearize.advisor.graph.BlockGraph(this.RedChannelGraph);
            end
        end
        function sBlks=getBlocksStructurallyOnPath(this)
            sBlks=getBlocksOnPath(this.BlockGraph);
        end
        function nBlks=getBlocksNumericallyOnPath(this)
            nBlks=getBlocksOnPath(this.RedBlockGraph);
        end
        function[sBlks,nBlks]=getBlockPathStatus(this)
            sBlks=getBlocksStructurallyOnPath(this);
            nBlks=getBlocksNumericallyOnPath(this);
        end
        function val=isBlockStructurallyArticulating(this,blkh)
            val=isBlockArticulating(this.BlockGraph,blkh);
        end
        function g=getMinimalChannelGraph(this)




            if isempty(this.MinimalChannelGraph)
                import linearize.advisor.graph.*
                g=this.ChannelGraph;
                sblks=getBlocksStructurallyOnPath(this);
                blkh=[this.ChannelGraph.Nodes.JacobianBlockHandle]';
                types=[this.ChannelGraph.Nodes.Type]';
                iotypes=(types==NodeTypeEnum.INLINIO)|(types==NodeTypeEnum.OUTLINIO);
                nodes2rm=~ismember(blkh,sblks)&~iotypes;
                g=rmNodes(g,nodes2rm);


                g=processForSimscapeBlocks(g);
                types=[g.Nodes.Type]';
                iotypes=(types==NodeTypeEnum.INLINIO)|(types==NodeTypeEnum.OUTLINIO);



                solonodes=~any(g.Adj,1)'&~any(g.Adj,2)&~iotypes;
                g=rmNodes(g,solonodes);
            else
                g=this.MinimalChannelGraph;
            end
        end
    end
    methods(Access=private)
        this=buildPathHighlighters(this)
        function pd=generatePortData(this,edges)

            pd=createEmptyPortDataStruct(this);
            for i=size(edges,1):-1:1
                e=edges(i,:);
                [segs,blks]=Simulink.SLHighlight.find_path(e(1),e(2),[]);
                pd(i)=struct('Edge',e,'Segments',segs,'Blocks',blks);
            end
        end
        function s=createEmptyPortDataStruct(~)
            s=struct(...
            'Edge',{},...
            'Segments',{},...
            'Blocks',{});
        end
    end
end
classdef AbstractGraph
    properties

        Adj logical
        Nodes linearize.advisor.graph.AbstractNode=linearize.advisor.graph.AbstractNode.empty
    end
    properties(Dependent,GetAccess=public,SetAccess=private)
Edges
    end
    methods(Abstract)
        srcIdx=getSrcIdx(this)
        snkIdx=getSnkIdx(this)
    end
    methods
        function edges=get.Edges(this)
            [tail,head]=find(this.Adj);
            edges=[head,tail];
        end
        function this=rmEdges(this,rmIdx)

            this.Adj(rmIdx,:)=false;
            this.Adj(:,rmIdx)=false;
        end
        function this=rmNodes(this,rmIdx)
            na=size(this.Adj,1);
            if islogical(rmIdx)
                rmIdx=find(rmIdx);
            end

            rmIdx=unique(rmIdx);
            na_new=na-numel(rmIdx);
            idxMat=true(na);
            idxMat(rmIdx,:)=false;
            idxMat(:,rmIdx)=false;
            this.Adj=reshape(this.Adj(idxMat),na_new,na_new);
            this.Nodes(rmIdx)=[];
        end
        function this=addNodes(this,nodes)

            nn=numel(nodes);
            this.Adj=blkdiag(this.Adj,false(nn));
            this.Nodes=[this.Nodes,nodes(:)'];
        end
        function this=addEdges(this,edges)

            n=size(edges,1);
            for i=1:n
                edge=edges(i,:);
                src=edge(1);
                snk=edge(2);
                this.Adj(snk,src)=true;
            end
        end
        function this=collapseAdj(this,nodeIdx,collapsedNode)



            this.Nodes(nodeIdx)=[];

            this.Adj=linearize.linutil.collapseAdj(this.Adj,nodeIdx);
            this.Nodes=[this.Nodes,collapsedNode];
        end
        function this=reduce(this)

            rIdx=getReachableNodes(this);
            this=rmNodes(this,~rIdx);
        end
        function rIdx=getReachableNodesFromSrc2Snk(this,sIdx,tIdx,rmap)


            if nargin<4
                rmap=getReachableMap(this);
            end
            node2target=any(rmap(tIdx,:),1);
            source2node=any(rmap(:,sIdx),2);
            rIdx=node2target(:)&source2node(:);
        end
        function rIdx=getReachableNodes(this)


            sIdx=this.getSrcIdx;
            tIdx=this.getSnkIdx;
            rIdx=getReachableNodesFromSrc2Snk(this,sIdx,tIdx);
        end
        function val=causesZeroChannel(this,nodeIdx)







            if islogical(nodeIdx)
                nodeIdx=find(nodeIdx);
            end
            origreachmap=getIOReachableMap(this);
            n=numel(nodeIdx);
            val=false(n,1);
            for i=1:n
                idx=nodeIdx(i);
                temp=rmEdges(this,idx);
                newreachmap=getIOReachableMap(temp);
                val(i,1)=any(any(origreachmap~=newreachmap));
            end
        end
        function val=isEdgeArticulating(this,edges)
            origreachmap=getIOReachableMap(this);
            n=size(edges,1);
            val=false(n,1);
            for i=1:n
                edge=edges(i,:);
                temp=this;
                temp.Adj(edge(2),edge(1))=false;
                newreachmap=getIOReachableMap(temp);
                val(i,1)=any(any(origreachmap~=newreachmap));
            end
        end
        function val=isNodeArticulating(this,nodeIdx)



            val=causesZeroChannel(this,nodeIdx);
        end
        function idx=predecessors(this,nodeidx)
            a=any(this.Adj(nodeidx,:),1);
            idx=a(:);
        end
        function idx=successors(this,nodeidx)
            a=any(this.Adj(:,nodeidx),2);
            idx=a(:);
        end
        function g=extractSubGraph(this,nodeidx)
            g=this;
            n=size(g.Adj,1);
            a=false(n,1);
            a(nodeidx)=true;
            b=~a;
            g.Adj(b,b)=[];
            g.Nodes(b)=[];
        end
        function paths=getPaths(this)






            paths=this.empty;
            moreThanOneSuc=sum(this.Adj,1)>1;
            moreThanOnePrd=sum(this.Adj,2)>1;

            src=getSrcIdx(this)|moreThanOneSuc';
            snk=getSnkIdx(this)|moreThanOnePrd;

            multiedgepoints=find(src|snk);
            n=numel(multiedgepoints);
            for i=1:n
                pi=multiedgepoints(i);
                suc=find(successors(this,pi));
                for s=suc(:)'
                    s_=s;
                    pathidx=[pi,s_];
                    while~ismember(s_,multiedgepoints)
                        s_=find(successors(this,pathidx(end)));
                        pathidx(end+1)=s_;%#ok<AGROW>
                    end
                    paths(end+1)=rmNodes(this,setdiff(1:numel(this.Nodes),pathidx));%#ok<AGROW>
                end
            end
        end
        function rmap=getReachableMap(this)

            g=matlab.internal.graph.MLDigraph(this.Adj');

            rmap=~isinf(bfsAllShortestPaths(g,'all','all'));


        end
        function r=getIOReachableMap(this,varargin)
            narginchk(1,3);
            if nargin==3
                snk=varargin{2};
                src=varargin{1};
            else
                snk=getSnkIdx(this);
                src=getSrcIdx(this);
            end

            r=getReachableMap(this);
            r=r(snk,src);
        end
        function missingEdges=getMissingEdges(gp,gv)
            ep=gp.Edges;
            ev=gv.Edges;
            missingEdges=setdiff(ep,ev,'rows');
        end
        function[sourceNodes,sinkNodes]=getBreakingNodes(this)




            rmap=getReachableMap(this);

            rmap(logical(eye(size(rmap,1))))=0;
            uidx=this.getSrcIdx;
            yidx=this.getSnkIdx;

            sourceNodes=~any(rmap,2)&~uidx;

            sinkNodes=~any(rmap,1)'&~yidx;
        end
        function d=distances(this)
            d=distances(getDigraph(this));
        end
        function dg=getDigraph(this,addnames)
            if nargin<2
                addnames=false;
            end
            dg=digraph(this.Adj');
            if addnames
                names=print(this.Nodes);
                dg.Nodes.Name=names(:);
            end
        end
        function varargout=plot(this,varargin)
            if numel(varargin)
                ha=varargin{1};
            else
                ha=gca;
            end
            dg=getDigraph(this,true);
            h=plot(ha,dg,'Layout','layered');

            hf=ha.Parent;



            dcm=datacursormode(hf);
            dcm.Enable='on';
            dcm.SnapToDataVertex='on';
            dcm.DisplayStyle='datatip';
            dcm.UpdateFcn={@linearize.advisor.graph.AbstractGraph.dataTipCB,this};
            ha.Title.Interpreter='none';
            if nargout>0
                varargout{1}=h;
            end
        end
    end
    methods(Static,Access=protected)
        function str=dataTipCB(src,ed,this)
            pos=ed.Position;
            x=pos(1);y=pos(2);

            hp=src.Parent.Children;
            nodeidx=(x==hp.XData)&(y==hp.YData);
            node=this.Nodes(nodeidx);
            str=getDataTipStr(node);
        end
    end
end
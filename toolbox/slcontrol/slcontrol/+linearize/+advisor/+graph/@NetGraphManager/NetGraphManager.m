classdef NetGraphManager


    properties(SetAccess=private,GetAccess=public)
GPattern
GValue
PMSys
PMInput
IsPatternFullyDisconnected
    end
    properties(GetAccess=public,SetAccess=private,Dependent)


Ny
Nu
Nx
Nxd
Ndxd
Nxa
Nodes
    end
    methods
        function this=NetGraphManager(pmsys,pminput)
            [this.GPattern,this.GValue]=...
            linearize.advisor.graph.SimscapeNetGraph.constructGraphs(pmsys,pminput);
            this.PMSys=pmsys;
            this.PMInput=pminput;
        end
        function ny=get.Ny(this)
            ny=this.GPattern.Ny;
        end
        function nu=get.Nu(this)
            nu=this.GPattern.Nu;
        end
        function nx=get.Nx(this)
            nx=this.GPattern.Nx;
        end
        function nxd=get.Nxd(this)
            nxd=this.GPattern.Nxd;
        end
        function ndxd=get.Ndxd(this)
            ndxd=this.GPattern.Ndxd;
        end
        function nxa=get.Nxa(this)
            nxa=this.GPattern.Nxa;
        end
        function nodes=get.Nodes(this)
            nodes=this.GPattern.Nodes;
        end



        function varargout=getBreakingNodes(this)

            nargoutchk(0,2);
            [srcP,snkP]=getBreakingNodes(this.GPattern);
            [srcV,snkV]=getBreakingNodes(this.GValue);
            brkSrc=setdiff(find(srcV),find(srcP));
            brkSnk=setdiff(find(snkV),find(snkP));
            if nargout<2
                varargout{1}=union(brkSrc,brkSnk);
            else
                varargout{1}=brkSrc;
                varargout{2}=brkSnk;
            end
        end
        function this=hookUpStateOutputs(this,xidx)


















        end
        function this=removeStructurallyDisconnectStates(this)


            rIdx=getReachableNodes(this.GPattern);
            if all(~rIdx)
                this.IsPatternFullyDisconnected=true;
            else
                this.GPattern=rmNodes(this.GPattern,~rIdx);
                this.GValue=rmNodes(this.GValue,~rIdx);
            end
        end
        function this=rmDisconnectedInputs(this)




            [this.GPattern,uidx2rm]=rmDisconnectedInputs(this.GPattern);
            this.GValue=rmDisconnectedInputs(this.GValue,uidx2rm);
        end
        function this=rmInputsNotOnPath(this,uidxonpath)


            uidx2rm=setdiff(1:this.Nu,uidxonpath);
            this.GPattern=rmInputs(this.GPattern,uidx2rm);
            this.GValue=rmInputs(this.GValue,uidx2rm);
        end
        function this=pathProcess(this,inputOnPathIdx,outputStateIdx)





            this=rmInputsNotOnPath(this,inputOnPathIdx);

            this=hookUpStateOutputs(this,outputStateIdx);
            this=removeStructurallyDisconnectStates(this);
        end
        function missingEdges=getMissingEdges(this)



            missingEdgeTable=getMissingEdges(this.GPattern,this.GValue);








            missingEdges=struct(...
            'Source',{},...
            'Sink',{},...
            'IndependentEquationVariables',{});
            numEdges=size(missingEdgeTable,1);
            for i=1:numEdges
                srcX=missingEdgeTable(i,1);
                snkX=missingEdgeTable(i,2);
                opX=find(predecessors(this.GPattern,snkX));
                missingEdges(i).Source=srcX;
                missingEdges(i).Sink=snkX;
                missingEdges(i).IndependentEquationVariables=opX;
            end
        end
        function[states,inputs]=getNetworkOperatingPoint(this)

            states=struct('Name',{},'x',{});
            nx=this.PMSys.NumStates;
            for i=1:nx
                name=this.PMSys.VariableData(i).path;
                x=this.PMInput.X(i);
                states(i)=struct('Name',name,'x',x);
            end

            inputs=struct('Port',{},'u',{});
            nu=this.PMSys.NumInputs;
            for i=1:nu

                u=this.PMInput.U(i);
                inputs(i)=struct('Port',i,'u',u);
            end
        end
        function val=isNodeArticulating(this,nodeIdx)



            if islogical(nodeIdx)
                nodeIdx=find(nodeIdx);
            end
            gp=this.GPattern;


            val=isNodeArticulating(gp,nodeIdx);
        end
        function varargout=plotDiagnostics(this,nodeidx,varargin)





            if numel(varargin)
                ha=varargin{1};
            else
                ha=gca;
            end
            gp=this.GPattern;gv=this.GValue;
            missingedges=getMissingEdges(gp,gv);

            ae=isEdgeArticulating(gp,missingedges);
            articedges=missingedges(ae,:);

            missingedges=reshape(missingedges',1,numel(missingedges));
            articedges=reshape(articedges',1,numel(articedges));

            snk=getSnkIdx(gp);
            src=getSrcIdx(gp);

            hp=plot(gp,ha);
            if~isempty(nodeidx)


                hp.NodeColor=[0.9,0.9,0.9];
                hp.EdgeColor=[0.9,0.9,0.9];
                hp.EdgeAlpha=0.5;

                d=gp.distances;
                opnodes=find(d(:,nodeidx)==1);
                highlight(hp,opnodes,'NodeColor','g','MarkerSize',4);

                n=2*numel(opnodes);
                opedges=zeros(1,n);
                opedges(1:2:n)=opnodes;
                opedges(2:2:n)=nodeidx;
                highlight(hp,opedges,'EdgeColor','g','LineStyle','-','LineWidth',1);

                highlight(hp,nodeidx,'NodeColor','m','MarkerSize',5);
            end

            highlight(hp,missingedges,...
            'EdgeColor',[1,0.65,0],'LineStyle','--','LineWidth',1);

            highlight(hp,articedges,...
            'EdgeColor','r','LineStyle','--','LineWidth',1.5);
            hp.ArrowSize=7;

            highlight(hp,src,'NodeColor','b','MarkerSize',7);
            highlight(hp,snk,'NodeColor','c','MarkerSize',7);
            title(ha,'Network Reachability');
            LocalConfigurePlot(this,ha);
            if nargout>0
                varargout{1}=hp;
            end
        end
        function varargout=plotFocusedDiagnostics(this,nodeidx,dist,varargin)





            if numel(varargin)
                ha=varargin{1};
            else
                ha=gca;
            end
            if isstruct(nodeidx)
                nodeidx=nodeidx.Index;
            end
            gp=this.GPattern;gv=this.GValue;
            d=gp.distances;
            idx2rm=(d(nodeidx,:)'>dist)&(d(:,nodeidx)>dist);
            gp=gp.rmNodes(find(idx2rm));%#ok<FNDSB>
            gv=gv.rmNodes(find(idx2rm));%#ok<FNDSB>
            missingedges=getMissingEdges(gp,gv);

            ae=isEdgeArticulating(gp,missingedges);
            articedges=missingedges(ae,:);


            newnodeidx=nodeidx-nnz(idx2rm(1:nodeidx));

            missingedges=reshape(missingedges',1,numel(missingedges));
            articedges=reshape(articedges',1,numel(articedges));
            hp=plot(gp,ha);


            d=gp.distances;
            opnodes=find(d(:,newnodeidx)==1);
            highlight(hp,opnodes,'NodeColor','g','MarkerSize',8);

            n=2*numel(opnodes);
            opedges=zeros(1,n);
            opedges(1:2:n)=opnodes;
            opedges(2:2:n)=newnodeidx;
            highlight(hp,opedges,'EdgeColor','g','LineStyle','-','LineWidth',2);

            highlight(hp,missingedges,'EdgeColor',[1,0.65,0],'LineStyle','--','LineWidth',2);
            highlight(hp,articedges,'EdgeColor','r','LineStyle','--','LineWidth',2);

            highlight(hp,newnodeidx,'NodeColor','m','MarkerSize',10);

            hp.ArrowSize=15;
            title(ha,sprintf('Reachability of State:\n%s',this.Nodes(nodeidx).Name));
            LocalConfigurePlot(this,ha);

            hp.Annotation.LegendInformation.IconDisplayStyle='on';


            if nargout>0
                varargout{1}=hp;
            end
        end
    end
    methods(Static,Access=private)
        function txt=dataTipCB(src,ed,this)
            import linearize.advisor.graph.*
            pos=ed.Position;
            x=pos(1);y=pos(2);

            hp=src.Parent.Children;
            labelidx=(x==hp.XData)&(y==hp.YData);
            label=hp.NodeLabel{labelidx};
            aliases=print(this.Nodes);
            nodeidx=strcmp(aliases,label);
            node=this.Nodes(nodeidx);
            txt=getDataTipStr(node);
        end
    end
end



function LocalConfigurePlot(this,ha)

    hf=ha.Parent;
    hf.MenuBar='none';
    ha.XAxis.Visible='off';
    ha.YAxis.Visible='off';


    ha.Title.Interpreter='none';

    dcm=datacursormode(hf);
    dcm.Enable='on';
    dcm.SnapToDataVertex='on';
    dcm.DisplayStyle='datatip';
    dcm.UpdateFcn={@linearize.advisor.graph.NetGraphManager.dataTipCB,this};
end
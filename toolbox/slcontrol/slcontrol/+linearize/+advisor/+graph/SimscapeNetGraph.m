classdef SimscapeNetGraph<linearize.advisor.graph.AbstractGraph
    properties(GetAccess=public,SetAccess=protected)


        Ny;
        Nu;
        Nx;
        Nxd;
        Ndxd;
        Nxa;
    end
    methods
        function srcIdx=getSrcIdx(this)
            import linearize.advisor.graph.*
            types=[this.Nodes.Type]';
            srcIdx=types==NodeTypeEnum.SIMSCAPE_INPUT;
        end
        function snkIdx=getSnkIdx(this)
            import linearize.advisor.graph.*
            types=[this.Nodes.Type]';
            snkIdx=types==NodeTypeEnum.SIMSCAPE_OUTPUT;
        end
        function this=rmNodes(this,rmIdx)
            import linearize.advisor.graph.*
            this=rmNodes@linearize.advisor.graph.AbstractGraph(this,rmIdx);
            types=[this.Nodes.Type]';
            this.Ny=nnz(types==NodeTypeEnum.SIMSCAPE_OUTPUT);
            this.Nu=nnz(types==NodeTypeEnum.SIMSCAPE_INPUT);
            this.Nxd=nnz(types==NodeTypeEnum.SIMSCAPE_DIFFERENTIAL);
            this.Nxa=nnz(types==NodeTypeEnum.SIMSCAPE_ALGEBRAIC);
            this.Ndxd=nnz(types==NodeTypeEnum.SIMSCAPE_DERIVATIVE);
            this.Nx=this.Nxd+this.Nxa;
        end
        function this=hookUpStateOutputs(this,xidx)
            import linearize.advisor.graph.*
            if islogical(xidx)
                xidx=find(xidx);
            end

            types=[this.Nodes.Type]';
            yidx=types==NodeTypeEnum.SIMSCAPE_OUTPUT;
            this=rmNodes(this,yidx);

            newny=numel(xidx);
            nodes=SimscapeNode.empty;
            for i=1:newny
                nodes(i)=SimscapeNode(NodeTypeEnum.SIMSCAPE_OUTPUT);
                nodes(i).Name=sprintf('y%u',i);
                nodes(i).BlockPath='';
                nodes(i).Description='';
                nodes(i).Index=i;
            end
            this=addNodes(this,nodes);

            types=[this.Nodes.Type]';
            yidx=types==NodeTypeEnum.SIMSCAPE_OUTPUT;

            xidx=xidx+this.Nxd;
            edges=[xidx(:),find(yidx(:))];
            this=addEdges(this,edges);
            this.Ny=newny;
        end
        function this=rmInputs(this,uidx2rm)
            if islogical(uidx2rm)
                uidx2rm=find(uidx2rm);
            end
            uidx=find(getSrcIdx(this));
            this=rmNodes(this,uidx(uidx2rm));

        end
        function[this,uidx2rm]=rmDisconnectedInputs(this,uidx2rm)

            if nargin<2
                rmap=getReachableMap(this);
                rmap(logical(eye(size(rmap,1))))=false;
                uidx=getSrcIdx(this);
                uidx2rm=all(~rmap,1)'&uidx;
            end
            this=rmInputs(this,uidx2rm);
        end
    end
    methods(Access=protected)
        function this=SimscapeNetGraph(ny,nu,nx,nxd,nxa,adj,nodes)
            this.Ny=ny;
            this.Nu=nu;
            this.Nx=nx;
            this.Nxd=nxd;
            this.Ndxd=nxd;
            this.Nxa=nxa;
            this.Adj=adj;
            this.Nodes=nodes;
        end
    end
    methods(Static)
        function[gp,gv]=constructGraphs(pmsys,pminput)
            import linearize.advisor.graph.*
            nld=linearize.advisor.utils.parseNetLinData(...
            linearize.advisor.utils.genNetLinData(pmsys,pminput));

            ny=nld.ny;
            nu=nld.nu;
            nx=nld.nx;
            nxd=nld.nxd;
            na=nld.nx-nld.nxd;

            nodes=SimscapeNode.empty;

            for i=1:nxd
                nodes(i)=SimscapeNode(NodeTypeEnum.SIMSCAPE_DERIVATIVE);
                nodes(i).Name=pmsys.VariableData(i).path;
                nodes(i).BlockPath=pmsys.VariableData(i).object;
                nodes(i).Description=pmsys.VariableData(i).description;
                nodes(i).Index=i;
                nodes(i).OPVal=[];
            end

            for i=1:nxd
                idx=i+nxd;
                nodes(idx)=SimscapeNode(NodeTypeEnum.SIMSCAPE_DIFFERENTIAL);
                nodes(idx).Name=pmsys.VariableData(i).path;
                nodes(idx).BlockPath=pmsys.VariableData(i).object;
                nodes(idx).Description=pmsys.VariableData(i).description;
                nodes(idx).Index=i;
                nodes(idx).OPVal=pminput.X(i);
            end

            for i=1:na
                idx=i+2*nxd;
                nodes(idx)=SimscapeNode(NodeTypeEnum.SIMSCAPE_ALGEBRAIC);
                nodes(idx).Name=pmsys.VariableData(i+nxd).path;
                nodes(idx).BlockPath=pmsys.VariableData(i+nxd).object;
                nodes(idx).Description=pmsys.VariableData(i+nxd).description;
                nodes(idx).Index=i;
                nodes(idx).OPVal=pminput.X(i+nxd);
            end

            for i=1:ny
                idx=i+2*nxd+na;
                nodes(idx)=SimscapeNode(NodeTypeEnum.SIMSCAPE_OUTPUT);
                nodes(idx).Name=sprintf('y%u',i);
                nodes(idx).BlockPath='';
                nodes(idx).Description='';
                nodes(idx).Index=i;
                nodes(idx).OPVal=[];
            end

            for i=1:nu
                idx=i+2*nxd+na+ny;
                nodes(idx)=SimscapeNode(NodeTypeEnum.SIMSCAPE_INPUT);
                nodes(idx).Name=sprintf('u%u',i);
                nodes(idx).BlockPath='';
                nodes(idx).Description='';
                nodes(idx).Index=i;
                nodes(idx).OPVal=pminput.U(i);
            end


            [av,swapIdx,constraintRows,singularRows]=descriptor2map(...
            nld.values,nld.values.J_c_x,nld.values.J_c_u);
            ap=descriptor2map(...
            nld.patterns,nld.patterns.J_c_x,nld.values.J_c_u,...
            swapIdx,constraintRows,singularRows);
            gv=SimscapeNetGraph(ny,nu,nx,nxd,na,av,nodes);
            gp=SimscapeNetGraph(ny,nu,nx,nxd,na,ap,nodes);
        end
    end
end
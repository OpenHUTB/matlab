classdef Flattener<handle

    properties(Access=private)
CircuitList
LocalMaps
ElementList
ParentList
GlobalGround
LastGlobalNode
    end

    methods
        function obj=Flattener
            reset(obj)
        end

        function reset(obj)
            obj.CircuitList=circuit.empty;
            obj.LocalMaps={};
            obj.ElementList=resistor.empty;
            obj.ParentList=circuit.empty;
            obj.GlobalGround=rf.internal.circuit.GlobalGroundNode;
            obj.LastGlobalNode=obj.GlobalGround;
        end

        function[elems,conn,flatports,numnodes,has0]=flattencircuit(obj,ckt)


            if~isa(ckt,'rf.internal.circuit.Network')||...
                ~isscalar(ckt)||~isempty(ckt.Parent)
                validateattributes(ckt,{'circuit'},{'scalar'})
                validateattributes(ckt.Parent,{'circuit'},{'nonempty'})
            end


            reset(obj)


            buildcircuitlevel(obj,ckt)


            currentnode=obj.GlobalGround;
            currentnum=0;
            while~isempty(currentnode.NextGlobalNode)
                currentnode=currentnode.NextGlobalNode;
                currentnum=currentnum+1;
                currentnode.GlobalNodeNumber=currentnum;
            end


            elems=obj.ElementList(:);
            numelems=numel(elems);
            conn=cell(numelems,1);
            for e=1:numelems
                prntckt=obj.ParentList(e);
                pnodes=elems(e).ParentNodes;
                connvec=zeros(1,numel(pnodes));
                for n=1:numel(pnodes)
                    nodeobj=getglobalnode(obj,prntckt,pnodes(n));
                    connvec(n)=nodeobj.GlobalNodeNumber;
                end
                conn{e}=connvec;
            end


            numports=ckt.NumPorts;
            flatports=cell(numports,1);
            termnums=ckt.TerminalNodes;
            for p=1:numports
                posobj=getglobalnode(obj,ckt,termnums(p));
                negobj=getglobalnode(obj,ckt,termnums(p+numports));
                pos=posobj.GlobalNodeNumber;
                neg=negobj.GlobalNodeNumber;
                flatports{p}=[pos,neg];
            end

            has0=~isempty(obj.GlobalGround.MyLocalNodes);
            numnodes=obj.LastGlobalNode.GlobalNodeNumber+has0;
        end
    end

    methods(Access=private)
        function buildcircuitlevel(obj,ckt)



            makenodeobjects(obj,ckt)


            elems=ckt.Elements;
            for n=1:numel(elems)
                if isa(elems(n),'rf.internal.circuit.Network')
                    buildcircuitlevel(obj,elems(n))
                else
                    obj.ElementList(end+1)=elems(n);
                    obj.ParentList(end+1)=ckt;
                end
            end
        end

        function makenodeobjects(obj,ckt)


            obj.CircuitList(end+1)=ckt;
            map=containers.Map('KeyType','double','ValueType','any');
            obj.LocalMaps{end+1}=map;


            cktnodes=ckt.Nodes;
            if cktnodes(1)
                startidx=1;
            else
                startidx=2;
                map(0)=rf.internal.circuit.LocalNode(obj.GlobalGround);
            end



            prevglbnode=obj.LastGlobalNode;
            for cn=startidx:numel(cktnodes)

                newglbnode=rf.internal.circuit.GlobalNonGroundNode(prevglbnode);
                newlclnode=rf.internal.circuit.LocalNode(newglbnode);


                map(cktnodes(cn))=newlclnode;


                prevglbnode=newglbnode;
            end
            obj.LastGlobalNode=newglbnode;


            tnodes=ckt.TerminalNodes;
            pnodes=ckt.ParentNodes;
            prntckt=ckt.Parent;
            for npn=1:numel(pnodes)
                templocal=map(tnodes(npn));
                glbnd1=templocal.MyGlobalNode;
                glbnd2=getglobalnode(obj,prntckt,pnodes(npn));
                mergenodes(obj,glbnd1,glbnd2)
            end
        end

        function glbnodeobj=getglobalnode(obj,ckt,lclnodenum)

            map=obj.LocalMaps{ckt==obj.CircuitList};
            lclnodeobj=map(lclnodenum);
            glbnodeobj=lclnodeobj.MyGlobalNode;
        end

        function mergenodes(obj,glbnd1,glbnd2)


            if glbnd1==glbnd2
                return
            end



            if glbnd1.GlobalNodeNumber<glbnd2.GlobalNodeNumber
                keep=glbnd1;
                toss=glbnd2;
            else
                keep=glbnd2;
                toss=glbnd1;
            end


            tosslclnodes=toss.MyLocalNodes;
            keep.MyLocalNodes=[keep.MyLocalNodes,tosslclnodes];
            for n=1:numel(tosslclnodes)
                tosslclnodes(n).MyGlobalNode=keep;
            end


            tossprev=toss.PreviousGlobalNode;
            if toss==obj.LastGlobalNode
                obj.LastGlobalNode=tossprev;
                tossprev.NextGlobalNode=rf.internal.circuit.GlobalNonGroundNode.empty;
            else
                tossprev.NextGlobalNode=toss.NextGlobalNode;
                toss.NextGlobalNode.PreviousGlobalNode=tossprev;
            end


            toss.NextGlobalNode=rf.internal.circuit.GlobalNonGroundNode.empty;
            toss.PreviousGlobalNode=rf.internal.circuit.GlobalNonGroundNode.empty;
            toss.MyLocalNodes=rf.internal.circuit.LocalNode.empty;
        end
    end

end
classdef Circuit<rf.internal.circuit.Network





    properties(SetAccess=protected)
        Nodes=[]
Elements
    end
    properties(Dependent,SetAccess=protected)
ElementNames
    end


    properties(Hidden,SetAccess=protected)
        TerminalNodes=[]
    end
    properties(Hidden,Access=protected)
NamingObject
    end
    properties(Constant,Access=protected)
        HeaderDescription='Circuit'
    end


    methods
        function obj=Circuit(varargin)
            obj=obj@rf.internal.circuit.Network(varargin{:});

            obj.Elements=resistor.empty;
            obj.NamingObject=rf.internal.NameMap;
        end
    end


    methods
        function enames=get.ElementNames(obj)
            elems=obj.Elements;
            nelems=numel(elems);

            enames=cell(sign(nelems),nelems);
            for n=1:nelems
                enames{n}=elems(n).Name;
            end
        end
    end

    methods
        function delete(obj)
            if~isempty(obj.Name)&&all(isvalid(obj.Elements))
                for k=1:numel(obj.Elements)
                    obj.Elements(k).Parent=circuit.empty;
                    obj.Elements(k).ParentNodes=[];
                end
            end
        end
    end


    methods(Hidden)
        Sobj=sparameters(ckt,freq,varargin)
        cktOut=richards(cktIn,opFreq)
        cktOut=insertUnitElement(cktIn,elem,port,opFreq,Z0)
        cktOut=kuroda(cktIn,varargin)
        cktOut=realize(cktIn,implObj)
        [elems,msgStr]=getChain(c,cloneChain)
    end


    methods(Hidden)
        function replaceName(obj,oldname,newname)


            replaceName(obj.NamingObject,oldname,newname)
        end
    end


    methods(Hidden,Access=protected)
        function plist=getLocalPropertyList(obj)
            plist.ElementNames=obj.ElementNames;
            if~isempty(obj.Elements)
                plist.Elements=obj.Elements;
            end
            plist.Nodes=obj.Nodes;
        end

        function initializeTerminalsAndPorts(obj)
            obj.Terminals={};
        end

        function outobj=localClone(inobj)
            outobj=circuit;
            elems=inobj.Elements;


            for n=1:numel(elems)
                add(outobj,elems(n).ParentNodes,clone(elems(n)))
            end


            if~isempty(inobj.Terminals)
                tnodes=inobj.TerminalNodes;
                numports=numel(inobj.Ports);
                if numports
                    spinputs=cell(1,numports+1);
                    spinputs{end}=inobj.Ports;
                    for n=1:numports
                        spinputs{n}=[tnodes(n),tnodes(n+numports)];
                    end
                    setports(outobj,spinputs{:})
                else
                    setterminals(outobj,tnodes,inobj.Terminals)
                end
            end
        end

        function[outobj,varargout]=functionalClone(inobj,cloneOp,remapNodes)
            outobj=circuit;
            inobjInt=clone(inobj);
            if nargin==2
                remapNodes=@remapNodesIdentity;
            end

            warningMsgs={};
            for n=1:numel(inobjInt.Elements)
                maxNodeNum=max([outobj.Nodes,inobjInt.Nodes]);
                [clonedElem,warningMsgs{end+1}]=cloneOp(inobjInt,n);%#ok<AGROW>


                warningMsgs{end+1}=remapNodes(outobj,inobjInt,n);%#ok<AGROW>
                for m=1:numel(clonedElem)
                    if sum(clonedElem(m).ParentNodes<0)>1

                        error(message('rf:rfcircuit:circuit:richards:FuncCloneMultipleNewNodes'))
                    end
                    clonedElem(m).ParentNodes(clonedElem(m).ParentNodes<0)=maxNodeNum+(1:sum(clonedElem(m).ParentNodes<0));
                    if isempty(clonedElem(m).ParentNodes)
                        clonedElem(m).ParentNodes=inobjInt.Elements(n).ParentNodes;
                    end



                    clonedElem(m).Name=matlab.lang.makeUniqueStrings(clonedElem(m).Name,...
                    [outobj.ElementNames,inobjInt.ElementNames(n+1:end)]);
                    add(outobj,clonedElem(m).ParentNodes,clonedElem(m));
                end
            end
            outobj.TerminalNodes=inobjInt.TerminalNodes;
            varargout={};
            if nargout>1
                warningMsgs=warningMsgs(~cellfun(@(x)isempty(x),warningMsgs));
                if isempty(warningMsgs)
                    warningMsgs={{}};
                end
                varargout=warningMsgs;
            end


            if~isempty(inobjInt.Terminals)
                tnodes=inobjInt.TerminalNodes;
                numports=numel(inobjInt.Ports);
                if numports
                    spinputs=cell(1,numports+1);
                    spinputs{end}=inobjInt.Ports;
                    for n=1:numports
                        spinputs{n}=[tnodes(n),tnodes(n+numports)];
                    end
                    setports(outobj,spinputs{:})
                else
                    setterminals(outobj,tnodes,inobjInt.Terminals)
                end
            end
            function[elemOutNodes,varargout]=remapNodesIdentity(ckt,elNum,~)
                warningMsg=[];
                varargout={};
                if elNum>0&&elNum<=length(ckt.Elements)
                    elemOutNodes=ckt.Elements(elNum).ParentNodes;
                else
                    elemOutNodes=ckt.TerminalNodes;
                end

                if nargout>1
                    varargout={warningMsg};
                end
            end
        end

        function checkNodesAreInCircuit(obj,nodes)



            cktnodes=obj.Nodes;

            overlapnodes=unique([nodes,cktnodes]);
            if numel(overlapnodes)~=numel(cktnodes)
                diffnodes=setxor(overlapnodes,cktnodes);

                error(message('rf:rfcircuit:circuit:setterminals:NodeNotInCircuit',sprintf('%d',diffnodes(1)),obj.Name))
            end
        end
    end
end

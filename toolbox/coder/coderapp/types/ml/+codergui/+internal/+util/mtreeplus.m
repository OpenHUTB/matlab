classdef(Sealed)mtreeplus<mtree

















    properties(Constant)
        KINDS=codergui.internal.util.mtreeplus.getKindsStruct()
        KIND_NAMES=codergui.internal.util.mtreeplus.getKindsCell()
    end

    properties(Constant,GetAccess=private)
        PATH_ALIAS_MAPPINGS=codergui.internal.util.mtreeplus.indexPathAliasMappings()
    end

    properties(Dependent,SetAccess=private)
Text
TreeLength
    end

    properties(Dependent,SetAccess=private,Hidden)
Data
    end

    properties(Access=private)
TempBuffer
    end

    methods
        function this=mtreeplus(text,varargin)
            if isa(text,'mtree')
                text=text.str;
                ix=text.getIX();
            end
            this=this@mtree(text,varargin{:});
            if exist('ix','var')
                this.setIX(ix);
            end
        end

        function match=iskind(this,kind)
            if isnumeric(kind)
                if this.count()==1||isscalar(kind)
                    match=any(this.rawkind()==kind);
                else
                    match=any(this.rawkind()==reshape(kind,1,numel(kind)),'all');
                end
            else
                match=iskind@mtree(this,kind);
            end
        end

        function result=kindId(this)
            result=this.T(this.IX,1);
        end

        function text=get.Text(this)
            text=this.str;
        end

        function len=get.TreeLength(this)
            len=this.n;
        end

        function data=get.Data(this)
            data=this.T;
        end

        function kindId=nsKindId(this,index)
            kindId=this.T(index,1);
        end

        function kind=nsKind(this,index)
            this.assertScalarForMethod(index,1);
            kind=this.KIND_NAMES{this.T(index,1)};
        end

        function kinds=nsKinds(this,indices)
            kinds=this.KIND_NAMES(this.T(indices,1));
        end

        function parent=nsTrueParent(this,index)
            parent=this.T(index,13);
        end

        function pos=nsLeftTreePos(this,index)
            pos=this.T(index,11);
        end

        function pos=nsRightTreePos(this,index)
            pos=this.T(index,12);
        end

        function str=nsString(this,index)
            strIndex=this.readNodeScalar(index,8);
            if strIndex==0
                error('Node at %d has no text',index);
            end
            str=this.C{strIndex};
        end

        function strs=nsStrings(this,indices)
            strs=cell(size(indices));
            strIndices=this.T(indices,8);
            strs(strIndices==0)={''};
            strs(strIndices~=0)=this.C(strIndices(strIndices~=0));
        end

        function rightIndex=nsRightFullIndex(this,index)
            rightIndex=this.T(index,15);
        end

        function rightIndex=nsRightTreeIndex(this,index)
            rightIndex=this.T(index,14);
        end

        function refIndex=nsArg(this,index)
            refIndex=this.followLink(index,this.Linkno.Arg,'L');
        end

        function refIndex=nsAttr(this,index)
            refIndex=this.followLink(index,this.Linkno.Attr,'L');
        end

        function refIndex=nsBody(this,index)
            refIndex=this.followLink(index,this.Linkno.Body,'R');
        end

        function refIndex=nsCatch(this,index)
            refIndex=this.followLink(index,this.Linkno.Catch,'RR');
        end

        function refIndex=nsCatchID(this,index)
            refIndex=this.followLink(index,this.Linkno.CatchID,'RL');
        end

        function refIndex=nsCattr(this,index)
            refIndex=this.followLink(index,this.Linkno.Cattr,'LL');
        end

        function refIndex=nsCexpr(this,index)
            refIndex=this.followLink(index,this.Linkno.Cexpr,'LR');
        end

        function refIndex=nsFname(this,index)
            refIndex=this.followLink(index,this.Linkno.Fname,'LRL');
        end

        function refIndex=nsIndex(this,index)
            refIndex=this.followLink(index,this.Linkno.Index,'LL');
        end

        function refIndex=nsIns(this,index)
            refIndex=this.followLink(index,this.Linkno.Ins,'LRR');
        end

        function refIndex=nsLeft(this,index)
            refIndex=this.followLink(index,this.Linkno.Left,'L');
        end

        function refIndex=nsNext(this,index)
            refIndex=this.followLink(index,this.Linkno.Next,'N');
        end

        function refIndex=nsOuts(this,index)
            refIndex=this.followLink(index,this.Linkno.Outs,'LL');
        end

        function refIndex=nsRight(this,index)
            refIndex=this.followLink(index,this.Linkno.Right,'R');
        end

        function refIndex=nsTry(this,index)
            refIndex=this.followLink(index,this.Linkno.Try,'L');
        end

        function refIndex=nsVector(this,index)
            refIndex=this.followLink(index,this.Linkno.Vector,'LR');
        end

        function listIndices=nsList(this,index)
            next=this.readNodeScalar(index,4);
            if next==0
                listIndices=[];
                return;
            end

            listIndices=zeros(1,24);
            pointer=0;
            while next~=0
                pointer=pointer+1;
                listIndices(pointer)=next;
                next=this.T(next,4);
            end
            listIndices=listIndices(1:pointer);
        end

        function lists=nsLists(this,indices)
            allIndices=1:this.TreeLength;
            nexts=this.nsNext(allIndices);
            listBuffer=zeros(1,numel(nexts));
            lists=cell(1,numel(indices));

            for i=1:numel(indices)
                link=indices(i);
                listBufferPointer=0;
                while link~=0
                    listBufferPointer=listBufferPointer+1;
                    listBuffer(listBufferPointer)=link;
                    link=nexts(link);
                end
                lists{i}=listBuffer(1:listBufferPointer);
            end
        end

        function paths=treePaths(this,indices)
            if nargin<2
                indices=this.indices();
            end

            allIndices=1:this.TreeLength;
            allParents=this.nsTrueParent(allIndices);
            paths=cell(1,this.TreeLength);
            hasParents=allParents~=0;


            rootMask=~hasParents;
            paths(rootMask)=num2cell(allIndices(rootMask));

            pathBuffer=zeros(1,20);
            for ni=indices(hasParents(indices))
                current=ni;
                parentPointer=0;
                while isempty(paths{current})
                    parentPointer=parentPointer+1;
                    pathBuffer(parentPointer)=current;
                    current=allParents(current);
                end
                if parentPointer>0
                    subParentList=flip(pathBuffer(1:parentPointer));
                    for i=1:parentPointer
                        paths{subParentList(i)}=subParentList(1:i);
                    end
                end
            end
            paths=paths(indices);
        end
    end

    methods(Access=private)
        function value=readNodeScalar(this,index,col)
            this.assertScalarForMethod(index,2);
            value=this.T(index,col);
        end

        function refIndex=followLink(this,nodeIndex,validationRow,path)
            if isscalar(nodeIndex)
                if this.Linkok(validationRow,this.T(nodeIndex,1))
                    resolved=this.PATH_ALIAS_MAPPINGS(path);
                    refIndex=nodeIndex;
                    for i=1:numel(path)
                        refIndex=this.T(refIndex,resolved(i));
                        if refIndex==0
                            break;
                        end
                    end
                else
                    refIndex=0;
                end
            else
                refIndex=zeros(size(nodeIndex));
                okays=this.Linkok(validationRow,this.T(nodeIndex,1));
                if~any(okays)
                    return;
                end
                resolved=this.PATH_ALIAS_MAPPINGS(path);
                for i=find(okays)
                    current=nodeIndex(i);
                    for j=1:numel(path)
                        current=this.T(current,resolved(j));
                        if current==0
                            break;
                        end
                    end
                    refIndex(i)=current;
                end
            end
        end
    end

    methods(Static,Access=private)
        function assertScalarForMethod(value,tossCount)
            if~isscalar(value)
                frames=dbstack(tossCount);
                error('"%s" only supports scalar index arguments',frames(1).name);
            end
        end

        function indexed=indexPathAliasMappings()
            indexed('L')=2;
            indexed('R')=3;
            indexed('N')=4;
        end
    end

    methods(Static,Hidden)
        function nodeKinds=getKindsStruct()
            [~,nodeKinds]=mtreemex();
        end

        function asCell=getKindsCell()
            kindStruct=codergui.internal.util.mtreeplus.getKindsStruct();
            kindNames=fieldnames(kindStruct);
            kindVals=struct2cell(kindStruct);
            kindVals=[kindVals{:}];
            asCell=cell(max(kindVals),1);
            for i=1:numel(kindVals)
                asCell{kindVals(i)}=kindNames{i};
            end
        end
    end
end
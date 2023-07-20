classdef(Hidden=true)spreadSheetSource<handle




    properties
        valueWidgetType;
        valueWidgetOptions;
        valueStructure;
valueScalarIndex
valueScalarTable
        spreadRowObjs;
        valueStructureVisitedFlag;
        workingIndex;
        mdlName;
        highlights;
    end
    methods(Access=public)
        function this=spreadSheetSource(structExprWidgetType,structExprWidgetOptions,...
            structHierarchy,scalarIndex,scalarTable,mdlName,varargin)
            this.valueStructure=structHierarchy;
            this.valueScalarIndex=scalarIndex;
            this.valueScalarTable=scalarTable;
            this.mdlName=mdlName;
            this.valueWidgetType=structExprWidgetType;
            this.valueWidgetOptions=structExprWidgetOptions;
            this.highlights=[];
            this.spreadRowObjs=[];



            this.valueStructureVisitedFlag=zeros(size(this.valueStructure));

            this.spreadRowObjs=this.createVariableTreeView;
        end

        function children=getChildren(obj)
            children=obj.spreadRowObjs;
        end

    end
    methods(Access=private)

        function treeTable=createVariableTreeView(this)
            treeTable=[];
            this.workingIndex(1)=0;
            for i=1:length(this.valueStructureVisitedFlag)
                if this.valueStructureVisitedFlag(i)==0


                    this.workingIndex(1)=this.workingIndex(1)+1;
                    this.workingIndex(2)=0;
                    treeTable=[treeTable,this.getVariable(i,'')];
                end
            end
        end

        function treeItem=getVariable(this,i,namePrefix)
            name=this.valueStructure(i).Name;
            isTop=this.valueStructure(i).IsRoot;
            if~isempty(this.valueStructure(i).Dims)

                treeItem=this.getArrayVariable(i,name,[namePrefix,name],isTop);
            else

                treeItem=this.getScalarVariable(i,name,[namePrefix,name],isTop);
            end
        end

        function treeItem=getScalarVariable(this,i,name,namePrefix,isTop)
            this.valueStructureVisitedFlag(i)=1;
            if~isequal(size(this.valueStructure(i).ChildrenIndex),[1,0])

                treeItem=this.getStructureVariable(i,name,namePrefix,isTop);
            else
                this.workingIndex(2)=this.workingIndex(2)+1;

                mdIdx=this.valueScalarIndex{this.workingIndex(1)}(this.workingIndex(2));

                if mdIdx>0
                    varSource=this.valueStructure(i).SourceType;
                    if this.valueStructure(i).DataType==0

                        treeItem=internal.internalVarConfig.spreadSheetReal(this,i,name,varSource,isTop);
                    elseif this.valueStructure(i).DataType==1

                        treeItem=internal.internalVarConfig.spreadSheetInteger(this,i,name,varSource,isTop);
                    elseif this.valueStructure(i).DataType==2

                        treeItem=internal.internalVarConfig.spreadSheetBoolean(this,i,name,varSource,isTop);
                    elseif this.valueStructure(i).DataType==3

                        treeItem=internal.internalVarConfig.spreadSheetString(this,i,name,varSource,isTop);
                    elseif this.valueStructure(i).DataType==4

                        treeItem=internal.internalVarConfig.spreadSheetEnumeration(this,i,name,varSource,isTop);
                    else
                        assert(false,'Invalid datatype from VariableStructure.');
                    end
                else
                    treeItem=[];
                end
            end
        end

        function treeItem=getArrayVariable(this,i,name,namePrefix,isTop)
            dimsIsZeroBased=uint32(this.valueStructure(i).IsDimsZeroBased);
            dims=this.valueStructure(i).Dims+dimsIsZeroBased;

            children(prod(dims))=internal.internalVarConfig.spreadSheetItem;
            dimsIter=ones(1,length(dims))-double(dimsIsZeroBased);
            skipIdxVect=[];
            for iter=1:prod(dims)
                indexStr=['[',regexprep(num2str(dimsIter,'%d '),' +',','),']'];
                retItem=getScalarVariable(this,i,indexStr,[namePrefix,indexStr],0);
                if isempty(retItem)
                    skipIdxVect(end+1)=iter;
                else
                    children(iter)=retItem;
                end


                j=length(dims);
                while 1
                    dimsIter(j)=dimsIter(j)+1;
                    if(j==1||dimsIter(j)<=dims(j)-double(dimsIsZeroBased))
                        break;
                    end
                    dimsIter(j)=1-double(dimsIsZeroBased);
                    j=j-1;
                end
            end

            children(skipIdxVect(:))=[];

            varSource=this.valueStructure(i).SourceType;
            treeItem=internal.internalVarConfig.spreadSheetArray(this,i,name,varSource,children,isTop);
        end

        function treeItem=getStructureVariable(this,i,name,namePrefix,isTop)

            children(1,length(this.valueStructure(i).ChildrenIndex))=internal.internalVarConfig.spreadSheetItem;

            for iter=1:length(this.valueStructure(i).ChildrenIndex)
                children(iter)=this.getVariable(this.valueStructure(i).ChildrenIndex(iter),[namePrefix,'.']);
            end

            varSource=this.valueStructure(i).SourceType;
            treeItem=internal.internalVarConfig.spreadSheetStruct(this,i,name,varSource,children,isTop);
        end
    end
end

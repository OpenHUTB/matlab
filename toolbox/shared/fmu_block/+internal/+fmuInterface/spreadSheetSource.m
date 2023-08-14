classdef(Hidden=true)spreadSheetSource<handle

    properties
        valueWidgetType;
        valueWidgetOptions;
        valueStructure;
valueScalarIndex

        internalValueWidgetType;
        internalValueWidgetOptions;
        internalValueStructure;
        internalValueScalarIndex;

valueScalarTable
        spreadRowObjs;
        dlgSource;
        isInputTab;
isLinkToLibrary

        valueStructureVisitedFlag;
        workingIndex;

internalFlag
    end
    methods(Access=public)
        function this=spreadSheetSource(dlgSource,structExprWidgetType,structExprWidgetOptions,...
            structHierarchy,scalarIndex,scalarTable,isInputTab,varargin)
            this.valueStructure=structHierarchy;
            this.valueScalarIndex=scalarIndex;
            this.valueScalarTable=scalarTable;
            this.valueWidgetType=structExprWidgetType;
            this.valueWidgetOptions=structExprWidgetOptions;

            this.spreadRowObjs=[];
            this.dlgSource=dlgSource;
            this.isInputTab=isInputTab;
            blk=dlgSource.getBlock();
            blkpath=[blk.Parent,'/',blk.Name];
            linkStatus=get_param(blkpath,'LinkStatus');
            if strcmp(linkStatus,'implicit')||strcmp(linkStatus,'resolved')
                this.isLinkToLibrary=true;
            else
                this.isLinkToLibrary=false;
            end
            if~this.isInputTab
                this.internalFlag=varargin{5};
            else
                this.internalFlag=false;
            end



            this.valueStructureVisitedFlag=zeros(size(this.valueStructure));

            this.spreadRowObjs=this.createVariableTreeView;
            if~this.isInputTab
                [this.internalValueWidgetType,this.internalValueWidgetOptions,this.internalValueStructure,this.internalValueScalarIndex,this.internalFlag]=varargin{:};
                if~isempty(this.internalValueStructure)&&~this.internalFlag
                    this.spreadRowObjs=[this.spreadRowObjs,this.addInternalVariableTreeView];
                end
            end
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
                    treeTable=[treeTable,this.getVariable(i,0,'')];
                end
            end
        end

        function localNode=addInternalVariableTreeView(this)

            for i=1:length(this.internalValueStructure)
                this.workingIndex(1)=i;
                this.workingIndex(2)=1;
                name=this.internalValueStructure(i).Name;
                if this.internalValueStructure(i).DataType==0

                    assert(length(this.internalValueScalarIndex{i})==1,'Incorrect mapping for internal variables');
                    mdIdx=this.internalValueScalarIndex{i}(1);
                    unit=this.valueScalarTable(mdIdx).unit;
                    treeItem=internal.fmuInterface.spreadSheetReal(this,0,name,unit,false);
                elseif this.internalValueStructure(i).DataType==1

                    treeItem=internal.fmuInterface.spreadSheetInteger(this,0,name,false);
                elseif this.internalValueStructure(i).DataType==2

                    treeItem=internal.fmuInterface.spreadSheetBoolean(this,0,name,false);
                elseif this.internalValueStructure(i).DataType==3

                    treeItem=internal.fmuInterface.spreadSheetString(this,0,name,false);
                elseif this.internalValueStructure(i).DataType==4

                    treeItem=internal.fmuInterface.spreadSheetEnumeration(this,0,name,false);
                else
                    assert(false,'Invalid datatype from local VariableStructure.');
                end

                children(i)=treeItem;
            end


            localNode=internal.fmuInterface.spreadSheetStruct(this,0,...
            DAStudio.message('FMUBlock:FMU:InternalVariables'),'',children,true);
        end

        function treeItem=getVariable(this,i,baseIdx,namePrefix)
            name=this.valueStructure(i).Name;
            if~isempty(this.valueStructure(i).Dims)

                treeItem=this.getArrayVariable(i,baseIdx,name,[namePrefix,name]);
            else

                treeItem=this.getScalarVariable(i,baseIdx,name,[namePrefix,name]);
            end
        end

        function treeItem=getScalarVariable(this,i,baseIdx,name,namePrefix)
            this.valueStructureVisitedFlag(i)=1;
            isTop=strcmp(name,namePrefix);
            if~isequal(size(this.valueStructure(i).ChildrenIndex),[1,0])

                treeItem=this.getStructureVariable(i,baseIdx,name,namePrefix);
            else
                this.workingIndex(2)=baseIdx+1;

                mdIdx=this.valueScalarIndex{this.workingIndex(1)}(this.workingIndex(2));

                if mdIdx>0
                    if this.valueStructure(i).DataType==0

                        unit=this.valueScalarTable(mdIdx).unit;
                        treeItem=internal.fmuInterface.spreadSheetReal(this,i,name,unit,isTop);
                    elseif this.valueStructure(i).DataType==1

                        treeItem=internal.fmuInterface.spreadSheetInteger(this,i,name,isTop);
                    elseif this.valueStructure(i).DataType==2

                        treeItem=internal.fmuInterface.spreadSheetBoolean(this,i,name,isTop);
                    elseif this.valueStructure(i).DataType==3

                        treeItem=internal.fmuInterface.spreadSheetString(this,i,name,isTop);
                    elseif this.valueStructure(i).DataType==4

                        treeItem=internal.fmuInterface.spreadSheetEnumeration(this,i,name,isTop);
                    else
                        assert(false,'Invalid datatype from VariableStructure.');
                    end
                    treeItem.setInternalItem(this.internalFlag);
                else
                    treeItem=[];
                end
            end
        end

        function treeItem=getArrayVariable(this,i,baseIdx,name,namePrefix)
            dimsIsZeroBased=uint32(this.valueStructure(i).IsDimsZeroBased);
            dims=this.valueStructure(i).Dims+dimsIsZeroBased;


            children(prod(dims))=internal.fmuInterface.spreadSheetItem;
            dimsIter=ones(1,length(dims))-double(dimsIsZeroBased);
            skipIdxVect=[];
            rowIter=internal.fmudialog.rowMajorIterator(dims);
            for iter=1:prod(dims)
                dimsIter=rowIter.idx-double(dimsIsZeroBased);

                itemSize=this.valueStructure(i).NodeCount/prod(dims);
                indexStr=['[',regexprep(num2str(dimsIter,'%d '),' +',','),']'];
                retItem=getScalarVariable(this,i,baseIdx+((rowIter.colIdx-1)*itemSize),indexStr,[namePrefix,indexStr]);
                if isempty(retItem)
                    skipIdxVect(end+1)=iter;
                else
                    children(iter)=retItem;
                end


                rowIter.increment();
            end

            children(skipIdxVect(:))=[];

            busObjectName=this.valueStructure(i).BusObjectName;
            isTop=strcmp(name,namePrefix);
            if isempty(children)
                treeItem=[];
            else
                treeItem=internal.fmuInterface.spreadSheetArray(this,i,name,busObjectName,children,isTop);
                treeItem.setInternalItem(this.internalFlag);
            end
        end

        function treeItem=getStructureVariable(this,i,baseIdx,name,namePrefix)

            children(1,length(this.valueStructure(i).ChildrenIndex))=internal.fmuInterface.spreadSheetItem;
            childItemCnt=0;
            skipIdxVect=[];
            for iter=1:length(this.valueStructure(i).ChildrenIndex)
                childStructIdx=this.valueStructure(i).ChildrenIndex(iter);
                retItem=this.getVariable(childStructIdx,baseIdx+childItemCnt,[namePrefix,'.']);
                if isempty(retItem)
                    skipIdxVect(end+1)=iter;
                else
                    children(iter)=retItem;
                end
                childItemCnt=childItemCnt+this.valueStructure(childStructIdx).NodeCount;
            end

            children(skipIdxVect(:))=[];
            if isempty(children)
                treeItem=[];
            else
                busObjectName=this.valueStructure(i).BusObjectName;
                isTop=strcmp(name,namePrefix);
                treeItem=internal.fmuInterface.spreadSheetStruct(this,i,name,busObjectName,children,isTop);
                treeItem.setInternalItem(this.internalFlag);
            end
        end
    end
end

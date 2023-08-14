classdef(Hidden=true)FMUSpreadSheetSource<handle

    properties
        valueString;
        valueWidgetType;
        valueWidgetOptions;
        valueStructure;
valueScalarIndex
valueScalarTable
        spreadRowObjs;
        dlgSource;
        showAsStruct;

        valueStructureVisitedFlag;
        valueStructurePosition;
        workingString;
        workingTree;
        workingIndex;
        workingIndexFlat;
    end
    methods(Access=public)
        function this=FMUSpreadSheetSource(dlgSource,structExprString,structExprWidgetType,structExprWidgetOptions,...
            structHierarchy,scalarIndex,scalarTable,showAsStruct)
            this.valueString=structExprString;
            this.valueStructure=structHierarchy;
            this.valueScalarIndex=scalarIndex;
            this.valueScalarTable=scalarTable;
            this.valueWidgetType=structExprWidgetType;
            this.valueWidgetOptions=structExprWidgetOptions;
            this.spreadRowObjs=[];
            this.dlgSource=dlgSource;
            this.showAsStruct=showAsStruct;



            this.valueStructureVisitedFlag=zeros(size(this.valueStructure));
            this.valueStructurePosition={};


            this.spreadRowObjs=this.createParameterTreeView;
        end

        function children=getChildren(obj)
            children=obj.spreadRowObjs;
        end

    end
    methods(Access=private)

        function treeTable=createParameterTreeView(this)
            treeTable=[];
            this.workingIndex(1)=0;
            for i=1:length(this.valueStructureVisitedFlag)
                if this.valueStructureVisitedFlag(i)==0


                    this.workingIndex(1)=this.workingIndex(1)+1;
                    this.valueStructurePosition{this.workingIndex(1)}=[];




                    try
                        this.showAsStruct=false;

                        this.workingString=this.valueString{this.workingIndex(1)};
                        this.workingTree=mtree(this.workingString);
                        this.ValidateRoot(this.workingTree.root,i);
                    catch
                        this.showAsStruct=true;
                    end

                    this.workingIndex(2)=0;
                    this.workingIndexFlat=0;
                    treeTable=[treeTable,this.getParameter(i,0,'','')];
                end
            end
        end

        function ValidateRoot(this,node,structureIndex)
            assert(node.count==1&&node.iskind('PRINT'));
            assert(node.list.count==1);

            node=node.Arg;
            Validate(this,node,structureIndex);
        end

        function Validate(this,node,structureIndex)
            if~isempty(this.valueStructure(structureIndex).Dims)

                this.ValidateArray(node,structureIndex);
            else

                this.ValidateScalar(node,structureIndex);
            end
        end

        function ValidateArray(this,node,structureIndex)

            assert(node.count==1&&(node.iskind('CALL')||node.iskind('LB')));

            dimsIsZeroBased=uint32(this.valueStructure(structureIndex).IsDimsZeroBased);
            dims=this.valueStructure(structureIndex).Dims+dimsIsZeroBased;

            if node.iskind('CALL')
                assert(node.Left.iskind('ID')&&strcmp(node.Left.string,'reshape'));
                assert(node.Right.Next.Next.isnull);
                assert(node.Right.iskind('LB')&&node.Right.Arg.iskind('ROW')&&node.Right.Arg.Next.isnull);
                assert(node.Right.Next.iskind('LB')&&node.Right.Next.Arg.iskind('ROW')&&node.Right.Next.Arg.Next.isnull);

                elements=node.Right.Arg.Arg.List;
                dimarray=node.Right.Next.Arg.Arg.List;


                indices=dimarray.indices;
                assert(length(dims)==length(indices));
                for i=1:length(dims)
                    s=dimarray.select(indices(i));
                    assert(s.iskind('INT')&&strcmp(num2str(dims(i)),s.string)==1);
                end


                indices=elements.indices;
                assert(length(indices)==prod(dims));

                for i=1:length(indices)
                    s=elements.select(indices(i));
                    ValidateScalar(this,s,structureIndex);
                end
            else
                assert(length(dims)==1||(length(dims)==2&&dims(1)==1));
                assert(node.Arg.iskind('ROW')&&node.Arg.Next.isnull);

                elements=node.Arg.Arg.List;


                indices=elements.indices;
                assert(length(indices)==prod(dims));

                for i=1:length(indices)
                    s=elements.select(indices(i));
                    this.ValidateScalar(s,structureIndex);
                end
            end
        end

        function ValidateScalar(this,node,structureIndex)
            if~isequal(size(this.valueStructure(structureIndex).ChildrenIndex),[1,0])

                this.ValidateStruct(node,structureIndex);
            elseif this.valueStructure(structureIndex).DataType==0

                this.valueStructurePosition{end}{end+1}=[node.lefttreepos,node.righttreepos];
            elseif this.valueStructure(structureIndex).DataType==1

                this.valueStructurePosition{end}{end+1}=[node.lefttreepos,node.righttreepos];
            elseif this.valueStructure(structureIndex).DataType==2

                this.valueStructurePosition{end}{end+1}=[node.lefttreepos,node.righttreepos];
            elseif this.valueStructure(structureIndex).DataType==3

                this.valueStructurePosition{end}{end+1}=[node.lefttreepos,node.righttreepos];
            elseif this.valueStructure(structureIndex).DataType==4

                this.valueStructurePosition{end}{end+1}=[node.lefttreepos,node.righttreepos];
            else
                assert(false,'Invalid datatype from ParameterStructure.');
            end
        end

        function ValidateStruct(this,node,structureIndex)
            assert(node.count==1&&node.iskind('CALL'));
            assert(node.Left.iskind('ID')&&strcmp(node.Left.string,'struct'));

            elements=node.Right.List;
            indices=elements.indices;
            ind_counter=1;
            for i=1:length(this.valueStructure(structureIndex).ChildrenIndex)
                idx=this.valueStructure(structureIndex).ChildrenIndex(i);
                f=elements.select(indices(ind_counter));
                if f.iskind('CHARVECTOR')&&strcmp(f.string,['''',this.valueStructure(idx).VarName,''''])==1
                    s=elements.select(indices(ind_counter+1));
                    ind_counter=ind_counter+2;
                elseif f.iskind('NAMEVALUE')&&strcmp(f.Left.string,this.valueStructure(idx).VarName)==1
                    s=f.Right;
                    ind_counter=ind_counter+1;
                else
                    assert(false,'Invalid syntax for ParameterStructure expression.');
                end

                Validate(this,s,idx);
            end
            assert(ind_counter==length(elements.indices)+1,'Invalid syntax for ParameterStructure expression. ');
        end



        function treeItem=getParameter(this,i,baseIdx,namePrefix,descName)
            name=this.valueStructure(i).Name;
            vname=this.valueStructure(i).VarName;
            if~isempty(this.valueStructure(i).Dims)

                treeItem=this.getArrayParameter(i,baseIdx,name,[namePrefix,name],[descName,vname]);
            else

                treeItem=this.getScalarParameter(i,baseIdx,name,[namePrefix,name],[descName,vname]);
            end
        end

        function treeItem=getScalarParameter(this,i,baseIdx,name,namePrefix,descName)
            this.valueStructureVisitedFlag(i)=1;
            isTop=strcmp(name,namePrefix);
            if~isequal(size(this.valueStructure(i).ChildrenIndex),[1,0])

                treeItem=this.getStructureParameter(i,baseIdx,name,namePrefix,descName);
            else
                if~this.showAsStruct

                    this.workingIndex(2)=baseIdx+1;
                end

                this.workingIndexFlat=baseIdx+1;

                mdIdx=this.valueScalarIndex{this.workingIndex(1)}(this.workingIndexFlat);




                if mdIdx>0


                    description=this.valueScalarTable(mdIdx).description;
                    if this.valueStructure(i).DataType==0

                        unit=this.valueScalarTable(mdIdx).unit;
                        treeItem=internal.fmudialog.FMUSpreadSheetReal(this,name,unit,description,descName,isTop);
                    elseif this.valueStructure(i).DataType==1

                        treeItem=internal.fmudialog.FMUSpreadSheetInteger(this,name,description,descName,isTop);
                    elseif this.valueStructure(i).DataType==2

                        treeItem=internal.fmudialog.FMUSpreadSheetBoolean(this,name,description,descName,isTop);
                    elseif this.valueStructure(i).DataType==3

                        treeItem=internal.fmudialog.FMUSpreadSheetString(this,name,description,descName,isTop);
                    elseif this.valueStructure(i).DataType==4

                        treeItem=internal.fmudialog.FMUSpreadSheetEnumeration(this,name,description,descName,isTop);
                    else
                        assert(false,'Invalid datatype from ParameterStructure.');
                    end
                else
                    treeItem=[];
                end
            end
        end

        function treeItem=getArrayParameter(this,i,baseIdx,name,namePrefix,descName)
            dimsIsZeroBased=uint32(this.valueStructure(i).IsDimsZeroBased);
            dims=this.valueStructure(i).Dims+dimsIsZeroBased;


            children(prod(dims))=internal.fmudialog.FMUSpreadSheetItem;
            dimsIter=ones(1,length(dims))-double(dimsIsZeroBased);
            skipIdxVect=[];
            rowIter=internal.fmudialog.rowMajorIterator(dims);
            for iter=1:prod(dims)
                dimsIter=rowIter.idx-double(dimsIsZeroBased);
                indexStr=['[',regexprep(num2str(dimsIter,'%d '),' +',','),']'];

                itemSize=this.valueStructure(i).NodeCount/prod(dims);
                retItem=getScalarParameter(this,i,baseIdx+((rowIter.colIdx-1)*itemSize),indexStr,[namePrefix,indexStr],[descName,indexStr]);
                if isempty(retItem)
                    skipIdxVect(end+1)=iter;
                else
                    children(iter)=retItem;
                end


                rowIter.increment();
            end

            children(skipIdxVect(:))=[];

            isTop=strcmp(name,namePrefix);
            if isempty(children)
                treeItem=[];
            else
                treeItem=internal.fmudialog.FMUSpreadSheetArray(this,name,children,isTop);
            end
        end

        function treeItem=getStructureParameter(this,i,baseIdx,name,namePrefix,descName)

            children(1,length(this.valueStructure(i).ChildrenIndex))=internal.fmudialog.FMUSpreadSheetItem;
            childItemCnt=0;
            skipIdxVect=[];
            for iter=1:length(this.valueStructure(i).ChildrenIndex)
                childStructIdx=this.valueStructure(i).ChildrenIndex(iter);
                retItem=this.getParameter(childStructIdx,baseIdx+childItemCnt,[namePrefix,'.'],[descName,'.']);
                if isempty(retItem)
                    skipIdxVect(end+1)=iter;
                else
                    children(iter)=retItem;
                end
                childItemCnt=childItemCnt+this.valueStructure(childStructIdx).NodeCount;
            end

            children(skipIdxVect(:))=[];

            isTop=strcmp(name,namePrefix);
            if isempty(children)
                treeItem=[];
            else
                treeItem=internal.fmudialog.FMUSpreadSheetStruct(this,name,children,isTop);
            end
        end
    end
end

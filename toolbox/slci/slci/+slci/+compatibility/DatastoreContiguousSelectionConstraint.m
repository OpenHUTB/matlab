



classdef DatastoreContiguousSelectionConstraint<slci.compatibility.Constraint


    properties(Access=private)
        fDsmBlockH=[];
        fDataStoreName='';
        fDataStoreDim=[];
        fDataStoreType='';
    end

    methods


        function out=getDescription(aObj)%#ok
            out='Only contiguous element selection is allowed in data store selection';
        end


        function obj=DatastoreContiguousSelectionConstraint()
            obj.setEnum('DatastoreContiguousSelection');
            obj.setCompileNeeded(true);
            obj.setFatal(false);
        end


        function out=check(aObj)
            out=[];
            parentBlock=aObj.getOwner();
            assert(isa(parentBlock,'slci.simulink.DataStoreReadBlock')...
            ||isa(parentBlock,'slci.simulink.DataStoreWriteBlock'));
            aObj.fDsmBlockH=parentBlock.getDataStoreHandle();
            aObj.fDataStoreName=parentBlock.getParam('DataStoreName');
            aObj.fDataStoreType=aObj.getDataStoreType();
            aObj.fDataStoreDim=slci.internal.getDataStoreMemoryDimensions(...
            get_param(aObj.fDsmBlockH,'Object'));
            if~aObj.isCompatible()
                out=slci.compatibility.Incompatibility(...
                aObj,...
                'DatastoreContiguousSelection',...
                aObj.ParentBlock().getName());
            end
        end

    end

    methods(Access=private)


        function isCompat=isCompatible(aObj)
            isCompat=true;
            parentBlock=aObj.getOwner();
            selectionAst=parentBlock.getElementsAst();
            for k=1:numel(selectionAst)
                ast=selectionAst{k};
                if isa(ast,'slci.ast.SFAstArray')
                    if~aObj.isContiguous(ast)
                        isCompat=false;
                        return;
                    end
                end
            end
        end


        function res=isContiguous(aObj,ast)
            assert(isa(ast,'slci.ast.SFAstArray'));
            children=ast.getChildren();
            assert(numel(children)>=2);
            baseAst=children{1};
            dim=aObj.getDim(baseAst);
            if dim==-1


                res=false;
                return;
            end



            indices=children(2:end);


            assert(numel(dim)==numel(indices));
            indexWidth=zeros(numel(indices),1);
            for k=1:numel(indices)
                index=indices{k};
                range=aObj.getIndexRange(index,dim(k));
                if isempty(range)

                    res=false;
                    return;
                end

                if~isscalar(range)&&...
                    ~aObj.isRangeContiguous(range)
                    res=false;
                    return;
                end
                indexWidth(k)=range(end)-range(1)+1;
            end

            if numel(indices)==2


                nRows=dim(1);
                rowIndexWidth=indexWidth(1);
                colIndexWidth=indexWidth(2);
                isPartialRowSelection=rowIndexWidth<nRows;
                if(colIndexWidth>1)&&isPartialRowSelection
                    res=false;
                    return;
                end
            end
            res=true;
        end


        function range=getIndexRange(~,index,maxSize)
            if isa(index,'slci.ast.SFAstColon')...
                &&isempty(index.getChildren())
                range=1:maxSize;
            else
                [success,val]=...
                slci.matlab.astProcessor.AstSlciInferenceUtil.evalValue(index);
                if success
                    range=val;
                else
                    range=[];
                end
            end
        end





        function res=isRangeContiguous(~,range)
            assert(~isscalar(range));
            difference=diff(range);
            res=all(difference==1);
        end


        function dim=getDim(aObj,ast)
            dim=-1;
            if isa(ast,'slci.ast.SFAstIdentifier')&&...
                strcmpi(ast.getIdentifier(),aObj.fDataStoreName)
                dim=aObj.fDataStoreDim;
            elseif isa(ast,'slci.ast.SFAstDot')
                bDataType=aObj.getDataType(ast.getBase());
                if~isempty(bDataType)
                    fieldName=ast.getField();
                    dim=aObj.deriveFieldDim(bDataType,fieldName);
                end
            elseif isa(ast,'slci.ast.SFAstArray')


            else

                dim=-1;
            end
            if ischar(dim)
                dim=slci.internal.resolveSymbol(...
                dim,'int32',aObj.getOwner().getSID());
                if isempty(dim)
                    dim=-1;
                end
            end
        end


        function dim=deriveFieldDim(aObj,pDataType,fieldName)
            resolvedType=aObj.ParentBlock.getType(pDataType);
            assert(isa(resolvedType,'Simulink.Bus'));
            dim=slci.internal.getBusElementDimension(resolvedType,...
            fieldName,aObj.ParentBlock.getSID());
        end


        function dataType=getDataType(aObj,ast)
            if isa(ast,'slci.ast.SFAstIdentifier')&&...
                strcmpi(ast.getIdentifier(),aObj.fDataStoreName)
                dataType=aObj.fDataStoreType;
            elseif isa(ast,'slci.ast.SFAstDot')
                bDataType=aObj.getDataType(ast.getBase());
                if~isempty(bDataType)
                    fieldName=ast.getField();
                    dataType=aObj.deriveFieldType(bDataType,fieldName);
                end
            elseif isa(ast,'slci.ast.SFAstArray')
                base=ast.getChildren{1};
                dataType=aObj.getDataType(base);
            else

                dataType='';
            end
        end


        function dataType=deriveFieldType(aObj,pDataType,fieldName)
            resolvedType=aObj.ParentBlock.getType(pDataType);
            assert(isa(resolvedType,'Simulink.Bus'));
            for i=1:numel(resolvedType.Elements)
                if strcmp(resolvedType.Elements(i).Name,fieldName)
                    fieldType=resolvedType.Elements(i).DataType;
                    assert(~isempty(fieldType));
                    if strncmp(fieldType,'Bus:',4)
                        fieldType=strtrim(fieldType(5:end));
                    end
                    dataType=fieldType;
                    return;
                end
            end
            dataType='';
        end


        function dataType=getDataStoreType(aObj)
            dataType=get_param(aObj.fDsmBlockH,'OutDataTypeStr');
            if strncmp(dataType,'Bus:',4)
                dataType=strtrim(dataType(5:end));
            end
        end

    end

end

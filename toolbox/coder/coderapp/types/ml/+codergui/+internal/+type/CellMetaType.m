classdef CellMetaType<codergui.internal.type.MetaType




    properties(SetAccess=immutable)
        Id char='metatype.cell'
        CustomAttributes codergui.internal.type.AttributeDef=[...
        codergui.internal.type.AttributeDefs.TypeName
        codergui.internal.type.AttributeDefs.Extern
        codergui.internal.type.AttributeDefs.HeaderFile
        codergui.internal.type.AttributeDefs.Alignment
        codergui.internal.type.AttributeDefs.Homogeneous
        codergui.internal.type.AttributeDef('locked','Boolean',...
        'Name',message('coderApp:metaTypes:attrSpecifyFimath'),...
        'Description','Internal locked property of CellType',...
        'Visible',false,...
        'Value',false)
        codergui.internal.type.AttributeDefs.IndexAddress
        ]
    end

    methods
        function this=CellMetaType()
            this.IsLeaf=false;
            this.IsUserModifiableSubtree=false;
        end
    end

    methods(Access={?codergui.internal.type.MetaType,?codergui.internal.type.TypeMakerNode})
        function validateNode(this,node)
            homogeneous=node.get('homogeneous');
            if homogeneous
                if numel(node.Children)>1&&~isequal(node.Children.Class)
                    tmerror(message('coderApp:typeMaker:cannotHomogenizeIncompatibleChildren'));
                else
                    try

                        node.setCoderType(node.getCoderType());
                    catch
                        tmerror(message('coderApp:typeMaker:cannotHomogenizeIncompatibleChildren'));
                    end
                    node.multiSet(this.CustomAttributes(1:4),'IsVisible',num2cell(false(1,4)));
                end
            else
                node.multiSet(this.CustomAttributes(1:4),'IsVisible',num2cell(true(1,4)));
                this.handleExtern(node);
                this.validateSize(node.Size,node);
            end
        end

        function coderType=toCoderType(this,node,childTypes)
            [sz,varDims]=node.Size.toNewTypeArgs();
            [extern,header,alignment,homogeneous,locked]=node.multiGet(...
            this.CustomAttributes(2:end-1),'value','deal');
            assert(homogeneous||prod(sz)==numel(childTypes));

            coderType=coder.newtype('cell',childTypes,sz,varDims);
            coderType.Extern=extern;
            coderType.HeaderFile=header;
            coderType.Alignment=alignment;


            if locked||(homogeneous~=coderType.isHomogeneous())
                if homogeneous
                    coderType=coderType.makeHomogeneous();
                else
                    coderType=coderType.makeHeterogeneous();
                end
            end

            this.handleExtern(node);
            coderType=this.invokeCStructName(node,coderType);
        end

        function fromCoderType(this,node,coderType)
            node.multiSet(this.CustomAttributes(1:end-1),'value',{...
            coderType.TypeName,coderType.Extern,coderType.HeaderFile,...
            coderType.Alignment,coderType.isHomogeneous(),isLocked(coderType)},true);
            node=this.handleExtern(node);
            node.Size=codergui.internal.type.Size(coderType.SizeVector,coderType.VariableDims);

            if coderType.isHomogeneous()
                if~isempty(coderType.Cells)
                    cells=[coderType.Cells{:}];
                    node.assignChildTypes(cells(1),repmat(-1,1,1));
                    if isprop(cells(1),'Complex')
                        node.Children(1).set('complex',any([cells.Complex]));
                    end
                end
            else
                node.assignChildTypes(coderType.Cells);
            end
        end

        function address=validateAddress(~,address,node)
            if~isempty(address)
                address=codergui.internal.type.MetaType.validateNumericAddress(address,node);
            else
                address=[];
            end
        end

        function size=validateSize(this,size,node)
            homogeneous=node.get('homogeneous');
            dims=size.Dimensions;
            expectedCount=prod([dims.length]);
            if homogeneous
                if size.NumElements>0
                    expectedCount=1;
                end
            else
                if any([dims.length]==Inf)
                    tmerror(message('coderApp:typeMaker:heterogeneousCellArrayCannotBeUnbounded'));
                elseif any([dims.variableSized]==true)
                    tmerror(message('coderApp:typeMaker:heterogeneousCellArrayCannotBeVarSized'));
                end
                if expectedCount>100
                    tmerror(message('coderApp:typeMaker:exceedsHeterogeneousCellArrayMaxSizeLimit',expectedCount));
                end
            end

            curCount=numel(node.Children);
            if curCount>expectedCount
                node.remove(expectedCount+1:curCount);
            elseif curCount<expectedCount
                node.append(expectedCount-curCount);
            end
            this.updateChildrenAddresses(node,size);
        end

        function applyClass(this,node,~)
            this.validateSize(node.Size,node);
        end

        function initializeChildren(~,~,childNodes)
            childNodes.multiSet('class',[],repmat({'double'},1,numel(childNodes)));
            childNodes.multiSet('address','IsEnabled',repmat({false},1,numel(childNodes)),true);
        end

        function code=toCode(this,node,varName,context)
            if node.get('homogeneous')
                switcher='makeHomogeneous';
                structNameCode='';
            else
                switcher='makeHeterogeneous';
                structNameCode=this.cStructNameToCode(node,varName);
                if~isempty(structNameCode)
                    structNameCode=[newline(),structNameCode];
                end
            end
            [sz,varDims]=node.Size.toNewTypeArgs(true);
            if isempty(context.childPaths)
                pathExpr='';
            else
                pathExpr=strjoin(context.childPaths,', ');
            end
            code=sprintf([...
'%s = coder.newtype(''cell'', {%s}, %s, %s);\n'...
            ,'%s = %s.%s();%s'],...
            varName,pathExpr,sz,varDims,varName,varName,switcher,structNameCode);
        end

        function cellType=toMF0(this,node,model,childTypes)
            [typeName,extern,header,alignment,homogeneous]=...
            node.multiGet(this.CustomAttributes(1:end-1),'value','deal');







            if homogeneous
                cellType=coderapp.internal.codertype.HomogeneousCellType(model);



                if numel(node.Children)==1
                    cellType.BaseType=node.Children(1).getCoderType(model);
                elseif numel(node.Children)==0

                else
                    assert(false,'Homogeneous cell array with more than 1 child');
                end

            else
                cellType=coderapp.internal.codertype.HeterogeneousCellType(model);
                cellType.Extern=extern;
                cellType.HeaderFile=header;
                cellType.Alignment=alignment;
                cellType.Cells=childTypes;
            end

            cellType.TypeName=typeName;
            cellType.Size=node.Size.toMfzDims();
        end

        function class=fromMF0(this,node,mf0)
            class='cell';
            isHomogeneous=isa(mf0,'coderapp.internal.codertype.HomogeneousCellType');

            if isHomogeneous
                extern=false;
                headerFile='';
                alignment=-1;
            else
                extern=mf0.Extern;
                headerFile=mf0.HeaderFile;
                alignment=mf0.Alignment;
            end
            node.multiSet(this.CustomAttributes(1:end-1),'value',{...
            mf0.TypeName,extern,headerFile,...
            alignment,isHomogeneous,false},true);
            node=this.handleExtern(node);
            node.Size=codergui.internal.type.Size(mf0.Size);

            if isHomogeneous
                if~isempty(mf0.BaseType)
                    node.assignChildTypes(mf0.BaseType,-1);
                    if isprop(mf0.BaseType,'Complex')
                        node.Children(1).set('complex',mf0.BaseType.Complex);
                    end
                end
            else
                node.assignChildTypes(mf0.Cells);
            end

        end
    end

    methods(Static,Access=private)
        function updateChildrenAddresses(node,sizeObj)
            if sizeObj.NumElements>0&&node.get(codergui.internal.type.AttributeDefs.Homogeneous)
                addresses=repmat(-1,1,1);
            else
                [addresses{1:numel(sizeObj.Dimensions)}]=ind2sub([sizeObj.Dimensions.length],(1:sizeObj.NumElements)');
                addresses=[addresses{:}];
            end
            addresses=mat2cell(addresses,ones(1,size(addresses,1)),size(addresses,2));
            node.setChildrenAddresses(node.Children,addresses);
        end
    end
end


function locked=isLocked(ct)


    try
        if ct.isHomogeneous()
            ct.makeHeterogeneous();
        else
            ct.makeHomogeneous();
        end
        locked=false;
    catch
        locked=true;
    end
end

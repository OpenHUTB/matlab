classdef(Abstract)MetaType<handle&matlab.mixin.Heterogeneous



    properties(Abstract,SetAccess=immutable)
        Id char
    end

    properties(Abstract,Hidden,SetAccess=immutable)
        CustomAttributes codergui.internal.type.AttributeDef
    end

    properties(SetAccess=protected)
        IsLeaf(1,1)logical=true
        IsUserModifiableSubtree(1,1)logical=true
        SupportsChecksum(1,1)logical=true
    end

    properties(SetAccess=private)


        Attributes codergui.internal.type.AttributeDef=codergui.internal.type.AttributeDefs.empty()
        CustomSizeAttribute codergui.internal.type.AttributeDef=codergui.internal.type.AttributeDefs.empty()
        ChildAddressAttribute codergui.internal.type.AttributeDef=codergui.internal.type.AttributeDefs.empty()
    end

    properties(Access=private)
        KeyToIndex=codergui.internal.undefined()
    end

    properties(Dependent,Access=private)
IsValidated
    end

    methods
        function set.IsUserModifiableSubtree(this,modifiable)
            this.assertNotValidated();
            this.IsUserModifiableSubtree=modifiable;
        end

        function set.IsLeaf(this,leaf)
            this.assertNotValidated();
            this.IsLeaf=leaf;
        end

        function validated=get.IsValidated(this)
            validated=~codergui.internal.undefined(this.KeyToIndex);
        end
    end

    methods(Abstract,Access={?codergui.internal.type.MetaType,?codergui.internal.type.TypeMakerNode})



        coderType=toCoderType(this,node,childTypes)


        fromCoderType(this,node,coderType)






        code=toCode(this,node,varName,context)



        mf0=toMF0(this,node,model,childTypes)
        class=fromMF0(this,node,mf0)
    end

    methods(Access={?codergui.internal.type.MetaType,?codergui.internal.type.TypeMakerNode})
        function size=validateSize(~,size,node)
        end

        function address=validateAddress(~,address,node)
        end


        function applyToNode(this,node)%#ok<*INUSD>
        end



        function applyClass(this,node,typeClass)
        end


        function cleanupNode(this,node)
        end



        function initializeChildren(this,parentNode,childNodes)
        end


        function validateNode(this,node)
        end



        function childTypeVars=preToCode(~,node)
            childTypeVars=cell(1,node.NumChildren);
            for i=1:numel(node.Children)
                child=node.Children(i);
                childName=child.Address;
                if isnumeric(childName)
                    if isscalar(childName)
                        childName=['t',num2str(childName)];
                    else
                        childName=['t',strjoin(strsplit(num2str(childName)),'_')];
                    end
                end
                if~isvarname(childName)
                    childName=matlab.lang.makeValidName(childName);
                end
                childTypeVars{i}=childName;
            end
        end


        function value=resolveToValue(~,node)
            value=codergui.internal.undefined();
        end


        function redirectClass=getUserFacingClass(~,node)
            redirectClass='';
        end
    end

    methods
        function compatible=isCompatibleClass(~,className)
            compatible=false;
        end

        function supported=isSupported(~)
            supported=true;
        end
    end

    methods(Static,Sealed,Access=protected)
        function wrapper=annotate(value,varargin)
            wrapper=codergui.internal.util.AnnotatedValue(value,varargin{:});
        end

        function address=validateNumericAddress(address,node)
            if isempty(node.Parent)
                return
            end
            if~isrow(address)
                address=reshape(address,1,[]);
            end
            siblings=node.Parent.Children;
            siblings=siblings(siblings~=node);
            siblings=vertcat(siblings.Address);
            if~isempty(siblings)&&ismember(address,siblings,'rows')
                if isscalar(address)
                    tmerror('duplicateArrayIndex',address);
                else
                    tmerror('duplicateArrayIndices',['[',strjoin(string(address),', '),']']);
                end
            end
        end

        function autoAssignNameAddresses(parent,children,prefix)
            clashableNames=regexp({parent.Children.Address},sprintf('^%s(\\d+)$',prefix),'tokens','once');
            clashableNums=repmat({''},1,numel(clashableNames));
            for i=1:numel(clashableNames)
                if~isempty(clashableNames{i})
                    clashableNums{i}=clashableNames{i}{1};
                end
            end
            clashableNums=str2double(clashableNums);
            clashableNums=sort(clashableNums(~isnan(clashableNums)));
            nameCounter=0;

            for i=1:numel(children)
                while true
                    nameCounter=nameCounter+1;
                    if~ismembc(nameCounter,clashableNums)
                        children(i).Address=[prefix,num2str(nameCounter)];
                        break
                    end
                end
            end
        end
    end

    methods(Sealed,Access=protected)
        function assertNotValidated(this)
            if this.IsValidated
                codergui.internal.util.throwInternal('Metatypes are immutable once they have been validated');
            end
        end
    end

    methods(Sealed)
        function indices=getAttributeIndices(this,keys)
            isValid=this.KeyToIndex.isKey(keys);
            if~iscell(keys)
                keys={keys};
            end
            if~all(isValid)
                error('Invalid attribute keys: %s',strjoin(keys(~isValid),', '));
            end
            indices=this.KeyToIndex.values(keys);
            indices=[indices{:}];
        end

        function has=hasAttributes(this,keys)
            has=this.KeyToIndex.isKey(keys);
        end
    end

    methods(Static,Sealed)
        function address=validateNameAddress(address,node,invalidErrId,dupeErrId)
            address=strtrim(address);
            if~isempty(regexp(address,'^_|[^_A-Za-z0-9]','once'))
                tmerror(invalidErrId,address);
            end
            if isempty(node.Parent)
                if~node.TypeMaker.EnforceUniqueRoots
                    return
                end
                siblings=node.TypeMaker.Roots;
            else
                siblings=node.Parent.Children;
            end
            siblings=siblings(siblings~=node);
            siblings={siblings.Address};

            if ismember(address,siblings)
                tmerror(dupeErrId,address);
            end
        end
    end

    methods(Sealed,Hidden)
        function this=validate(this)
            if this.IsValidated
                return
            end


            [hasReserved,idx]=ismember({'size','address'},{this.CustomAttributes.Key});
            customAttributes=reshape(this.CustomAttributes,1,[]);
            if hasReserved(1)
                this.CustomSizeAttribute=customAttributes(idx(1));
            end
            if hasReserved(2)
                this.ChildAddressAttribute=customAttributes(idx(2));
            end
            customAttributes(idx(hasReserved))=[];


            attributes=[customAttributes,...
            codergui.internal.type.AttributeDefs.ValueExpression,...
            codergui.internal.type.AttributeDefs.InitValue,...
            codergui.internal.type.AttributeDef('isInternalValueExpr','Boolean','Visible',false)];
            this.Attributes=attributes;

            keys={attributes.Key};
            if~isempty(keys)
                if numel(unique(keys))~=numel(keys)
                    codergui.internal.util.throwInternal('MetaType attribute keys must be unique');
                end
                this.KeyToIndex=containers.Map(keys,num2cell(1:numel(keys)));
            else
                this.KeyToIndex=containers.Map();
            end
        end
    end

    methods(Static,Sealed,Access=protected)
        function coderType=invokeCStructName(node,coderType)
            [typeName,extern,header,alignment]=node.multiGet({'typeName','extern','headerFile','alignment'},'value','deal');
            if~isempty(typeName)
                args={};
                if extern
                    args(1:3)={'extern','Alignment',alignment};
                    if~isempty(header)
                        args(4:5)={'HeaderFile',header};
                    end
                end
                coderType=coder.cstructname(coderType,typeName,args{:});
            end
        end

        function node=handleExtern(node)
            externAttr=node.attr('extern');
            typeNameAttr=node.attr('typeName');
            if externAttr.Value&&isempty(typeNameAttr.Value)
                tmerror(message('coderApp:typeMaker:externStructCannotHaveEmptyTypeName'));
            else
                IsVisible=externAttr.IsVisible&&externAttr.IsEnabled&&externAttr.Value;
                node.multiSet({'headerFile','alignment'},'IsVisible',num2cell(repmat(IsVisible,2,1)));
            end
        end

        function structNameCode=cStructNameToCode(node,varName)
            structNameCode='';
            [typeName,extern,header,alignment]=node.multiGet({'typeName','extern','headerFile','alignment'},'value','deal');
            [hasHeader,hasAlignment]=node.multiGet({'headerFile','alignment'},'HasNonDefaultValue','deal');
            if~isempty(typeName)||extern||hasHeader||hasAlignment
                extraArgs={};
                if extern
                    extraArgs{end+1}='''extern''';
                    if hasHeader
                        extraArgs(end+1:end+2)={'''HeaderFile''',['''',header,'''']};
                    end
                    if hasAlignment
                        extraArgs(end+1:end+2)={'''Alignment''',num2str(alignment)};
                    end
                end
                structNameCode=sprintf('%s = coder.cstructname(%s, ''%s''%s);',...
                varName,varName,typeName,strjoin(strcat({', '},extraArgs),''));
            end
        end

        function applyNonDefaultAttributes(node,attrDefs,values)
            assert(numel(attrDefs)==numel(values));
            different=false(1,numel(attrDefs));
            for i=1:numel(attrDefs)
                different(i)=~isequal(attrDefs(i).InitialValue,values{i});
            end
            if any(different)
                node.multiSet(attrDefs(different),[],values(different));
            end
        end
    end
end

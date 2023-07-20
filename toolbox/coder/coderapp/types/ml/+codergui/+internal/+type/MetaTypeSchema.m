classdef(Sealed)MetaTypeSchema<handle




    properties(SetAccess=immutable)


        UnboundClassWhitelist=codergui.internal.undefined()
    end

    properties
        DefaultClass='double'
    end

    properties(Dependent,SetAccess=immutable)
        BoundClasses cell
    end

    properties(SetAccess=private)
        MetaTypes codergui.internal.type.MetaType=codergui.internal.type.MetaType.empty()
    end

    properties(GetAccess=private,SetAccess=immutable)
        TypesByClass containers.Map
    end

    properties(Access=private)
        SealCount double=0
    end

    methods
        function this=MetaTypeSchema(unboundClassWhitelist)
            this.TypesByClass=containers.Map();
            if nargin>0
                assert(iscellstr(unboundClassWhitelist));%#ok<ISCLSTR>
                this.UnboundClassWhitelist=unboundClassWhitelist;
            end
        end

        function bind(this,metaType,varargin)
            this.assertUnsealed();
            validateattributes(metaType,{'codergui.internal.type.MetaType'},{'scalar'});
            classNames=this.validateClassArg(true,varargin);

            prior=this.MetaTypes(strcmp({this.MetaTypes.Id},metaType));
            if~isempty(prior)&&metaType~=this.MetaTypes(known)
                codergui.internal.util.throwInternal('Duplicate MetaType ID: %s',metaType.Id);
            elseif isempty(prior)
                this.MetaTypes(end+1)=metaType;
            end

            if~isempty(classNames)
                for i=1:numel(classNames)
                    this.TypesByClass(classNames{i})=metaType;
                end
            end

            metaType.validate();
        end

        function metaType=getMetaType(this,className)
            if this.TypesByClass.isKey(className)
                metaType=this.TypesByClass(className);
            elseif~codergui.internal.undefined(this.UnboundClassWhitelist)&&...
                ~ismember(this.UnboundClassWhitelist,className)
                tmerror('unsupportedClass',className);
            else
                if~ismember('coder.Type',superclasses(className))
                    for i=1:numel(this.MetaTypes)
                        metaType=this.MetaTypes(i);
                        if metaType.isCompatibleClass(className)
                            return;
                        end
                    end
                end
                metaType=codergui.internal.undefined();
            end
        end

        function boundClasses=get.BoundClasses(this)
            boundClasses=this.TypesByClass.keys();
        end
    end

    methods(Access=?codergui.internal.type.TypeMaker)
        function seal(this)
            this.SealCount=this.SealCount+1;
        end

        function unseal(this)
            this.SealCount=max(this.SealCount-1,0);
        end
    end

    methods(Access=private)
        function assertUnsealed(this)
            if this.SealCount==0
                return;
            end
            frames=dbstack(1);
            codergui.internal.util.throwInternal('"%s" can only be called on schemas not currently in use',frames(1).name);
        end
    end

    methods(Static,Access=private)
        function classNames=validateClassArg(allowEmpty,varargin)
            if nargin>2
                classNames=varargin;
            elseif nargin==2
                classNames=varargin{1};
                if~iscell(classNames)
                    classNames={classNames};
                end
            elseif~allowEmpty
                codergui.internal.util.throwInternal('No class names were specified');
            end
            if~iscellstr(classNames)
                codergui.internal.util.throwInternal('Class names should be char or cell arrays of char');
            end
        end
    end

    methods(Static)
        function schema=default()
            schema=codergui.internal.type.MetaTypeSchema();
            schema.bind(codergui.internal.type.PrimitiveMetaType,...
            'coder.PrimitiveType',...
            'coderapp.internal.codertype.PrimitiveType',...
            'char','logical','double','single','int64','uint64',...
            'int32','uint32','int16','uint16','int8','uint8','gpuArray','half');
            schema.bind(codergui.internal.type.StructMetaType,...
            'coder.StructType',...
            'coderapp.internal.codertype.StructType',...
            'struct');
            schema.bind(codergui.internal.type.StringMetaType,...
            'string',...
            'coderapp.internal.codertype.StringType');






            schema.bind(codergui.internal.type.CellMetaType,...
            'cell',...
            'coderapp.internal.codertype.HeterogeneousCellType',...
            'coderapp.internal.codertype.HomogeneousCellType');
            schema.bind(codergui.internal.type.FiMetaType,...
            'embedded.fi',...
            'coderapp.internal.codertype.FiType');
            schema.bind(codergui.internal.type.OutputRefMetaType,...
            'coder.OutputType',...
            'coderapp.internal.codertype.OutputType');
            schema.bind(codergui.internal.type.ConstantMetaType,...
            'coder.Constant',...
            'coderapp.internal.codertype.Constant');
            schema.bind(codergui.internal.type.CustomMetaType,'coder.type.Base');
            schema.bind(codergui.internal.type.ClassMetaType);
            schema.bind(codergui.internal.type.EnumMetaType,...
            'coderapp.internal.codertype.EnumType');
        end
    end
end

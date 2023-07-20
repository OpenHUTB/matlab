classdef(Sealed)ValueTypes<codergui.internal.ui.ValueType




    enumeration
        Any([])
        Text('','Validator',@mustBeScalarText)
        Number(0,'Validator',@mustBeScalarNumber)
        Integer(0,'BaseType','Number','Validator',@mustBeScalarInteger)
        PositiveInteger(1,'BaseType','Integer','Validator',@mustBePositiveInteger)
        Boolean(false,'BaseType','Integer','Validator',@mustBeScalarLogical)
        MatlabCode('','BaseType','Text','Validator',@mustBeCode)
        MatlabIdentifier('ans','BaseType','Text','Validator',@mustBeMatlabName)
        MatlabClassName('','BaseType','Text','Validator',@mustBeValidClassName)
        MatlabFunctionName('','BaseType','MatlabIdentifier')
        IndexVector([],'Validator',@mustBeValidIndexVector)
        File('','BaseType','Text')
        Folder('','BaseType','Text')
        Size(codergui.internal.type.Size([0,0]),'Validator',@mustBeSize,'Encoder',@encodeSize,'Decoder',@decodeSize)
        NumericType([],'Validator',@mustBeNumericType)
        Fimath([],'Validator',@mustBeFimath)
    end

    properties(Dependent,SetAccess=immutable)
        Id char
    end

    properties(SetAccess=immutable)
        BaseValueType codergui.internal.ui.ValueType=codergui.internal.ui.ValueTypes.empty()
DefaultValue
    end

    properties(SetAccess=immutable,GetAccess=private)
        Validator=function_handle.empty()
        EncodePreProcessor=function_handle.empty()
        DecodePostProcessor=function_handle.empty()
    end

    methods
        function this=ValueTypes(defaultValue,varargin)
            this=this@codergui.internal.ui.ValueType(false);
            persistent ip;
            if isempty(ip)
                ip=inputParser();
                ip.addParameter('BaseType',[]);
                ip.addParameter('Validator',function_handle.empty());
                ip.addParameter('Encoder',function_handle.empty());
                ip.addParameter('Decoder',function_handle.empty());
            end
            ip.parse(varargin{:});
            if~isempty(ip.Results.BaseType)
                this.BaseValueType=codergui.internal.ui.ValueTypes.(ip.Results.BaseType);
            end
            this.Validator=ip.Results.Validator;
            this.DecodePostProcessor=ip.Results.Decoder;
            this.EncodePreProcessor=ip.Results.Encoder;

            this.DefaultValue=defaultValue;
        end
    end

    methods
        function value=validateValue(this,value)
            if~isempty(this.Validator)
                value=this.Validator(value);
            elseif~isempty(this.BaseValueType)
                value=this.BaseValueType.validateValue(value);
            end
        end

        function value=fromDecodedJson(this,decoded)
            if~isempty(this.DecodePostProcessor)
                value=feval(this.DecodePostProcessor,decoded);
            elseif~isempty(this.BaseValueType)
                value=this.BaseValueType.fromDecodedJson(decoded);
            else
                value=decoded;
            end
        end

        function encodable=toJsonEncodable(this,value)
            if~isempty(this.EncodePreProcessor)
                encodable=feval(this.EncodePreProcessor,value);
            elseif~isempty(this.BaseValueType)
                encodable=this.BaseValueType.toJsonEncodable(value);
            else
                encodable=value;
            end
        end

        function id=get.Id(this)
            id=char(this);
        end
    end
end


function value=mustBeValidClassName(value)
    value=mustBeScalarText(value);
    if~isempty(value)&&isempty(meta.class.fromName(value))
        codergui.internal.util.customError(message('coderApp:uicommon:valueNotMatlabClass'));
    end
end


function value=mustBeMatlabName(value)
    value=mustBeScalarText(value);
    if~isvarname(value)
        codergui.internal.util.customError(message('coderApp:uicommon:valueNotMatlabIdentifier'));
    end
end


function value=mustBeValidIndexVector(value)
    if~isvector(value)||~isnumeric(value)||any(abs(floor(value))~=value)||any(value==0)
        codergui.internal.util.customError(message('coderApp:uicommon:valueNotIndexVector'));
    else
        value=reshape(value,1,[]);
    end
end


function value=mustBeSize(value)
    if isempty(value)
        value=codergui.internal.type.Size();
        return
    end
    if~isscalar(value)||~isa(value,'codergui.internal.type.Size')
        codergui.internal.util.customError(message('coderApp:uicommon:valueNotSize'));
    end
end


function value=mustBeScalarNumber(value)
    if~isscalar(value)||~isnumeric(value)||~isreal(value)||issparse(value)||isa(value,'gpuArray')
        codergui.internal.util.customError(message('coderApp:uicommon:valueNotScalarNumber'));
    end
end


function value=mustBeScalarInteger(value)
    mustBeScalarNumber(value);
    if floor(value)~=value
        codergui.internal.util.customError(message('coderApp:uicommon:valueNotScalarInteger'));
    end
end


function value=mustBePositiveInteger(value)
    mustBeScalarInteger(value);
    if value<=0
        codergui.internal.util.customError(message('coderApp:uicommon:valueNotPositiveInteger'));
    end
end


function value=mustBeScalarLogical(value)
    if~isscalar(value)||~islogical(value)
        codergui.internal.util.customError(message('coderApp:uicommon:valueNotScalarLogical'));
    end
end


function value=mustBeScalarText(value)
    if isstring(value)&&isscalar(value)
        value=char(value);
    elseif~ischar(value)&&~isvector(value)
        codergui.internal.util.customError(message('coderApp:uicommon:valueNotScalarText'));
    end
end


function value=mustBeCode(value)
    value=strtrim(mustBeScalarText(value));
    if isempty(value)
        return
    end
    mt=mtree(value);
    if mt.count()==0||strcmp(mt.root().kind(),'ERR')
        codergui.internal.util.customError(message('coderApp:uicommon:valueNotMatlabCode'));
    end
end


function value=mustBeNumericType(value)
    if ischar(value)||isstring(value)
        try
            value=eval(value);
        catch
            value=[];
        end
    end
    if isa(value,'embedded.fi')
        value=numerictype(value);
    elseif~isa(value,'numerictype')
        codergui.internal.util.customError(message('coderApp:uicommon:valueNotNumericType'));
    end
end


function value=mustBeFimath(value)
    if ischar(value)||isstring(value)
        try
            value=eval(value);
        catch
            value=[];
        end
    end
    if~isa(value,'fimath')
        codergui.internal.util.customError(message('coderApp:uicommon:valueNotFimath'));
    end
end


function value=encodeSize(size)
    value=struct('dimensions',size.Dimensions,'numDimensions',size.NumDimensions,...
    'numElements',size.NumElements);
    for i=1:numel(size.Dimensions)
        value.dimensions(i).unbounded=value.dimensions(i).length==inf;
    end
    value.dimensions=num2cell(value.dimensions);
end


function size=decodeSize(value)
    if isempty(value)
        size=codergui.internal.type.Size;
        return
    end
    if~iscell(value)
        dims=num2cell(value);
    else
        dims=value;
    end
    for i=1:numel(dims)
        if~isstruct(dims{i})
            dims{i}=struct('length',dims{i},'variableSized',false);
        else
            if isfield(dims{i},'unbounded')
                if dims{i}.unbounded
                    dims{i}.length=Inf;
                end
                dims{i}=rmfield(dims{i},'unbounded');
            end
            if~isfield(dims{i},'variableSized')
                dims{i}.variableSize=false;
            end
        end
    end
    size=codergui.internal.type.Size([dims{:}]);
end
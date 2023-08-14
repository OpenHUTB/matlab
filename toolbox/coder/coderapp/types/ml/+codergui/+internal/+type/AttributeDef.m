classdef AttributeDef<handle&matlab.mixin.Heterogeneous




    properties(SetAccess=immutable)

        Key{mustBeValidKey}='placeholder'

        Name=''

        Description=''


        Category message=message.empty()

        ValueType codergui.internal.ui.ValueType=codergui.internal.ui.ValueTypes.empty()


        InitialAllowedValues={}

        InitialValue=codergui.internal.undefined()

        InitialVisible=true

        InitialEnabled=true


        InitialMin=-inf


        InitialMax=inf


        IncludeMin=true


        IncludeMax=true


        Step=1

        Internal=false
    end

    properties(SetAccess=immutable,GetAccess=private)
        CommitValidator{mustBeValidValidator}
        Presenter{mustBeValidValidator}
    end

    methods
        function this=AttributeDef(key,valueType,varargin)
            this.Key=key;
            if ischar(valueType)
                this.ValueType=codergui.internal.ui.ValueTypes.(valueType);
            else
                this.ValueType=valueType;
            end

            persistent ip;
            if isempty(ip)
                ip=inputParser();
                ip.addParameter('Name','',@mustBeTextOrMessage);
                ip.addParameter('Description','',@mustBeTextOrMessage);
                ip.addParameter('Validator',[],@(v)isempty(v)||isa(v,'function_handle'));
                ip.addParameter('Presenter',[],@(v)isempty(v)||isa(v,'function_handle'));
                ip.addParameter('Enabled',true,@islogical);
                ip.addParameter('Visible',true,@islogical);
                ip.addParameter('AllowedValues',{},@(v)~isobject(v));
                ip.addParameter('Min',-inf,@mustBeScalarNumber);
                ip.addParameter('IncludeMin',true,@islogical);
                ip.addParameter('Max',inf,@mustBeScalarNumber);
                ip.addParameter('IncludeMax',true,@islogical);
                ip.addParameter('Step',1,@mustBeScalarNumber);
                ip.addParameter('Value',codergui.internal.undefined());
                ip.addParameter('Category',[],@(v)isempty(v)||isa(v,'message'));
                ip.addParameter('Internal',false,@islogical);
            end
            ip.parse(varargin{:});
            results=ip.Results;

            this.Name=getMessageString(results.Name);
            this.Description=getMessageString(results.Description);
            this.CommitValidator=results.Validator;
            this.Presenter=results.Presenter;
            this.InitialAllowedValues=results.AllowedValues;
            this.InitialVisible=results.Visible;
            this.InitialEnabled=results.Enabled;
            this.InitialMin=results.Min;
            this.InitialMax=results.Max;
            this.IncludeMin=results.IncludeMin;
            this.IncludeMax=results.IncludeMax;
            this.Step=results.Step;
            this.Internal=results.Internal;

            if~codergui.internal.undefined(results.Value)
                this.InitialValue=this.ValueType.validateValue(results.Value);
            else
                this.InitialValue=this.ValueType.DefaultValue;
            end
            if~isempty(results.Category)
                this.Category=results.Category;
            end
        end

        function value=validateValue(this,value,node)
            if~isempty(this.CommitValidator)
                value=feval(this.CommitValidator,value,node);
            end
            value=this.basicValidateValue(value);
        end

        function value=valueToExternal(~,value)


        end

        function value=externalToValue(~,value)

        end

        function wrapper=valueToPresentation(this,value,forJson)

            if nargin>2&&forJson
                value=this.ValueType.toJsonEncodable(value);
            end
            wrapper=codergui.internal.util.PresentableValue(value);
            if~isempty(this.Presenter)
                [wrapper.DisplayValue,tags]=feval(this.Presenter,value);
                if~isempty(tags)
                    wrapper.Tags=tags;
                end
            end
        end
    end

    methods(Sealed,Access=protected)
        function value=basicValidateValue(this,value)
            try
                this.ValueType.validateValue(value);
            catch me
                codergui.internal.util.throwInternal(me);
            end
        end
    end
end


function mustBeValidKey(value)
    validateattributes(value,{'char'},{'scalartext'});
    if~isvarname(value)
        codergui.internal.util.throwInternal('Attribute keys must be valid MATLAB variable names: %s',value);
    end
end


function mustBeTextOrMessage(value)
    if ischar(value)
        validateattributes(value,{'char'},{'scalartext'});
    else
        validateattributes(value,{'message'},{'scalar'});
    end
end


function mustBeValidValidator(value)
    if~isa(value,'function_handle')&&~isempty(value)
        codergui.internal.util.throwInternal('Validator and presenter callbacks must be function handles');
    end
end


function mustBeScalarNumber(value)
    validateattributes(value,{'numeric'},{'real','scalar'});
end


function text=getMessageString(text)
    if isa(text,'message')
        text=text.getString();
    elseif isstring(text)
        text=char(text);
    end
end

classdef ResultData<handle



    properties
        Object;
        Type='violation';
        Parameter='';
        CurrentValue;
        SupportedValues={};
        UnsupportedValues={};
        SupportedRange=[];
    end

    methods(Access=public)
        function this=ResultData(Object,varargin)


            return;

            this.Object=Object;


            if nargin>1&&(mod(nargin-1,2)~=0)
                DAStudio.error('Advisor:engine:NoNameValuePairs');
            end

            for n=1:2:nargin-1
                if~ischar(varargin{n})
                    DAStudio.error('Advisor:engine:NameMustBeString');
                end

                switch lower(varargin{n})
                case 'type'
                    TypesEnum={'violation','informational'};

                    if~ischar(varargin{n+1})&&~any(strcmp(TypesEnum,varargin{n+1}))
                        DAStudio.error('Advisor:engine:UnsupportedInput');
                    end
                    this.Type=varargin{n+1};
                case 'parameter'
                    this.Parameter=varargin{n+1};
                case 'currentvalue'
                    this.CurrentValue=varargin{n+1};



                case 'supportedvalues'
                    if~isempty(this.UnsupportedValues)||~isempty(this.SupportedRange)
                        DAStudio.error('Advisor:engine:ResultOverspecified');
                    end
                    this.SupportedValues=varargin{n+1};
                case 'unsupportedvalues'
                    if~isempty(this.SupportedValues)||~isempty(this.SupportedRange)
                        DAStudio.error('Advisor:engine:ResultOverspecified');
                    end
                    this.UnsupportedValues=varargin{n+1};
                case 'supportedrange'
                    if~isempty(this.SupportedValues)||~isempty(this.UnsupportedValues)
                        DAStudio.error('Advisor:engine:ResultOverspecified');
                    end
                    this.SupportedRange=varargin{n+1};
                otherwise
                    DAStudio.error('Advisor:engine:UnsupportedPorpertyName');
                end
            end
        end

        function setObject(this,Object)
            this.Object=Object;
        end

        function Object=getObject(this)
            Object=this.Object;
        end

        function setType(this,Type)
            TypesEnum={'violation','informational'};

            if~ischar(Type)&&~any(strcmp(TypesEnum,Type))
                DAStudio.error('Advisor:engine:UnsupportedInput');
            end
            this.Type=Type;
        end

        function Type=getType(this)
            Type=this.Type;
        end

        function setParameter(this,ParameterName)
            if~ischar(ParameterName)
                DAStudio.error('Advisor:engine:UnsupportedInput');
            end
            this.Parameter=ParameterName;
        end

        function Parameter=getParameter(this)
            Parameter=this.Parameter;
        end

        function setCurrentValue(this,currentValue)
            this.CurrentValue=currentValue;
        end

        function currentValue=getCurrentValue(this)
            currentValue=this.CurrentValue;
        end

        function setSupportedValues(this,supportedValues)
            if~isempty(this.UnsupportedValues)||~isempty(this.SupportedRange)
                DAStudio.error('Advisor:engine:ResultOverspecified');
            end
            this.SupportedValues=supportedValues;
        end

        function supportedValues=getSupportedValues(this)
            supportedValues=this.SupportedValues;
        end

        function setUnsupportedValues(this,UnsupportedValues)
            if~isempty(this.SupportedValues)||~isempty(this.SupportedRange)
                DAStudio.error('Advisor:engine:ResultOverspecified');
            end
            this.UnsupportedValues=UnsupportedValues;
        end

        function UnsupportedValues=getUnsupportedValues(this)
            UnsupportedValues=this.UnsupportedValues;
        end

        function setSupportedRange(this,SupportedRange)
            if~isempty(this.SupportedValues)||~isempty(this.UnsupportedValues)
                DAStudio.error('Advisor:engine:ResultOverspecified');
            end
            this.SupportedRange=SupportedRange;
        end

        function SupportedRange=getSupportedRange(this)
            SupportedRange=this.SupportedRange;
        end
    end
end


classdef microstrip<rf.internal.txline.basetxline




    properties(Dependent)

Width

Thickness
    end

    properties(AbortSet,Dependent)

Height

        DielectricThickness(1,1)double{mustBePositive,mustBeFinite}
    end

    properties

EpsilonR

LossTangent

SigmaCond
    end

    properties(Constant,Access=protected)

        HeaderDescription='Microstrip'
        DefaultName='Microstrip';
    end

    properties(Hidden,Access=protected)
privateWidth
privateHeight
privateDielectricThickness
privateThickness
    end

    properties(Access=protected,Constant)

        DefaultWidth=0.6e-3;

        DefaultHeight=0.635e-3;

        DefaultThickness=0.005e-3;

        DefaultEpsilonR=9.8;

        DefaultLossTangent=0;

        DefaultSigmaCond=inf;
    end

    properties(SetAccess=immutable)
        Type(1,:)char{mustBeMember(Type,{'Standard','Embedded','Inverted','Suspended'})}='Standard'
    end

    properties(Dependent,Hidden)
TotalHeight
EpsilonEffective
CharacteristicImpedance
    end
...
...
...
...
...
...
...
...
...
...
...
...
...
    methods
        function obj=microstrip(varargin)
            parserObj=makeParser(obj);
            parse(parserObj,varargin{:});
            obj.Type=parserObj.Results.Type;
            setProperties(obj,parserObj);
            checkproperty(obj);
            checkStubMode(obj);
        end
    end

    methods(Access=protected,Hidden)
        function p=makeParser(obj)
            p=inputParser;
            p.CaseSensitive=false;
            addParameter(p,'Name',obj.DefaultName);
            addParameter(p,'Type',obj.Type);
            addParameter(p,'Width',obj.DefaultWidth);
            addParameter(p,'Height',obj.DefaultHeight);
            addParameter(p,'Thickness',obj.DefaultThickness);
            addParameter(p,'DielectricThickness',obj.DefaultHeight);
            addParameter(p,'EpsilonR',obj.DefaultEpsilonR);
            addParameter(p,'LossTangent',obj.DefaultLossTangent);
            addParameter(p,'SigmaCond',obj.DefaultSigmaCond);
            addParameter(p,'LineLength',0.0100);
            addParameter(p,'Termination','NotApplicable');
            addParameter(p,'StubMode','NotAStub');
        end

        function setProperties(obj,p)
            obj.Name=p.Results.Name;
            obj.Width=p.Results.Width;
            obj.Height=p.Results.Height;
            obj.Thickness=p.Results.Thickness;
            if any(strcmp(p.UsingDefaults,'DielectricThickness'))
                switch obj.Type
                case{'Standard','Inverted'}
                    obj.DielectricThickness=obj.Height;
                case 'Embedded'
                    obj.DielectricThickness=2*obj.Height;
                case 'Suspended'
                    obj.DielectricThickness=obj.Height/2;
                end
            else
                obj.DielectricThickness=p.Results.DielectricThickness;
            end
            obj.EpsilonR=p.Results.EpsilonR;
            obj.LossTangent=p.Results.LossTangent;
            obj.SigmaCond=p.Results.SigmaCond;
            obj.LineLength=p.Results.LineLength;
            obj.Termination=p.Results.Termination;
            obj.StubMode=p.Results.StubMode;
        end
    end

    methods
        function set.Width(obj,value)
            validateattributes(value,{'numeric'},...
            {'nonempty','scalar','finite','real','positive'},...
            'txlineMicrostrip','Width')

            if~(isempty(obj.Width)||isempty(obj.Height)||...
                isempty(obj.DielectricThickness)||isempty(obj.Thickness))
                if(value/obj.TotalHeight>20)||(value/obj.TotalHeight<0.05)
                    error(message('rf:rftxline:WidthHeightLimit',''));
                end
            end
            obj.privateWidth=value;
        end

        function set.Height(obj,value)
            validateattributes(value,{'numeric'},...
            {'nonempty','scalar','finite','real','positive'},...
            'txlineMicrostrip','Height')

            if~(isempty(obj.Width)||isempty(obj.Height))
                if(obj.Width/value>20)||(obj.Width/value<0.05)
                    error(message('rf:rftxline:WidthHeightLimit',''));
                end
            end
            if~(isempty(obj.DielectricThickness)||isempty(obj.Height))
                switch obj.Type
                case 'Embedded'
                    validateattributes(value,{'numeric'},{'scalar',...
                    '<',obj.DielectricThickness},'txlineMicrostrip','Height')
                case 'Suspended'
                    validateattributes(value,{'numeric'},{'scalar',...
                    '>',obj.DielectricThickness},'txlineMicrostrip','Height')
                end
            end
            obj.privateHeight=value;
            if strcmp(obj.Type,'Standard')
                obj.privateDielectricThickness=value;
            end
        end

        function set.DielectricThickness(obj,value)

            if~(isempty(obj.Width)||isempty(obj.Height)||...
                isempty(obj.DielectricThickness)||isempty(obj.Thickness))
                if(obj.Width/obj.TotalHeight>20)||(obj.Width/obj.TotalHeight<0.05)
                    error(message('rf:rftxline:WidthHeightLimit',''));
                end
            end
            switch obj.Type
            case 'Standard'
                obj.privateHeight=value;

            case 'Embedded'
                validateattributes(value,{'numeric'},{'scalar',...
                '>',obj.Height},'txlineMicrostrip','DielectricThickness')
            case 'Suspended'
                validateattributes(value,{'numeric'},{'scalar',...
                '<',obj.Height},'txlineMicrostrip','DielectricThickness')
            end
            obj.privateDielectricThickness=value;
        end

        function set.Thickness(obj,value)
            validateattributes(value,{'numeric'},...
            {'nonempty','scalar','finite','real','nonnegative'},...
            'txlineMicrostrip','Thickness')

            if~(isempty(obj.Width)||isempty(obj.Height)||...
                isempty(obj.DielectricThickness)||isempty(obj.Thickness))
                if(value/obj.TotalHeight>0.1)
                    error(message('rf:rftxline:ThicknessHeightLimit',''));
                end
            end
            obj.privateThickness=value;
        end

        function set.EpsilonR(obj,value)
            validateattributes(value,{'numeric'},{'nonempty','scalar',...
            'finite','real','positive','>',1},'txlineMicrostrip',...
            'EpsilonR')
            obj.EpsilonR=value;
        end

        function set.LossTangent(obj,value)
            validateattributes(value,{'numeric'},...
            {'nonempty','scalar','finite','real','nonnegative'},...
            'txlineMicrostrip','LossTangent')
            obj.LossTangent=value;
        end

        function set.SigmaCond(obj,value)
            validateattributes(value,{'numeric'},...
            {'nonempty','scalar','nonnan','real','positive'},...
            'txlineMicrostrip','SigmaCond')
            obj.SigmaCond=value;
        end

        function val=get.Width(obj)
            val=obj.privateWidth;
        end

        function val=get.Height(obj)
            val=obj.privateHeight;
        end

        function val=get.Thickness(obj)
            val=obj.privateThickness;
        end

        function val=get.DielectricThickness(obj)
            val=obj.privateDielectricThickness;
        end

        function val=get.TotalHeight(obj)
            switch obj.Type
            case{'Standard','Suspended'}
                val=obj.Height;
            case 'Embedded'
                val=obj.DielectricThickness;
            case 'Inverted'
                val=obj.DielectricThickness+obj.Height+obj.Thickness;
            end
        end

        function val=get.EpsilonEffective(obj)
            [~,val]=getZ0(obj);
        end

        function val=get.CharacteristicImpedance(obj)
            val=getZ0(obj);
        end

...
...
...
...
...
...
...
...
...
    end

    methods(Hidden)
        [y,z0_f,Eeff_f]=calckl(h,varargin)
        [Eeff_f,z0_f]=epsilonTypeEffect(h,Eeff_f,z0_f,we)
    end

    methods(Hidden)
        function checkproperty(obj)

            if~(isempty(obj.Width)||isempty(obj.Height)||...
                isempty(obj.DielectricThickness)||isempty(obj.Thickness))
                if(obj.Width/obj.TotalHeight>20)||(obj.Width/obj.TotalHeight<0.05)
                    error(message('rf:rftxline:WidthHeightLimit',''));
                end
            end

            if~(isempty(obj.Width)||isempty(obj.Height)||...
                isempty(obj.DielectricThickness)||isempty(obj.Thickness))
                if(obj.Thickness/obj.TotalHeight>0.1)
                    error(message('rf:rftxline:ThicknessHeightLimit',''));
                end
            end
        end
    end

    methods(Hidden,Access=protected)
        function plist1=getLocalPropertyList(obj)
            if strcmp(obj.Type,'Standard')
                plist1.Name=obj.Name;
                plist1.Width=obj.Width;
                plist1.Height=obj.Height;
                plist1.Thickness=obj.Thickness;
            else
                plist1.Name=obj.Name;
                plist1.Type=obj.Type;
                plist1.Width=obj.Width;
                plist1.Height=obj.Height;
                plist1.Thickness=obj.Thickness;
                plist1.DielectricThickness=obj.DielectricThickness;
            end
            plist1.EpsilonR=obj.EpsilonR;
            plist1.LossTangent=obj.LossTangent;
            plist1.SigmaCond=obj.SigmaCond;
            plist1.LineLength=obj.LineLength;
            plist1.Termination=obj.Termination;
            plist1.StubMode=obj.StubMode;
        end

        function out=localClone(in)
            to=metaclass(in);
            t1=findobj(to.PropertyList,'GetAccess','public','-AND',...
            'SetAccess','public','-AND','Hidden',0);
            outProp=arrayfun(@(x)x.Name,t1,'UniformOutput',false);
            nvPairs=reshape([['Type',outProp.'];...
            [in.Type,get(in,outProp)]],[],1);
            out=txlineMicrostrip(nvPairs{:});
        end
    end

    methods
        function[z0_f,Eeff_f]=getZ0(h,varargin)


            narginchk(1,2)
            checkStubMode(h);
            if nargin==2
                frequency=checktxlineFrequency(h,varargin{:});
                [~,z0_f,Eeff_f]=calckl(h,frequency);
            else
                [~,z0_f,Eeff_f]=calckl(h);
            end
        end
    end
end

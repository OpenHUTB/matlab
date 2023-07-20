classdef cpw<rf.internal.txline.basetxline




    properties(Dependent)

ConductorWidth

SlotWidth

Height

Thickness
    end

    properties

EpsilonR

LossTangent

SigmaCond

        ConductorBacked(1,1)logical{mustBeNumericOrLogical}=false
    end
    properties(Constant,Access=protected)

        HeaderDescription='CPW'
        DefaultName='CPW';
    end

    properties(Hidden,Access=protected)
privateConductorWidth
privateSlotWidth
privateHeight
privateThickness
    end

    properties(Access=protected,Constant)

        DefaultConductorWidth=0.6e-3;

        DefaultSlotWidth=0.2e-3;

        DefaultHeight=0.635e-3;

        DefaultThickness=0.005e-3;

        DefaultEpsilonR=9.8;

        DefaultLossTangent=0;

        DefaultSigmaCond=inf;
    end

    methods
        function obj=cpw(varargin)
            parserObj=makeParser(obj);
            parse(parserObj,varargin{:});
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
            addParameter(p,'ConductorWidth',obj.DefaultConductorWidth);
            addParameter(p,'SlotWidth',obj.DefaultSlotWidth);
            addParameter(p,'Height',obj.DefaultHeight);
            addParameter(p,'Thickness',obj.DefaultThickness);
            addParameter(p,'EpsilonR',obj.DefaultEpsilonR);
            addParameter(p,'LossTangent',obj.DefaultLossTangent);
            addParameter(p,'SigmaCond',obj.DefaultSigmaCond);
            addParameter(p,'LineLength',0.0100);
            addParameter(p,'ConductorBacked',obj.ConductorBacked)
            addParameter(p,'Termination','NotApplicable');
            addParameter(p,'StubMode','NotAStub');
        end

        function setProperties(obj,p)
            obj.Name=p.Results.Name;
            obj.ConductorWidth=p.Results.ConductorWidth;
            obj.SlotWidth=p.Results.SlotWidth;
            obj.Height=p.Results.Height;
            obj.Thickness=p.Results.Thickness;
            obj.EpsilonR=p.Results.EpsilonR;
            obj.LossTangent=p.Results.LossTangent;
            obj.SigmaCond=p.Results.SigmaCond;
            obj.LineLength=p.Results.LineLength;
            obj.ConductorBacked=p.Results.ConductorBacked;
            obj.Termination=p.Results.Termination;
            obj.StubMode=p.Results.StubMode;
        end
    end

    methods
        function set.ConductorWidth(obj,value)
            validateattributes(value,{'numeric'},...
            {'nonempty','scalar','nonnan','finite','real','positive'},...
            'cpw','ConductorWidth')

            if~(isempty(obj.ConductorWidth)||isempty(obj.SlotWidth))
                if(value/obj.SlotWidth>100)||(value/obj.SlotWidth<0.01)
                    error(message('rf:rftxline:ConductorwidthSlotwidthLimit',''));
                end
            end

            if(obj.Thickness/value>0.1)
                error(message('rf:rftxline:ThicknessConductorwidthLimit',''));
            end

            obj.privateConductorWidth=value;
        end

        function set.Height(obj,value)
            validateattributes(value,{'numeric'},...
            {'nonempty','scalar','nonnan','finite','real','positive'},...
            'cpw','Height')

            if~(isempty(obj.SlotWidth)||isempty(obj.Height))
                if(obj.SlotWidth/value>20)||(obj.SlotWidth/value<0.05)
                    error(message('rf:rftxline:SlotWidthHeightLimit',''));
                end
            end
            obj.privateHeight=value;
        end

        function set.Thickness(obj,value)
            validateattributes(value,{'numeric'},...
            {'nonempty','scalar','nonnan','finite','real','positive'},...
            'cpw','Thickness')
            if~(isempty(obj.Thickness)||isempty(obj.SlotWidth)||...
                isempty(obj.ConductorWidth))

                if(value/obj.SlotWidth>0.1)
                    error(message('rf:rftxline:ThicknessSlotwidthLimit',''));
                end

                if(value/obj.ConductorWidth>0.1)
                    error(message('rf:rftxline:ThicknessConductorwidthLimit',''));
                end
            end
            obj.privateThickness=value;
        end

        function set.SlotWidth(obj,value)
            validateattributes(value,{'numeric'},...
            {'nonempty','scalar','nonnan','finite','real','positive'},...
            'cpw','SlotWidth')
            if~(isempty(obj.SlotWidth)||isempty(obj.Height)||...
                isempty(obj.ConductorWidth)||isempty(obj.Thickness))

                if(value/obj.Height>20)||(value/obj.Height<0.05)
                    error(message('rf:rftxline:SlotWidthHeightLimit',''));
                end

                if(obj.ConductorWidth/value>100)||...
                    (obj.ConductorWidth/value<0.01)
                    error(message('rf:rftxline:ConductorwidthSlotwidthLimit',''));
                end

                if(obj.Thickness/value>0.1)
                    error(message('rf:rftxline:ThicknessSlotwidthLimit',''));
                end
            end
            obj.privateSlotWidth=value;
        end

        function set.EpsilonR(obj,value)
            validateattributes(value,{'numeric'},...
            {'nonempty','scalar','nonnan','finite','real','positive'},...
            'cpw','EpsilonR')

            if(value<=1)
                rferrhole='EpsilonR';
                error(message('rf:rftxline:LessThanOne',rferrhole));
            end
            obj.EpsilonR=value;
        end

        function set.LossTangent(obj,value)
            validateattributes(value,{'numeric'},...
            {'nonempty','scalar','nonnan','finite','real','nonnegative'},...
            'cpw','LossTangent')
            obj.LossTangent=value;
        end

        function set.SigmaCond(obj,value)
            validateattributes(value,{'numeric'},...
            {'nonempty','scalar','nonnan','real','positive'},...
            'cpw','SigmaCond')
            obj.SigmaCond=value;
        end

        function val=get.ConductorWidth(obj)
            val=obj.privateConductorWidth;
        end

        function val=get.SlotWidth(obj)
            val=obj.privateSlotWidth;
        end

        function val=get.Height(obj)
            val=obj.privateHeight;
        end

        function val=get.Thickness(obj)
            val=obj.privateThickness;
        end
    end

    methods(Hidden)
        [y,z0_f,Eeff_f]=calckl(h,varargin)
    end


    methods(Hidden)
        function checkproperty(obj)

            if(obj.SlotWidth/obj.Height>20)||(obj.SlotWidth/obj.Height<0.05)
                error(message('rf:rftxline:SlotWidthHeightLimit',''));
            end

            if(obj.ConductorWidth/obj.SlotWidth>100)||(obj.ConductorWidth/obj.SlotWidth<0.01)
                error(message('rf:rftxline:ConductorwidthSlotwidthLimit',''));
            end

            if(obj.Thickness/obj.SlotWidth>0.1)
                error(message('rf:rftxline:ThicknessSlotwidthLimit',''));
            end

            if(obj.Thickness/obj.ConductorWidth>0.1)
                error(message('rf:rftxline:ThicknessConductorwidthLimit',''));
            end

        end
    end

    methods(Hidden,Access=protected)
        function plist1=getLocalPropertyList(obj)
            plist1.Name=obj.Name;
            plist1.ConductorWidth=obj.ConductorWidth;
            plist1.SlotWidth=obj.SlotWidth;
            plist1.Height=obj.Height;
            plist1.Thickness=obj.Thickness;
            plist1.EpsilonR=obj.EpsilonR;
            plist1.LossTangent=obj.LossTangent;
            plist1.SigmaCond=obj.SigmaCond;
            plist1.LineLength=obj.LineLength;
            plist1.ConductorBacked=obj.ConductorBacked;
            plist1.Termination=obj.Termination;
            plist1.StubMode=obj.StubMode;
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

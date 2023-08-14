classdef(Sealed,ConstructOnLoad=true)AirspeedIndicator<...
    matlab.ui.control.internal.model.ComponentModel&...
    matlab.ui.control.internal.model.mixin.EnableableComponent&...
    matlab.ui.control.internal.model.mixin.VisibleComponent&...
    matlab.ui.control.internal.model.mixin.TooltipComponent&...
    matlab.ui.control.internal.model.mixin.ScaleColorsComponent&...
    matlab.ui.control.internal.model.mixin.PositionableComponent&...
    matlab.ui.control.internal.model.mixin.Layoutable





    properties(Dependent,AbortSet)
        Value{validateattributes(Value,{'numeric'},{'scalar','finite','nonempty','real'})}=0;
        Limits{validateattributes(Limits,{'numeric'},{'finite','nonempty','numel',2,'real'})}=[40,400];
        Airspeed{validateattributes(Airspeed,{'numeric'},{'scalar','finite','nonempty','real'})}=0;
    end
    properties(Access={?Aero.ui.control.AirspeedIndicator,...
        ?Aero.ui.control.internal.controller.AeroController})
        ValueProperties={'Airspeed'};
        PrivateLogic='false';
    end
    properties(Access='protected')
        PrivateValue=0;
        PrivateLimits=[40,400];
    end




    methods
        function obj=AirspeedIndicator(varargin)
            defaultSize=[120,120];
            obj.Value=0;
            obj.Limits=[40,400];
            obj.ScaleColorLimits=[0,120;...
            100,360;...
            360,380;...
            380,400];
            obj.ScaleColors=[255,255,255;...
            76,187,23;...
            252,209,22;...
            227,23,13]/255;
            obj.PrivateInnerPosition(3:4)=defaultSize;
            obj.PrivateOuterPosition(3:4)=defaultSize;
            obj.AspectRatioLimits=[1,1];
            obj.Type='uiaeroairspeed';

            if builtin('license','checkout','Aerospace_Toolbox')
                obj.PrivateLogic='true';
            else
                error(message('aero:licensing:noLicenseTlbx'));
            end
            parsePVPairs(obj,varargin{:});

        end
    end




    methods
        function set.Value(obj,newValue)

            finalValue=double(newValue);


            obj.PrivateValue=finalValue;

            obj.markPropertiesDirty({'Value'});
        end

        function value=get.Value(obj)
            value=obj.PrivateValue;
        end

        function set.Limits(obj,newValue)

            obj.PrivateLimits=matlab.ui.control.internal.model.PropertyHandling.validateFiniteLimitsInput(obj,double(newValue));


            markPropertiesDirty(obj,{'Limits','ScaleColorLimits'});
        end

        function value=get.Limits(obj)
            value=obj.PrivateLimits;
        end
        function set.Airspeed(obj,newValue)

            finalValue=double(newValue);


            obj.PrivateValue=finalValue;


            markPropertiesDirty(obj,{'Value'});
        end

        function value=get.Airspeed(obj)
            value=obj.PrivateValue;
        end
    end



    methods(Access=protected)

        function names=getPropertyGroupNames(obj)





            names={'Airspeed',...
            'ScaleColors',...
            'ScaleColorLimits',...
            'Limits'};

        end

        function str=getComponentDescriptiveLabel(obj)



            str=num2str(obj.Value);

        end
    end

end

classdef(Sealed,ConstructOnLoad=true)EGTIndicator<...
    matlab.ui.control.internal.model.ComponentModel&...
    matlab.ui.control.internal.model.mixin.EnableableComponent&...
    matlab.ui.control.internal.model.mixin.VisibleComponent&...
    matlab.ui.control.internal.model.mixin.TooltipComponent&...
    matlab.ui.control.internal.model.mixin.ScaleColorsComponent&...
    matlab.ui.control.internal.model.mixin.PositionableComponent&...
    matlab.ui.control.internal.model.mixin.Layoutable




    properties(Dependent,AbortSet)
        Value{validateattributes(Value,{'numeric'},{'scalar','finite','nonempty','real'})}=0;
        Limits{validateattributes(Limits,{'numeric'},{'finite','nonempty','numel',2,'real'})}=[0,1000];
        Temperature{validateattributes(Temperature,{'numeric'},{'scalar','finite','nonempty','real'})}=0;
    end

    properties(Access={?Aero.ui.control.EGTIndicator,...
        ?Aero.ui.control.internal.controller.AeroController})
        ValueProperties={'Temperature'};
        PrivateLogic='false';
    end

    properties(Access='protected')
        PrivateValue=0;
        PrivateLimits=[0,1000];
    end




    methods
        function obj=EGTIndicator(varargin)
            defaultSize=[120,120];
            obj.Value=0;
            obj.Limits=[0,1000];
            obj.ScaleColorLimits=[0,700;...
            700,900;...
            900,1000];
            obj.ScaleColors=[76,187,23;...
            252,209,22;...
            227,23,13]/255;
            obj.PrivateInnerPosition(3:4)=defaultSize;
            obj.PrivateOuterPosition(3:4)=defaultSize;
            obj.AspectRatioLimits=[1,1];

            if builtin('license','checkout','Aerospace_Toolbox')
                obj.PrivateLogic='true';
            else
                error(message('aero:licensing:noLicenseTlbx'));
            end
            obj.Type='uiaeroegt';

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

        function set.Temperature(obj,newValue)

            finalValue=double(newValue);


            obj.PrivateValue=finalValue;

            obj.markPropertiesDirty({'Value'});
        end

        function value=get.Temperature(obj)
            value=obj.PrivateValue;
        end

        function set.Limits(obj,newValue)

            obj.PrivateLimits=matlab.ui.control.internal.model.PropertyHandling.validateFiniteLimitsInput(obj,double(newValue));


            markPropertiesDirty(obj,{'Limits','ScaleColorLimits'});
        end

        function value=get.Limits(obj)
            value=obj.PrivateLimits;
        end
    end



    methods(Access=protected)

        function names=getPropertyGroupNames(obj)





            names={'Temperature',...
            'ScaleColors',...
            'ScaleColorLimits',...
            'Limits'};

        end
        function str=getComponentDescriptiveLabel(obj)



            str=num2str(obj.Value);

        end

    end
end

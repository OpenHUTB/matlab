classdef(Sealed,ConstructOnLoad=true)RPMIndicator<...
    matlab.ui.control.internal.model.ComponentModel&...
    matlab.ui.control.internal.model.mixin.EnableableComponent&...
    matlab.ui.control.internal.model.mixin.VisibleComponent&...
    matlab.ui.control.internal.model.mixin.TooltipComponent&...
    matlab.ui.control.internal.model.mixin.ScaleColorsComponent&...
    matlab.ui.control.internal.model.mixin.PositionableComponent&...
    matlab.ui.control.internal.model.mixin.Layoutable




    properties(Dependent,AbortSet)
        Value{validateattributes(Value,{'numeric'},{'scalar','finite','nonempty','real'})}=0;
        RPM{validateattributes(RPM,{'numeric'},{'scalar','finite','nonempty','real'})}=0;
    end
    properties(Constant=true)
        Limits{validateattributes(Limits,{'numeric'},{'finite','nonempty','numel',2,'real'})}=[0,110];
    end

    properties(Access={?Aero.ui.control.RPMIndicator,...
        ?Aero.ui.control.internal.controller.AeroController})
        ValueProperties={'RPM'};
        PrivateLogic='false';
    end

    properties(Access='protected')
        PrivateValue=0;
    end



    methods
        function obj=RPMIndicator(varargin)
            defaultSize=[120,120];
            obj.Value=0;
            obj.ScaleColorLimits=[0,100;...
            100,105;...
            105,110];
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
            obj.Type='uiaerorpm';

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

        function set.RPM(obj,newValue)

            finalValue=double(newValue);


            obj.PrivateValue=finalValue;

            obj.markPropertiesDirty({'Value'});
        end

        function value=get.RPM(obj)
            value=obj.PrivateValue;
        end
    end



    methods(Access=protected)

        function names=getPropertyGroupNames(obj)





            names={'RPM',...
            'ScaleColors',...
            'ScaleColorLimits'};

        end
        function str=getComponentDescriptiveLabel(obj)



            str=num2str(obj.Value);

        end

    end
end

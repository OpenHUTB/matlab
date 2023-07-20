classdef(Sealed,ConstructOnLoad=true)ClimbIndicator<...
    matlab.ui.control.internal.model.ComponentModel&...
    matlab.ui.control.internal.model.mixin.PositionableComponent&...
    matlab.ui.control.internal.model.mixin.EnableableComponent&...
    matlab.ui.control.internal.model.mixin.VisibleComponent&...
    matlab.ui.control.internal.model.mixin.TooltipComponent&...
    matlab.ui.control.internal.model.mixin.Layoutable





    properties(Dependent,AbortSet)
        Value{validateattributes(Value,{'numeric'},{'scalar','finite','nonempty','real'})}=0;
        MaximumRate{validateattributes(MaximumRate,{'numeric'},{'scalar','finite','nonzero','nonempty','nonnegative','real'})}=2000;
        ClimbRate{validateattributes(ClimbRate,{'numeric'},{'scalar','finite','nonempty','real'})}=0;
    end

    properties(Access={?Aero.ui.control.ClimbIndicator,...
        ?Aero.ui.control.internal.controller.AeroController})
        ValueProperties={'ClimbRate'};
        PrivateLogic='false';
        PrivateLimits=[0,2000];
    end

    properties(Access='protected')
        PrivateValue=0;
    end




    methods
        function obj=ClimbIndicator(varargin)




            defaultSize=[120,120];
            obj.PrivateInnerPosition(3:4)=defaultSize;
            obj.PrivateOuterPosition(3:4)=defaultSize;
            obj.AspectRatioLimits=[1,1];
            obj.Type='uiaeroclimb';
            obj.MaximumRate=2000;
            obj.Value=0;

            if builtin('license','checkout','Aerospace_Toolbox')
                obj.PrivateLogic='true';
            else
                error(message('aero:licensing:noLicenseTlbx'));
            end
            parsePVPairs(obj,varargin{:});
        end


        function set.Value(obj,newValue)

            finalValue=double(newValue);


            obj.PrivateValue=finalValue;


            markPropertiesDirty(obj,{'Value'});
        end

        function value=get.Value(obj)
            value=obj.PrivateValue;
        end

        function set.MaximumRate(obj,newValue)

            obj.PrivateLimits=[0,double(newValue)];


            markPropertiesDirty(obj,{'MaximumRate'});
        end

        function value=get.MaximumRate(obj)
            value=obj.PrivateLimits(2);
        end
        function set.ClimbRate(obj,newValue)

            finalValue=double(newValue);


            obj.PrivateValue=finalValue;


            markPropertiesDirty(obj,{'Value'});
        end

        function value=get.ClimbRate(obj)
            value=obj.PrivateValue;
        end

    end




    methods(Access=protected)

        function names=getPropertyGroupNames(obj)





            names={'ClimbRate',...
            'MaximumRate'};

        end

        function str=getComponentDescriptiveLabel(obj)



            str=num2str(obj.Value);

        end

    end
end

classdef(Sealed,ConstructOnLoad=true)Altimeter<...
    matlab.ui.control.internal.model.ComponentModel&...
    matlab.ui.control.internal.model.mixin.PositionableComponent&...
    matlab.ui.control.internal.model.mixin.EnableableComponent&...
    matlab.ui.control.internal.model.mixin.VisibleComponent&...
    matlab.ui.control.internal.model.mixin.TooltipComponent&...
    matlab.ui.control.internal.model.mixin.Layoutable





    properties(Dependent,AbortSet)
        Value{validateattributes(Value,{'numeric'},{'scalar','finite','nonempty','real'})}=0;
        Altitude{validateattributes(Altitude,{'numeric'},{'scalar','finite','nonempty','real'})}=0;
    end

    properties(Access={?Aero.ui.control.Altimeter,...
        ?Aero.ui.control.internal.controller.AeroController})
        ValueProperties={'Altitude'};
        PrivateLogic='false';
    end
    properties(Access='protected')
        PrivateValue=0;
    end



    methods
        function obj=Altimeter(varargin)




            defaultSize=[120,120];
            obj.PrivateInnerPosition(3:4)=defaultSize;
            obj.PrivateOuterPosition(3:4)=defaultSize;
            obj.AspectRatioLimits=[1,1];
            obj.Type='uiaeroaltimeter';

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

        function set.Altitude(obj,newValue)

            finalValue=double(newValue);


            obj.PrivateValue=finalValue;


            markPropertiesDirty(obj,{'Value'});
        end

        function value=get.Altitude(obj)
            value=obj.PrivateValue;
        end


    end




    methods(Access=protected)

        function names=getPropertyGroupNames(obj)





            names={'Altitude'};

        end
        function str=getComponentDescriptiveLabel(obj)



            str=num2str(obj.Value);

        end

    end
end

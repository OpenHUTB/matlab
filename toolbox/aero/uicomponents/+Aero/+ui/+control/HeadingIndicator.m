classdef(Sealed,ConstructOnLoad=true)HeadingIndicator<...
    matlab.ui.control.internal.model.ComponentModel&...
    matlab.ui.control.internal.model.mixin.PositionableComponent&...
    matlab.ui.control.internal.model.mixin.EnableableComponent&...
    matlab.ui.control.internal.model.mixin.VisibleComponent&...
    matlab.ui.control.internal.model.mixin.TooltipComponent&...
    matlab.ui.control.internal.model.mixin.Layoutable





    properties(Dependent,AbortSet)
        Value{validateattributes(Value,{'numeric'},{'scalar','finite','nonempty','real'})}=0;
        Heading{validateattributes(Heading,{'numeric'},{'scalar','finite','nonempty','real'})}=0;
    end

    properties(Access={?Aero.ui.control.HeadingIndicator,...
        ?Aero.ui.control.internal.controller.AeroController})
        ValueProperties={'Heading'};
        PrivateLogic='false';
    end
    properties(Access='protected')
        PrivateValue=0;
    end




    methods
        function obj=HeadingIndicator(varargin)




            defaultSize=[120,120];
            obj.Value=0;
            obj.PrivateInnerPosition(3:4)=defaultSize;
            obj.PrivateOuterPosition(3:4)=defaultSize;
            obj.AspectRatioLimits=[1,1];

            if builtin('license','checkout','Aerospace_Toolbox')
                obj.PrivateLogic='true';
            else
                error(message('aero:licensing:noLicenseTlbx'));
            end
            obj.Type='uiaeroheading';

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

        function set.Heading(obj,newValue)

            finalValue=double(newValue);


            obj.PrivateValue=finalValue;


            markPropertiesDirty(obj,{'Value'});
        end

        function value=get.Heading(obj)
            value=obj.PrivateValue;
        end



    end




    methods(Access=protected)

        function names=getPropertyGroupNames(obj)





            names={'Heading'};

        end
        function str=getComponentDescriptiveLabel(obj)



            str=num2str(obj.Value);

        end

    end
end

classdef(Sealed,ConstructOnLoad=true)ArtificialHorizon<...
    matlab.ui.control.internal.model.ComponentModel&...
    matlab.ui.control.internal.model.mixin.PositionableComponent&...
    matlab.ui.control.internal.model.mixin.EnableableComponent&...
    matlab.ui.control.internal.model.mixin.VisibleComponent&...
    matlab.ui.control.internal.model.mixin.TooltipComponent&...
    matlab.ui.control.internal.model.mixin.Layoutable





    properties(Dependent,AbortSet)
        Value{validateattributes(Value,{'numeric'},{'finite','nonempty','numel',2,'real'})}=[0,0];
        Pitch{validateattributes(Pitch,{'numeric'},{'scalar','finite','nonempty','real'})}=0;
        Roll{validateattributes(Roll,{'numeric'},{'scalar','finite','nonempty','real'})}=0;
    end
    properties(Access={?Aero.ui.control.ArtificialHorizon,...
        ?Aero.ui.control.internal.controller.AeroController})
        ValueProperties={'Roll','Pitch'};
        PrivateLogic='false';
    end
    properties(Access='protected')
        PrivateValue=[0,0];
    end



    methods
        function obj=ArtificialHorizon(varargin)




            defaultSize=[120,120];
            obj.Value=[0,0];
            obj.PrivateInnerPosition(3:4)=defaultSize;
            obj.PrivateOuterPosition(3:4)=defaultSize;
            obj.AspectRatioLimits=[1,1];

            if builtin('license','checkout','Aerospace_Toolbox')
                obj.PrivateLogic='true';
            else
                error(message('aero:licensing:noLicenseTlbx'));
            end
            obj.Type='uiaerohorizon';

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

        function set.Pitch(obj,newValue)

            finalValue=double(newValue);


            obj.PrivateValue(2)=finalValue;


            markPropertiesDirty(obj,{'Value'});
        end

        function value=get.Pitch(obj)
            value=obj.PrivateValue(2);
        end
        function set.Roll(obj,newValue)

            finalValue=double(newValue);


            obj.PrivateValue(1)=finalValue;


            markPropertiesDirty(obj,{'Value'});
        end

        function value=get.Roll(obj)
            value=obj.PrivateValue(1);
        end



    end




    methods(Access=protected)

        function names=getPropertyGroupNames(obj)





            names={'Pitch',...
            'Roll'};

        end

        function str=getComponentDescriptiveLabel(obj)



            str=['[',num2str(obj.Value),']'];

        end

    end
end

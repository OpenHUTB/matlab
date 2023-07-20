classdef(Sealed,ConstructOnLoad=true)TurnCoordinator<...
    matlab.ui.control.internal.model.ComponentModel&...
    matlab.ui.control.internal.model.mixin.PositionableComponent&...
    matlab.ui.control.internal.model.mixin.EnableableComponent&...
    matlab.ui.control.internal.model.mixin.VisibleComponent&...
    matlab.ui.control.internal.model.mixin.TooltipComponent&...
    matlab.ui.control.internal.model.mixin.Layoutable





    properties(Dependent,AbortSet)
        Value{validateattributes(Value,{'numeric'},{'finite','nonempty','numel',2,'real'})}=[0,0];
        Turn{validateattributes(Turn,{'numeric'},{'scalar','finite','nonempty','real'})}=0;
        Slip{validateattributes(Slip,{'numeric'},{'scalar','finite','nonempty','real'})}=0;
    end

    properties(Access={?Aero.ui.control.TurnCoordinator,...
        ?Aero.ui.control.internal.controller.AeroController})
        ValueProperties={'Turn','Slip'};
        PrivateLogic='false';
    end
    properties(Access='protected')
        PrivateValue=[0,0];
    end



    methods
        function obj=TurnCoordinator(varargin)




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
            obj.Type='uiaeroturn';

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
        function set.Turn(obj,newValue)

            finalValue=double(newValue);


            obj.PrivateValue(1)=finalValue;


            markPropertiesDirty(obj,{'Value'});
        end

        function value=get.Turn(obj)
            value=obj.PrivateValue(1);
        end
        function set.Slip(obj,newValue)
            validateattributes(newValue,...
            {'numeric'},...
            {'finite','nonempty'});


            finalValue=double(newValue);


            obj.PrivateValue(2)=finalValue;


            markPropertiesDirty(obj,{'Value'});
        end

        function value=get.Slip(obj)
            value=obj.PrivateValue(2);
        end


    end




    methods(Access=protected)

        function names=getPropertyGroupNames(obj)





            names={'Turn',...
            'Slip'};

        end
        function str=getComponentDescriptiveLabel(obj)



            str=['[',num2str(obj.Value),']'];

        end

    end
end

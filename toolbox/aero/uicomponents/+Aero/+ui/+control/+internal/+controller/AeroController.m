classdef(Hidden)AeroController<matlab.ui.control.internal.controller.ComponentController






    methods
        function obj=AeroController(varargin)
            obj@matlab.ui.control.internal.controller.ComponentController(varargin{:});
        end
    end

    methods(Access='protected')

        function viewPvPairs=getPropertiesForView(obj,propertyNames)
            import appdesservices.internal.util.ismemberForStringArrays;













            viewPvPairs={};



            viewPvPairs=[viewPvPairs,...
            getPropertiesForView@matlab.ui.control.internal.controller.ComponentController(obj,propertyNames),...
            'PrivateLogic',obj.Model.PrivateLogic];


            if ismemberForStringArrays("Value",propertyNames)
                viewPvPairs=[viewPvPairs,reshape([obj.Model.ValueProperties;num2cell(obj.Model.Value)],1,[])];
            end




            if isa(obj.Model,'Aero.ui.control.ClimbIndicator')&&...
                ismemberForStringArrays("MaximumRate",propertyNames)
                viewPvPairs=[viewPvPairs,'Limits',obj.Model.PrivateLimits];
            end
        end

        function handleEvent(obj,src,event)

            handleEvent@matlab.ui.control.internal.controller.ComponentController(obj,src,event);

            if(strcmp(event.Data.Name,'ValueChanged'))




                previousValue=obj.Model.Value;


                newValue=previousValue;


                valueChangedEventData=matlab.ui.eventdata.ValueChangedData(newValue,previousValue);



                obj.handleUserInteraction('ValueChanged',...
                {'ValueChanged',valueChangedEventData,'PrivateValue',newValue});

            end
        end
    end
end
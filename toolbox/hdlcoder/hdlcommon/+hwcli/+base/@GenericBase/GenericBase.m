


classdef GenericBase<hwcli.base.WorkflowBase





    properties(Hidden)



    end
    properties

RunTaskPerformLogicSynthesis
RunTaskPerformMapping
RunTaskPerformPlaceAndRoute
RunTaskRunSynthesis
RunTaskRunImplementation



    end





    methods
        function obj=GenericBase(workflow,tool)
            obj=obj@hwcli.base.WorkflowBase(workflow,tool);


            obj.RunTaskPerformLogicSynthesis=true;
            obj.RunTaskPerformMapping=true;
            obj.RunTaskPerformPlaceAndRoute=false;
            obj.RunTaskRunSynthesis=true;
            obj.RunTaskRunImplementation=false;



            obj.Properties(...
            'RunTaskRunImplementation')={'IgnorePlaceAndRouteErrors'};
            obj.Properties(...
            'RunTaskRunSynthesis')={'SkipPreRouteTimingAnalysis'};
            obj.Properties(...
            'RunTaskPerformPlaceAndRoute')={'IgnorePlaceAndRouteErrors'};
            obj.Properties(...
            'RunTaskPerformMapping')={'SkipPreRouteTimingAnalysis'};

        end
    end





    methods
        function set.RunTaskPerformLogicSynthesis(obj,val)
            obj.errorCheckTask('RunTaskPerformLogicSynthesis',val);
            obj.RunTaskPerformLogicSynthesis=val;
        end

        function set.RunTaskPerformMapping(obj,val)
            obj.errorCheckTask('RunTaskPerformMapping',val);
            obj.RunTaskPerformMapping=val;
        end

        function set.RunTaskPerformPlaceAndRoute(obj,val)
            obj.errorCheckTask('RunTaskPerformPlaceAndRoute',val);
            obj.RunTaskPerformPlaceAndRoute=val;
        end

        function set.RunTaskRunSynthesis(obj,val)
            obj.errorCheckTask('RunTaskRunSynthesis',val);
            obj.RunTaskRunSynthesis=val;
        end

        function set.RunTaskRunImplementation(obj,val)
            obj.errorCheckTask('RunTaskRunImplementation',val);
            obj.RunTaskRunImplementation=val;
        end

    end
end



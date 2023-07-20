


classdef TurnkeyBase<hwcli.base.GenericBase





    properties(Hidden)

    end

    properties

RunTaskGenerateRTLCode
RunTaskGenerateProgrammingFile


SkipPreRouteTimingAnalysis
IgnorePlaceAndRouteErrors
    end




    methods
        function obj=TurnkeyBase(workflow,tool)
            obj=obj@hwcli.base.GenericBase(workflow,tool);


            obj.RunTaskGenerateRTLCode=true;
            obj.RunTaskGenerateProgrammingFile=true;
            obj.RunTaskRunImplementation=true;
            obj.RunTaskPerformPlaceAndRoute=true;
            obj.SkipPreRouteTimingAnalysis=true;
            obj.IgnorePlaceAndRouteErrors=false;



        end
    end





    methods
        function set.RunTaskGenerateRTLCode(obj,val)
            obj.errorCheckTask('RunTaskGenerateRTLCode',val);
            obj.RunTaskGenerateRTLCode=val;
        end

        function set.RunTaskGenerateProgrammingFile(obj,val)
            obj.errorCheckTask('RunTaskGenerateProgrammingFile',val);
            obj.RunTaskGenerateProgrammingFile=val;
        end

        function set.SkipPreRouteTimingAnalysis(obj,val)
            if(strcmp(val,'On')||(islogical(val)&&val==true))
                obj.SkipPreRouteTimingAnalysis=true;
            elseif(strcmp(val,'Off')||(islogical(val)&&val==false))
                error(message('hdlcoder:workflow:ParameterMustBeSet','SkipPreRouteTimingAnalysis','true',obj.TargetWorkflow));
            else
                error(message('hdlcoder:workflow:InvalidToggleValue','SkipPreRouteTimingAnalysis'));
            end
        end

        function set.IgnorePlaceAndRouteErrors(obj,val)
            if(strcmp(val,'On')||(islogical(val)&&val==true))
                error(message('hdlcoder:workflow:ParameterMustBeSet','IgnorePlaceAndRouteErrors','false',obj.TargetWorkflow));
            elseif(strcmp(val,'Off')||(islogical(val)&&val==false))
                obj.IgnorePlaceAndRouteErrors=false;
            else
                error(message('hdlcoder:workflow:InvalidToggleValue','IgnorePlaceAndRouteErrors'));
            end
        end

    end
end


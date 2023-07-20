classdef MASFEditTimeManager<handle




    properties
        cache=[]
        runFlag=false;
    end

    methods(Static=true)
        function singleObj=getInstance()
            persistent localStaticObj;
            if isempty(localStaticObj)||~isvalid(localStaticObj)
                localStaticObj=slcheck.MASFEditTimeManager;
            end
            singleObj=localStaticObj;
        end
    end


    methods(Access='public')
        function clearCache(this)
            this.cache=containers.Map;
            this.runFlag=false;
        end

        function results=getSFViolation(this,SFChart,taskID)


            if this.runFlag
                results=this.getViolation(SFChart,taskID);
                return;
            end

            this.updateCache(SFChart)

            results=this.getViolation(SFChart,taskID);

            this.runFlag=true;

        end

    end

    methods(Access='private')

        function obj=MASFEditTimeManager()
            obj.cache=containers.Map;
        end

        function violation=getViolation(this,SFChart,taskID)

            violation=[];

            key=int2str(SFChart.Id);

            if~this.cache.isKey(key)
                this.updateCache(SFChart)
                violation=this.getViolation(SFChart,taskID);
                return
            end

            taskCache=this.cache(key);

            if~taskCache.isKey(taskID)
                return
            end

            violation=taskCache(taskID);

        end

        function issue=callSFETAlgorithm(~,Obj)
            issue=[];
            try
                issue=sf('GetMALintIssues',Obj.Id);
            catch exc
                if strcmp(exc.identifier,'slcheck:configurationManager:UnknownConfigurationType')
                    DAStudio.warning...
                    ('ModelAdvisor:engine:MASFEditTimeManager');
                    return;
                else
                    throw(exc)
                end
            end
        end

        function flag=isRunTimeJSONUpdated(~)
            slConfig=slcheck.ConfigurationManagerInterface();
            flag=slConfig.isRunTimeJSONUpdated;
        end

        function updateCache(this,SFChart)

            violation=this.callSFETAlgorithm(SFChart);
            key=int2str(SFChart.Id);

            if isempty(violation)
                this.cache(key)=containers.Map;
                return
            end

            taskCache=containers.Map;

            for vCount=1:numel(violation)
                taskID=violation(vCount).MATaskId;

                if~taskCache.isKey(taskID)
                    taskCache(taskID)={violation(vCount)};
                else
                    taskCache(taskID)=[taskCache(taskID),...
                    violation(vCount)];
                end

            end

            this.cache(key)=taskCache;
        end
    end
end

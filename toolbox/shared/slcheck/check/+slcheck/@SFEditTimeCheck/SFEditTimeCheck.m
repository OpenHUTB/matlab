classdef SFEditTimeCheck<slcheck.subcheck




    properties(Access=private)
SFETmessageInfo
TaskID
    end

    methods(Access=public)

        function obj=SFEditTimeCheck(InitParams)
            obj.CompileMode='None';
            obj.Licenses={'Stateflow'};
            obj.ID=InitParams.MAMsgCataloguePrefix;
            obj.TaskID="";

            if ischar(InitParams.SFETMsgCataloguePrefix)&&...
                strcmp(InitParams.SFETMsgCataloguePrefix,'CUSTOM')


                return;
            end

            try

                if~iscell(InitParams.SFETMsgCataloguePrefix)
                    InitParams.SFETMsgCataloguePrefix={InitParams.SFETMsgCataloguePrefix};
                end

                obj.SFETmessageInfo=cellfun(@(x)...
                DAStudio.message(strcat('Stateflow:sflint:',x,'Details')),...
                InitParams.SFETMsgCataloguePrefix,'UniformOutput',false);

            catch E
                DAStudio.warning('ModelAdvisor:engine:SFEditTimeCheckRegister',obj.ID,E.message);
            end

        end

        function result=run(this)

            result=false;

            violation=this.getViolation();
            violation=this.filterSFEViolationWithCheckID(violation);

            if 0==numel(violation)
                return;
            end

            violation=this.filterAndSortViolation(violation);
            vObj=this.getResultDetailObject(violation);

            result=this.setResult(vObj);

        end

        function id=getTaskID(this)
            id=this.TaskID;
        end

        function setTaskID(this,id)
            if id==""
                DAStudio.error('ModelAdvisor:engine:SFEditTimeTaskIDNot')
            end
            this.TaskID=id;
        end
    end

    methods(Access=protected)
        function results=getViolation(this)

            SFChart=this.getEntity();

            if slfeature("SFETIntegration")==0&&...
                ~isa(SFChart,'Stateflow.Chart')
                SFChart=SFChart.Chart;
            elseif slfeature("SFETIntegration")==1&&...
                ~any([isa(SFChart,'Stateflow.Chart')...
                ,isa(SFChart,'Stateflow.StateTransitionTableChart')...
                ,isa(SFChart,'Stateflow.TruthTable')])
                DAStudio.error('ModelAdvisor:engine:SFEditTimeCheckEntity');
            end

            sfManObj=slcheck.MASFEditTimeManager.getInstance();
            results=sfManObj.getSFViolation(SFChart,this.TaskID);


            if isempty(results)||...
                0==numel(results)
                results={};
                return;
            end

            if~iscell(results)
                results={results};
            end

        end

        function violation=convertToSID(~,violation)

            if isempty(violation)
                return;
            end

            violation=cellfun(@(x)idToHandle(sfroot,x.objectId),...
            violation,'UniformOutput',false);
        end

        function violation=filterAndSortViolation(~,violation)

            if isempty(violation)
                return;
            end

            hashs=cellfun(@(x)x.MAResultDetail.getHash,violation,'UniformOutput',false);
            [~,uniqueIndex,~]=unique(hashs);
            violation=violation(uniqueIndex);
            sids=cellfun(@(x)ModelAdvisor.ResultDetail.getSIDFromSFID(x.objectId),violation,'UniformOutput',false);
            [~,sortedIndex]=sort(sids);
            violation=violation(sortedIndex);
        end

        function vObj=getResultDetailObject(~,violations)

            vObj=[];

            for iCount=1:numel(violations)
                vObj=[vObj;violations{iCount}.MAResultDetail];
            end

        end

        function issue=filterSFEViolationWithCheckID(this,issue)

            if 0==numel(issue)
                return;
            end

            flag=cellfun(@(x)any(strcmp(x.details.getString(),this.SFETmessageInfo)),issue);
            issue=issue(flag);

        end
    end

    methods(Static)

        function entities=getRelevantBlocks(system,FollowLinks,LookUnderMasks)

            [entities]=Advisor.Utils.Stateflow.sfFindSys(...
            system,...
            FollowLinks,...
            LookUnderMasks,...
            {'-isa','Stateflow.Chart',...
            '-or',...
            '-isa','Stateflow.TruthTable',...
            '-or',...
            '-isa','Stateflow.StateTransitionTableChart'},...
            true);

            if isempty(entities)
                return;
            end

        end

    end
end












function sysResult=getComponentResult(this,compId)

    if this.IsInitialized
        maObj=this.getMAObjs(compId);

        if~isempty(maObj)
            maObj=maObj{1};
            sysResult=ModelAdvisor.SystemResult;

            nodeIdx=this.getNodesUnderRoot();

            system=maObj.SystemName;

            sysResult.system=system;

            if~maObj.IsLibrary
                sysResult.Type='Model';
            end

            sysResult.uniqueCode=maObj.RunTime;
            sysResult.ComponentId=compId;

            numPass=0;
            numWarn=0;
            numFail=0;
            numNotRun=0;


            taca=maObj.TaskAdvisorCellArray;


            isTask=false(size(taca));

            for n=1:length(nodeIdx)
                if nodeIdx(n)~=0
                    node=taca{nodeIdx(n)};

                    if isa(node,'ModelAdvisor.Task')
                        isTask(nodeIdx(n))=true;
                    end
                end
            end

            tasks=taca(isTask);
            checkResults=ModelAdvisor.CheckResult.empty();

            for n=length(tasks):-1:1
                node=tasks{n};
                checkResults(n)=ModelAdvisor.CheckResult(system);



                check=node.Check;
                if~isa(check,'ModelAdvisor.Check')

                    check=ModelAdvisor.Check(node.MAC);
                    check.Success=false;
                    check.ErrorSeverity=1;
                end
                checkResults(n).checkID=check.ID;
                checkResults(n).index=check.Index;
                checkResults(n).taskID=node.ID;

                for ni=1:length(check.InputParameters)
                    ip=check.InputParameters{ni};

                    checkResults(n).paramName{ni}=ip.Name;
                    checkResults(n).paramValue{ni}=ip.Value;
                end

                checkResults(n).checkName=node.DisplayName;
                checkResults(n).html=check.ResultInHTML;



                if strcmp(check.CallbackStyle,'DetailStyle')
                    checkResults(n).resultDetails=check.ResultDetails;
                end
                checkResults(n).status=ModelAdvisor.CheckStatusUtil.getText(node.state);
            end



            count=ModelAdvisor.getTaskStateCount(tasks);
            sysResult.numPass=count.(char(ModelAdvisor.CheckStatus.Passed));
            sysResult.numWarn=count.(char(ModelAdvisor.CheckStatus.Warning));
            sysResult.numFail=count.(char(ModelAdvisor.CheckStatus.Failed));
            sysResult.numNotRun=count.(char(ModelAdvisor.CheckStatus.NotRun));
            sysResult.CheckResultObjs=checkResults;



        else
            DAStudio.error('Advisor:base:Components_UnknownIstanceID',compId);
        end
    else
        sysResult=ModelAdvisor.SystemResult.empty;
    end
end



function setCompileError(this,compileErrors,runTime,selectedComponentIDs)
    if this.IsInitialized

        maObjs=this.getMAObjs(selectedComponentIDs);


        tempMsg=ModelAdvisor.Element('span','style','color:#FF0000;');
        tempMsg.addContent(DAStudio.message('Simulink:tools:MAErrorOccurredCompile'));
        tempMsg.addContent(ModelAdvisor.LineBreak);
        tempMsg.addContent(ModelAdvisor.LineBreak);

        for n=1:length(compileErrors)
            tempMsg.addContent(Simulink.ModelAdvisor.getErrorMessage(compileErrors{n}.Error));
            tempMsg.addContent(ModelAdvisor.LineBreak);
        end

        msg=tempMsg.emitHTML;


        info=this.getTaskInfoForExecution();

        taskList=info.regularTaskCompileInfo.TaskIdxList;
        taskIdx=taskList(info.regularTaskCompileInfo.ModeList~=...
        Advisor.CompileModes.None);

        for n=1:length(maObjs)
            maObj=maObjs{n};



            numFailed=0;


            for ni=1:length(taskIdx)
                task=maObj.TaskAdvisorCellArray{taskIdx{ni}};


                task.Check.ResultInHTML=msg;
                task.Check.Success=false;
                task.Check.ErrorSeverity=100;
                task.Check.setStatus(ModelAdvisor.CheckStatus.Failed);



                task.RunTime=runTime;

                task.updateStates(ModelAdvisor.CheckStatus.Failed,'fastmode');

                numFailed=numFailed+1;

            end


            for ni=1:length(info.procedureTaskCompileInfo)

                taskIdx=info.procedureTaskCompileInfo{ni}.TaskIdxList;

                for nii=1:length(taskIdx)
                    task=maObj.TaskAdvisorCellArray{taskIdx{nii}};

                    stopTask=~task.Check.Success&&...
                    ((task.Check.ErrorSeverity>0)||strcmp(task.Severity,'Required'));

                    if stopTask
                        break;



                    elseif(task.RunTime~=runTime)||(task.RunTime==0)

                        task.Check.ResultInHTML=msg;
                        task.Check.Success=false;
                        task.Check.ErrorSeverity=100;



                        task.RunTime=runTime;

                        task.updateStates(ModelAdvisor.CheckStatus.Failed,'fastmode');

                        numFailed=numFailed+1;


                        break;
                    end
                end
            end


            if numFailed>0
                maObj.Database.saveMASessionData;

                genInfo=maObj.Database.loadData('geninfo',...
                maObj.TaskAdvisorRoot.DisplayName);



                if~isempty(genInfo)
                    genInfo.failCt=genInfo.failCt+numFailed;
                    genInfo.nrunCt=genInfo.nrunCt-numFailed;

                else
                    counterStructure=modeladvisorprivate(...
                    'modeladvisorutil2','getNodeSummaryInfo',maObj.TaskAdvisorRoot);

                    genInfo=struct('fromTaskAdvisorNode',[],...
                    'generateTime',runTime,...
                    'passCt',counterStructure.passCt,...
                    'failCt',counterStructure.failCt,...
                    'warnCt',counterStructure.warnCt,...
                    'nrunCt',counterStructure.nrunCt,...
                    'allCt',counterStructure.allCt,...
                    'reportName','report.html');
                end

                modeladvisorprivate('modeladvisorutil2',...
                'SaveGenerateInfo',maObj,...
                maObj.TaskAdvisorRoot.DisplayName,...
                maObj.RunTime,...
                genInfo.passCt,genInfo.failCt,genInfo.warnCt,...
                genInfo.nrunCt,genInfo.allCt);


                workDir=maObj.getWorkDir();
                reportName=...
                modeladvisorprivate('modeladvisorutil2',...
                'GetReportNameForTaskNode',...
                maObj.TaskAdvisorRoot,workDir);


                if exist(reportName,'file')
                    delete(reportName);
                end

            end
        end
    end
end
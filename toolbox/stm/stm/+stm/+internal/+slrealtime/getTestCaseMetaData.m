function out=getTestCaseMetaData(modelName,out,simWatcher,realtimeWorkflow)



    out.modelChecksum=[];
    tg=slrealtime;
    try

        if(realtimeWorkflow==0)



            out.modelVersion=get_param(modelName,'ModelVersion');
            out.modelFilePath=get_param(modelName,'FileName');
            out.modelAuthor=get_param(modelName,'LastModifiedBy');
            out.modelLastModifiedDate=get_param(simWatcher.mainModel,'LastModifiedDate');
            out.mainModelVersion='';
            out.mainModelAuthor='';
            if(strcmp(modelName,simWatcher.mainModel))
                field='modelVersion';
                if isfield(out,field)
                    out.mainModelVersion=out.(field);
                end
                out.mainModelAuthor=out.modelAuthor;
            end
            if(isempty(out.mainModelVersion))
                out.mainModelVersion=get_param(simWatcher.mainModel,'ModelVersion');
            end
            if(isempty(out.mainModelAuthor))
                out.mainModelAuthor=get_param(simWatcher.mainModel,'LastModifiedBy');
            end
        else
            out.modelVersion='N/A';
            out.modelFilePath=which([modelName,'.mldatx']);
            if(realtimeWorkflow==1)
                d=dir([modelName,'.mldatx']);
                out.modelLastModifiedDate=d.date;
            end
        end
        if ispc
            out.machineName=getenv('COMPUTERNAME');
            out.modelUserID=getenv('USERNAME');
        else
            out.machineName=getenv('HOSTNAME');
            out.modelUserID=getenv('USER');
        end

        appObj=slrealtime.Application(modelName);
        v=ver('Simulink');
        out.simulinkVersion=v.Version;
        out.simulinkRelease=v.Release;

        out.machineName=tg.TargetSettings.name;
        out.platform='Simulink Real-Time';
        out.SimulationModeUsed='Simulink Real-Time';
        out.startTime=0;
        out.stopTime=tg.get('ModelStatus').StopTime;
        out.solverName=appObj.getInformation.ModelSolverName;
        out.solverType='Fixed-Step';
        out.fixedStepSize=tg.get('ModelStatus').TETInfo(1).Rate;
        if(realtimeWorkflow==2)
            out.MLDATX=modelName;
        end
    catch

    end





end


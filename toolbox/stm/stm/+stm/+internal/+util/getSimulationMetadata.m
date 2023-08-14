function out=getSimulationMetadata(inStructure,mdata,modelToRun,mainModel)






    out=initializeMetadata(inStructure);
    try
        out.modelAuthor=get_param(modelToRun,'LastModifiedBy');
        out.modelLastModifiedDate=get_param(mainModel,'LastModifiedDate');

        out.mainModelVersion='';
        out.mainModelAuthor='';
        if(strcmp(modelToRun,mainModel))
            field='modelVersion';
            if isfield(out,field)
                out.mainModelVersion=out.(field);
            end
            out.mainModelAuthor=out.modelAuthor;
        end
        if(isempty(out.mainModelVersion))
            out.mainModelVersion=get_param(mainModel,'ModelVersion');
        end
        if(isempty(out.mainModelAuthor))
            out.mainModelAuthor=get_param(mainModel,'LastModifiedBy');
        end
        out.overridesilpilmode=inStructure.overridesilpilmode;

    catch
    end
    if(isa(mdata,'Simulink.SimulationMetadata'))
        try
            out.modelChecksum=mdata.ModelInfo.ModelStructuralChecksum;
            out.modelVersion=mdata.ModelInfo.ModelVersion;
            out.modelFilePath=mdata.ModelInfo.ModelFilePath;
            out.modelUserID=mdata.ModelInfo.UserID;

            out.machineName=mdata.ModelInfo.MachineName;
            out.platform=mdata.ModelInfo.Platform;

            slVersion=mdata.ModelInfo.SimulinkVersion;
            out.simulinkVersion=slVersion.Version;
            out.simulinkRelease=slVersion.Release;
            out.simulinkDate=slVersion.Date;

            out.simMode=mdata.ModelInfo.SimulationMode;
            out.startTime=mdata.ModelInfo.StartTime;
            out.stopTime=mdata.ModelInfo.StopTime;


            solverInfo=mdata.ModelInfo.SolverInfo;
            out.solverType=solverInfo.Type;
            out.solverName=solverInfo.Solver;

            out.solverMaxStepSize=0;
            out.fixedStepSize=0;
            if(strcmp(solverInfo.Type,'Variable-Step')&&isfield(solverInfo,'MaxStepSize'))
                out.solverMaxStepSize=solverInfo.MaxStepSize;
            end
            if(strcmp(solverInfo.Type,'Fixed-Step')&&isfield(solverInfo,'FixedStepSize'))
                out.fixedStepSize=solverInfo.FixedStepSize;
            end

            out.timeStampStart=mdata.TimingInfo.WallClockTimestampStart;
            out.timeStampStop=mdata.TimingInfo.WallClockTimestampStop;
            out.executionTime=mdata.TimingInfo.ExecutionElapsedWallTime;
        catch
        end
    else
        if(isempty(out.modelAuthor))
            out.modelAuthor=out.mainModelAuthor;
        end
        if(isempty(out.modelVersion))
            out.modelVersion=out.mainModelVersion;
        end
        if(isempty(out.modelFilePath))
            out.modelFilePath=which(mainModel);
        end

        v=ver('Simulink');
        out.simulinkVersion=v.Version;
        out.simulinkRelease=v.Release;
        out.simulinkDate=v.Date;
        out.platform=computer();
        if ispc
            out.machineName=getenv('COMPUTERNAME');
            out.modelUserID=getenv('USERNAME');
        else
            [unusedVar,out.machineName]=system('hostname');%#ok
            out.modelUserID=getenv('USER');
        end
        try
            out.solverType=get_param(modelToRun,'SolverType');
            out.solverName=get_param(modelToRun,'SolverName');
            out.solverMaxStepSize=get_param(modelToRun,'MaxStep');
        catch
        end

        if isempty(out.simMode)&&~isempty(inStructure.SimulationModeUsed)
            out.simMode=inStructure.SimulationModeUsed;
        end
    end
end

function out=initializeMetadata(inStruct)
    mdata=struct(...
    'modelAuthor','',...
    'modelLastModifiedDate','',...
    'mainModelVersion','',...
    'mainModelAuthor','',...
    'modelChecksum',[],...
    'modelVersion','',...
    'modelFilePath','',...
    'modelUserID','',...
    'machineName','',...
    'platform','',...
    'simulinkVersion','',...
    'simulinkRelease','',...
    'simulinkDate','',...
    'simMode','',...
    'overridesilpilmode','',...
    'startTime','',...
    'stopTime','',...
    'solverType','',...
    'solverName','',...
    'solverMaxStepSize','',...
    'fixedStepSize','',...
    'timeStampStart','',...
    'timeStampStop','',...
    'executionTime',''...
    );
    if(isempty(inStruct))
        out=mdata;
    else
        out=inStruct;
        fieldNames=fieldnames(mdata);
        for k=1:length(fieldNames)
            fieldName=fieldNames{k};
            out.(fieldName)=mdata.(fieldName);
        end
    end
end



















function[simout]=run(this,cgv,inputIndex)

    if cgv.Debug>0
        open_system(this.TestHarnessName);
    else
        load_system(this.TestHarnessName);
    end
    if cgv.NoInputData==false
        filename=cgv.InputData(inputIndex).pathAndName;






        cgvSimParams=configureParams(filename,cgv.SimParams);
        evalin('base',['load(''',filename,''');']);
    end

    if~isempty(cgv.CallbackFcn)
        cgv.CallbackFcn(inputIndex,cgv.ModelName,this.ComponentType,this.Connectivity);
    end
    if~isempty(cgv.PreExecFcn)
        cgv.PreExecFcn(cgv,inputIndex);
    end
    if~isempty(cgv.PreReportFcn)
        cgv.PreReportFcn(cgv,inputIndex);
    end

    if~isempty(cgv.SimParams)
        simcmd=['sim(''',this.TestHarnessName,''', cgvSimParams);'];
        assignin('base','cgvSimParams',cgvSimParams);
    else
        simcmd=['sim(''',this.TestHarnessName,''');'];
    end


    if cgv.ReturnWorkspaceOutputs||~isempty(cgv.SimParams)
        simout=evalin('base',simcmd);
    else
        evalin('base',simcmd);
        try
            simout=evalin('base',cgv.OutputDataName);
        catch ME
            if strcmp(ME.identifier,'MATLAB:UndefinedFunction')
                newExc=MException('RTW:cgv:NoOutputForConfig',...
                DAStudio.message('RTW:cgv:NoOutputForConfig',cgv.ModelName));
                throw(newExc);
            end
            rethrow(ME);
        end
    end
end

function cgvSimParams=configureParams(filename,cgvSimParams)


    if isempty(cgvSimParams)
        cgvSimParams=[];
        return;
    end
    workspace=load(filename);
    if length(fields(workspace))>1

        if isfield(cgvSimParams,'StartTime')

            startTime=cgvSimParams.StartTime;
            if isnan(str2double(startTime))&&isfield(workspace,startTime)
                cgvSimParams.StartTime=num2str(eval(['workspace','.',startTime]));
            end
        end
        if isfield(cgvSimParams,'StopTime')

            stopTime=cgvSimParams.StopTime;
            if isnan(str2double(stopTime))&&isfield(workspace,stopTime)
                cgvSimParams.StopTime=num2str(eval(['workspace','.',stopTime]));
            end
        end
        if isfield(cgvSimParams,'FixedStep')

            fixedStep=cgvSimParams.FixedStep;
            if isnan(str2double(fixedStep))&&isfield(workspace,fixedStep)
                cgvSimParams.StopTime=num2str(eval(['workspace','.',fixedStep]));
            end
        end
    end
end

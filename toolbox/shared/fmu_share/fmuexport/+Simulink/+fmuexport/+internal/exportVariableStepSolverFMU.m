function exportVariableStepSolverFMU(model,varargin)
    narginchk(2,18);


    if slfeature('FMUExportWithMCRDependency')==0
        return;
    end


    [m,errmsg]=builtin('license','checkout','Simulink_Compiler');
    if~m
        ex=MSLException([],message('Simulink:utility:invalidSimulinkCompilerLicenseForFMU'));
        ex=ex.addCause(MException('SimulinkCompiler:LicenseCheckoutError','%s',errmsg));
        throwAsCaller(ex);
    end



    mdl_handle=get_param(model,'Handle');
    hasUnsavedChange=bdIsDirty(mdl_handle);
    if hasUnsavedChange
        throwAsCaller(MSLException([],message('FMUShare:FMU:CannotExportVarStepFMUUnsavedModel',model)));
    end
    if strcmp(computer('arch'),'maca64')
        throwAsCaller(MSLException([],message('FMUShare:FMU:CannotExportMaca64VarStepFMU')));
    end


    [status,fileattri]=fileattrib(pwd);

    if~status||~fileattri.UserWrite
        throwAsCaller(MSLException([],message('FMUShare:FMU:CannotExportToDirectory',pwd)));
    end

    model_path=which(model);
    [status,fileattri]=fileattrib(model_path);

    if~status||~fileattri.UserWrite
        throwAsCaller(MSLException([],message('FMUShare:FMU:CannotOpenFileForWriting',model)));
    end



    modelData=struct('Model',model,'Description','','Author','','Copyright','','License','',...
    'fmu','','icon','','CreateModelAfterGeneratingFMU','off','target','raccel');
    [~,fmu,~]=fileparts(model);
    modelData.fmu=fullfile(pwd,[fmu,'.fmu']);
    modelData.ProjectName='';


    for i=1:2:length(varargin)
        if i+1>length(varargin)
            throwAsCaller(MSLException([],message('FMUShare:FMU:UnpairedArguments',varargin{i})));
        end

        switch varargin{i}
        case '-description'
            modelData.Description=varargin{i+1};
        case '-author'
            modelData.Author=varargin{i+1};
        case '-copyright'
            modelData.Copyright=varargin{i+1};
        case '-license'
            modelData.License=varargin{i+1};
        case '-fmuname'
            modelData.fmu=varargin{i+1};
        case '-fmuicon'
            modelData.icon=varargin{i+1};
        case 'CreateModelAfterGeneratingFMU'
            modelData.CreateModelAfterGeneratingFMU=varargin{i+1};
        otherwise
            throwAsCaller(MSLException([],message('FMUShare:FMU:UnrecognizedArguments',varargin{i})));
        end
    end

    set_param(model,'CompileForCoSimTarget','FMUVarStep');
    Simulink.fmuexport.internal.packToolCouplingFMU(modelData);
    set_param(model,'CompileForCoSimTarget','');


    if strcmp(modelData.CreateModelAfterGeneratingFMU,'on')
        tmpModelName=[char(randi([65,90],1,6)),'_fmu'];
        new_system(tmpModelName,'model');
        Cl1=onCleanup(@()bdclose(tmpModelName));
        newBlockName=[tmpModelName,'/Generated FMU Block'];
        add_block('built-in/FMU',newBlockName,'FMUName',[model,'.fmu'],'Position',[50,50,200,200]);
        harnessModelName=[model,'_harness'];
        postFix=1;
        while exist(fullfile(pwd,[harnessModelName,'.slx']),'file')==4
            harnessModelName=[model,'_harness',num2str(postFix)];
            postFix=postFix+1;
        end


        warningIdToSuppress={'Simulink:Harness:ExportDeleteHarnessFromSystemModel',...
        'Simulink:Engine:InputNotConnected',...
        'Simulink:Engine:OutputNotConnected',...
        'Simulink:SampleTime:SourceInheritedTS'};

        WarningId=cellfun(@(x)warning('off',x),warningIdToSuppress,'un',0);
        Cl2=onCleanup(@()cellfun(@(x)warning(x),WarningId,'un',0));
        harnessModelFile=fullfile(pwd,[harnessModelName,'.slx']);
        harnessInfo=Simulink.harness.internal.create(newBlockName,false,false,'Name',harnessModelName);

        Simulink.harness.internal.export(newBlockName,harnessInfo.name,false,'Name',harnessModelFile);
    end
end

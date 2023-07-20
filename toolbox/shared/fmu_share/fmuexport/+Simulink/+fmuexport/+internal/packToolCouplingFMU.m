function packToolCouplingFMU(modelData)







    if strcmp(modelData.target,'slproject')
        [~,projName,projExt]=fileparts(modelData.Project);

        if strcmp(projExt,'.zip')
            modelData.ProjectName=[projName,projExt];
        else
            assert(strcmp(projName,modelData.Project),'extract project name failed.');
            modelData.ProjectName=[modelData.Project,'.zip'];
        end
    end

    [modelPath,modelName,~]=fileparts(modelData.Model);
    assert(isempty(modelPath)||exist(modelPath,'dir')==7,'Model file must be on path');
    assert(exist(modelName,'file')==4,'Model file must exist on path');
    modelData.ModelName=modelData.Model;

    if~isempty(modelData.icon)
        [success,attrib]=fileattrib(modelData.icon);
        if~success
            throwAsCaller(MSLException([],message('FMUShare:FMU:IconFileDoesNotExist',modelData.icon)));
        end
        icon=attrib.Name;

        [~,~,iconExt]=fileparts(icon);
        if~strcmpi(iconExt,'.png')
            throwAsCaller(MSLException([],message('FMUShare:FMU:InvalidIconFileFormat',modelData.icon)));
        end
    end


    platformStr={'win64','darwin64','linux64'};
    archStr={'libwin64','libmaci64','libglnxa64'};
    if strcmp(modelData.target,'slproject')
        libStr={'fmuexportlib','libmwfmuexportlib','libmwfmuexportlib'};
    elseif strcmp(modelData.target,'raccel')
        libStr={'fmuraccellib','libmwfmuraccellib','libmwfmuraccellib'};
    end
    libExt={'.dll','.dylib','.so'};

    if slsvTestingHook('FMUExportSbruntestsMode')==1
        if ispc
            platformStr=platformStr(1);archStr=archStr(1);libStr=libStr(1);libExt=libExt(1);
        elseif ismac
            platformStr=platformStr(2);archStr=archStr(2);libStr=libStr(2);libExt=libExt(2);
        else
            platformStr=platformStr(3);archStr=archStr(3);libStr=libStr(3);libExt=libExt(3);
        end
    end



    cleanupTasks=cell(4,1);

    tempDirStr=fullfile(pwd,strrep(char(matlab.lang.internal.uuid),'-','_'));
    mkdir(tempDirStr);
    cleanupTasks{4}=onCleanup(@()rmdir(tempDirStr,'s'));










    if strcmp(modelData.target,'raccel')
        origSimMode=get_param(modelData.Model,'SimulationMode');
        set_param(modelData.Model,'SimulationMode','normal');

        inport_handle=add_block('built-in/Inport',[modelData.Model,'/ToolCouplingFMU_VariableStepSolver_Inport']);
        sfcn_handle=add_block('built-in/S-Function',[modelData.Model,'/ToolCouplingFMU_VariableStepSolver']);
        set_param(sfcn_handle,'FunctionName','fmuVarStepMex');
        set_param(sfcn_handle,"Priority","1");
        stopTime=str2double(get_param(modelData.Model,'StopTime'));

        set_param(modelData.Model,'StopTime',num2str(stopTime+1.0));
        line_hanlde=add_line(modelData.Model,'ToolCouplingFMU_VariableStepSolver_Inport/1','ToolCouplingFMU_VariableStepSolver/1');
        cleanupLine=onCleanup(@()delete_line(line_hanlde));
        cleanupInport=onCleanup(@()delete_block(inport_handle));
        cleanupSFcn=onCleanup(@()delete_block(sfcn_handle));
        cleanupStopTime=onCleanup(@()set_param(modelData.Model,'StopTime',num2str(stopTime)));


        saveModelObj=onCleanup(@()save_system(modelData.Model));


        copyfile(fullfile(matlabroot,'toolbox','shared','fmu_share','obj',['lib',computer('arch')],['fmuVarStepMex.',mexext]),tempDirStr);


        origEnvPath=addpath(pwd);
        cleanupTasks{1}=onCleanup(@()path(origEnvPath));


        cleanupTasks{2}=onCleanup(@()clear('fmuVarStepMex'));
        addpath(tempDirStr);
        save_system(modelData.Model);
    end
    if Simulink.fmuexport.internal.ModelInfoUtilsBase.UseRefactorCode()
        modelUtil=Simulink.fmuexport.internal.ModelCompileInfoUtils(modelName,modelData);
    else
        modelUtil=Simulink.fmuexport.internal.ModelInfoUtils(modelName,modelData);
    end

    origDirStr=cd(tempDirStr);
    cleanupTasks{3}=onCleanup(@()cd(origDirStr));

    if strcmp(modelData.target,'slproject')

        callStack=dbstack('-completenames');
        componentRoot=fileparts(fileparts(fileparts(fileparts(fileparts(callStack(1).file)))));

        mkdir('resources');cd('resources');mkdir('obj');cd('obj');




        if exist(modelData.Project,'file')==2


            movefile(modelData.Project,fullfile('.',modelData.ProjectName));
        else

            zipFileName=fullfile('.',modelData.ProjectName);
            slproject.getCurrentProject().export(zipFileName);
        end
        cd('..');cd('..');
    elseif strcmp(modelData.target,'raccel')

        try
            Simulink.fmuexport.internal.buildRapidAccelTarget(modelData.Model);
        catch exc
            rethrow(exc);
        end
        delete(fullfile(tempDirStr,['fmuVarStepMex.',mexext]));



        delete(fullfile(tempDirStr,'*.slxc'));
        delete(fullfile(tempDirStr,['*.',mexext]));

        set_param(modelData.Model,'SimulationMode',origSimMode);
        componentRoot=fullfile(matlabroot,'toolbox','shared','fmu_share');

        mkdir('resources');cd('resources');

        copyfile(fullfile(tempDirStr,'slprj','raccel_deploy',modelData.Model,'*.mat'),fullfile(tempDirStr,'resources'));
        copyfile(fullfile(tempDirStr,'slprj','raccel_deploy',modelData.Model,'*.dmr'),fullfile(tempDirStr,'resources'));
        copyfile(fullfile(tempDirStr,'slprj','raccel_deploy',modelData.Model,'*.mex*'),fullfile(tempDirStr,'resources'));

        copyfile(fullfile(tempDirStr,'slprj','raccel_deploy',modelData.Model,'*.txt*'),fullfile(tempDirStr,'resources'));

        if ispc
            copyfile(fullfile(tempDirStr,'slprj','raccel_deploy',modelData.Model,[modelData.Model,'.exe']),fullfile(tempDirStr,'resources'));
        else
            copyfile(fullfile(tempDirStr,'slprj','raccel_deploy',modelData.Model,modelData.Model),fullfile(tempDirStr,'resources'));
        end
        copyfile(fullfile(tempDirStr,'slprj','raccel_deploy',modelData.Model,'tmwinternal'),fullfile(tempDirStr,'resources','tmwinternal'));
        if exist(fullfile(tempDirStr,'slprj','raccel_deploy',modelData.Model,'_fmu'),'dir')
            copyfile(fullfile(tempDirStr,'slprj','raccel_deploy',modelData.Model,'_fmu'),fullfile(tempDirStr,'resources','_fmu'));
        end
        rmdir(fullfile(tempDirStr,'slprj'),'s');
        fid=fopen('modelInfo.txt','wt');
        fprintf(fid,'%s\n',modelData.Model);

        fmuVarStepPortId=find(contains({modelUtil.ModelVariableList.xml_name},'ToolCouplingFMU_VariableStepSolver_Inport'));
        fprintf(fid,'%d\n',modelUtil.ModelVariableList(fmuVarStepPortId).vr);
        prMatFile=dir("pr*.mat");
        fprintf(fid,'%s\n',prMatFile.name);

        slMatFile=dir("sl*.mat");
        fprintf(fid,'%s\n',slMatFile.name);
        fclose(fid);

        prMat=load(fullfile(prMatFile.folder,prMatFile.name),'parameters');
        modelUtil.addRuntTimeParameterFromRapid(prMat.parameters);
        cd('..');
    end

    mkdir('binaries');cd('binaries');
    for i=1:length(platformStr)
        mkdir(platformStr{i});cd(platformStr{i});

        copyfile(fullfile(componentRoot,'obj',archStr{i},...
        [libStr{i},libExt{i}]),[modelUtil.ModelIdentifier,libExt{i}]);
        fileattrib([modelUtil.ModelIdentifier,libExt{i}],'+w');

        cd('..');
    end
    cd('..');

    mkdir('documentation');cd('documentation');
    docWriter=Simulink.fmuexport.internal.CoSimToolCouplingFMU2HTMLWriter(modelUtil,'index.html');
    docWriter.write;
    docWriter.delete;
    cd('..');



    xmlWriter=Simulink.fmuexport.internal.fmi2ModelDescriptionWriter(modelUtil,'modelDescription.xml');
    xmlWriter.write;
    if strcmp(modelData.target,'slproject')

        copyfile(fullfile('.','modelDescription.xml'),fullfile('resources','obj'));
    end


    if~isempty(modelData.icon)
        copyfile(modelData.icon,'model.png');
        fileattrib('model.png','+w');
    end

    [success,attrib]=fileattrib(modelData.fmu);
    if success
        fmu=attrib.Name;
    end
    [fmuPath,fmuName,~]=fileparts(modelData.fmu);

    zip(fullfile(fmuPath,[fmuName,'.zip']),'*');
    movefile(fullfile(fmuPath,[fmuName,'.zip']),fullfile(fmuPath,[fmuName,'.fmu']));

end
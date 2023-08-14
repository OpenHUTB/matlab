function importFromScript



    MAObj=Simulink.ModelAdvisor.getActiveModelAdvisorObj;
    modelName=MAObj.modelName;
    hdriver=hdlmodeldriver(modelName);
    hDI=hdriver.DownstreamIntegrationDriver;
    hdlwaDriver=hdriver.getWorkflowAdvisorDriver;

    dutName=hdlget_param(modelName,'HDLSubsystem');


    [FileName,PathName]=uigetfile('*.m',DAStudio.message('HDLShared:hdldialog:HDLWAImportWorkflow'),'hdlworkflow.m');
    if isequal(FileName,0)
        return;
    end
    file=fullfile(PathName,FileName);









    [loadCmds,hdlrestoreCmds,hdlsetCmds,configCmds]=parseImportFile(file);


    h=waitbar(0,DAStudio.message('HDLShared:hdldialog:HDLWAWaitBarLoading'));




    loadModel='';
    if(~isempty(loadCmds))
        tokens=regexp(loadCmds{1},'load_system\(''(.*)''\)','tokens');
        if(~isempty(tokens))
            loadModel=tokens{1}{1};
        else

            loadModel=loadCmds{1};
        end
    end


    msg={};
    if(~strcmp(modelName,loadModel))
        msg1=MException(message('hdlcoder:workflow:WorkflowImportModelNameError',loadModel,modelName));
        msg{end+1}=msg1;
    else
        for i=1:length(loadCmds)
            try
                cmdStr=loadCmds{i};
                evalc(cmdStr);
            catch me
                msg1=MException(message('hdlcoder:workflow:WorkflowImportCommandError',cmdStr,me.message));
                msg{end+1}=msg1;
            end
        end
        for i=1:length(hdlrestoreCmds)
            try
                cmdStr=hdlrestoreCmds{i};
                evalc(cmdStr);
            catch me
                msg1=MException(message('hdlcoder:workflow:WorkflowImportCommandError',cmdStr,me.message));
                msg{end+1}=msg1;
            end
        end
        for i=1:length(hdlsetCmds)
            try
                cmdStr=hdlsetCmds{i};
                evalc(cmdStr);
            catch me
                msg1=MException(message('hdlcoder:workflow:WorkflowImportCommandError',cmdStr,me.message));
                msg{end+1}=msg1;
            end
        end
    end


    waitbar(0.2,h,DAStudio.message('HDLShared:hdldialog:HDLWAWaitBarPullModel'));
    downstream.integration('Model',dutName);





    waitbar(0.8,h,DAStudio.message('HDLShared:hdldialog:HDLWAWaitBarPullConfig'));

    for i=1:length(configCmds)
        try
            cmdStr=configCmds{i};
            evalc(cmdStr);
        catch me
            msg1=MException(message('hdlcoder:workflow:WorkflowImportCommandError',cmdStr,me.message));
            msg{end+1}=msg1;
        end
    end



    try
        if(~isempty(hWC))
            hWC.configure(hDI);
        end
    catch me
        msg{end+1}=me;
    end



    waitbar(0.9,h,DAStudio.message('HDLShared:hdldialog:HDLWAWaitBarUpdateInterface'));
    delete(h);
    utilHandle_HDLAdvisorModelParamLoad(dutName);




    if isa(MAObj,'Simulink.ModelAdvisor')&&isa(MAObj.MAExplorer,'DAStudio.Explorer')
        imme=DAStudio.imExplorer(MAObj.MAExplorer);
        MAObj.displayExplorer
        p=hdlwaDriver.getTaskObj('com.mathworks.HDL.WorkflowAdvisor');
        imme.selectTreeViewNode(p);
        dlgs=DAStudio.ToolRoot.getOpenDialogs(imme.getCurrentTreeNode);
        if isa(dlgs,'DAStudio.Dialog')
            dlgs.restoreFromSchema;
        end
    end


    emitImportErrorMsg(modelName,msg)


end





function[loadCmds,hdlrestoreCmds,hdlsetCmds,configCmds]=parseImportFile(file)

    fid=fopen(file,'r');

    if(fid<1)
        hf=errordlg(message('hdlcoder:engine:CouldNotOpenFile',file),'Error','modal');
        set(hf,'tag','HDL Workflow Advisor error dialog');
    end





    loadCmds={};
    hdlrestoreCmds={};
    hdlsetCmds={};
    configCmds={};
    tline='';

    while ischar(tline)


        tline=fgetl(fid);


        if isempty(tline)||~ischar(tline)||strncmp(tline,'%',1)
            continue
        end


        value=regexp(tline,'(?<cmd>load_system\(.*\))','names');
        if(~isempty(value))
            loadCmds{end+1}=value.cmd;
            continue;
        end


        value=regexp(tline,'(?<cmd>hdlrestoreparams\(.*\))','names');
        if(~isempty(value))
            hdlrestoreCmds{end+1}=value.cmd;
            continue;
        end


        value=regexp(tline,'(?<cmd>hdlset_param\(.*\))','names');
        if(~isempty(value))
            hdlsetCmds{end+1}=value.cmd;
            continue;
        end


        value=regexp(tline,'(?<cmd>hWC = hdlcoder\.WorkflowConfig\(.*\))','names');
        if(~isempty(value))
            configCmds{end+1}=value.cmd;
            continue;
        end


        value=regexp(tline,'(?<cmd>hWC\..*)','names');
        if(~isempty(value))
            configCmds{end+1}=value.cmd;
            continue;
        end

    end

    fclose(fid);

end

function emitImportErrorMsg(modelName,msg)

    if~isempty(msg)
        stageObj=Simulink.output.Stage(DAStudio.message('hdlcoder:workflow:WorkflowImportStageTitle'),'ModelName',modelName,'UIMode',true);%#ok<NASGU>
        for i=1:length(msg)
            Simulink.output.error(msg{i},'Component','HDLCoder','Category','HDL');
        end
    end
end



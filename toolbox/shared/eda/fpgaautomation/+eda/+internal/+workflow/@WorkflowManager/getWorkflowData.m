function getWorkflowData(h,varargin)




    if nargin==2
        model=varargin{1};
    else
        error(message('EDALink:WorkflowManager:getWorkflowData:modelnotfound'));
    end


    addtdkfpgaconfig(model);

    cs=getActiveConfigSet(model);


    h.getWorkflowCommonData(model);


    h.mWorkflowInfo.control.CheckProjDuringRun=false;
    h.mWorkflowInfo.control.AssociateProject=true;




    genHDL=get_param(cs,'AlwaysGenHDL');
    h.mWorkflowInfo.userParam.alwaysGenHDL=strcmpi(genHDL,'on');

    getSettings=get_param(cs,'GetFPGAProjectSettings');
    h.mWorkflowInfo.userParam.importSettings=strcmpi(getSettings,'on');




    h.mWorkflowInfo.userParam.assocExist=get_param(cs,'HasAssociatedFPGAProject');
    h.mWorkflowInfo.userParam.assocProjPath=get_param(cs,'AssociatedFPGAProjectPath');
    h.mWorkflowInfo.userParam.associate=get_param(cs,'AssociateFPGAProject');




    h.mWorkflowInfo.userParam.hilOutput=get_param(cs,'FPGAHilOutput');
    h.mWorkflowInfo.userParam.hilBoard=get_param(cs,'FPGAHardwareBoard');




    h.mWorkflowInfo.tdkParam.model=model;

    h.mWorkflowInfo.tdkParam.assocInfoName='_workflowInfo.mat';
    h.mWorkflowInfo.tdkParam.assocModelVar='assocMdlPath';
    h.mWorkflowInfo.tdkParam.assocFileListVar='addedFileList';


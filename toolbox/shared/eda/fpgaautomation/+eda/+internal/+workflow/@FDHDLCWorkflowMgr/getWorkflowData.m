function getWorkflowData(h,varargin)




    if nargin==2
        fpgaobj=varargin{1};
    else

        error(message('EDALink:FDHDLCWorkflowMgr:getWorkflowData:fpgaobjectnotfound'));
    end


    h.getWorkflowCommonData(fpgaobj);


    h.mWorkflowInfo.control.CheckProjDuringRun=true;
    h.mWorkflowInfo.control.AssociateProject=false;





    h.mWorkflowInfo.userParam.projectType=get(fpgaobj,'FPGAProjectType');





    h.mWorkflowInfo.userParam.usrpOutput=get(fpgaobj,'CustomFilterOutput');
    h.mWorkflowInfo.userParam.usrpLoc=get(fpgaobj,'USRPFPGASourceFolder');





function validateUSRP(h)




    hdlcData=h.mWorkflowInfo.hdlcData;


    if any(strcmp(computer,{'PCWIN','PCWIN64'}))
        error(message('EDALink:FDHDLCWorkflowMgr:validateUSRP:unsupportedOS'));
    end


    if strcmpi(hdlcData.target_language,'vhdl')
        error(message('EDALink:FDHDLCWorkflowMgr:validateUSRP:vhdl'));
    end


    if~hdlcData.filter_complex_inputs
        error(message('EDALink:FDHDLCWorkflowMgr:validateUSRP:complex'));
    end


    vstruct.name=true;
    vstruct.folder=true;
    vstruct.userfiles=false;
    vstruct.processprop=false;

    h.validateNewProjectParam(vstruct);

    userParam=h.mWorkflowInfo.userParam;


    if isempty(userParam.usrpLoc)||~ischar(userParam.usrpLoc)

        error(message('EDALink:FDHDLCWorkflowMgr:validateUSRP:emptyfolder'));
    end

    if~exist(userParam.usrpLoc,'dir')

        error(message('EDALink:FDHDLCWorkflowMgr:validateUSRP:foldernotfound'));
    end









    makeLoc1=fullfile(userParam.usrpLoc,'top','u2_rev3','Makefile');
    makeLoc2=fullfile(userParam.usrpLoc,'Makefile');

    if~exist(makeLoc1,'file')&&~exist(makeLoc2,'file')
        error(message('EDALink:FDHDLCWorkflowMgr:validateUSRP:invalidfolder',userParam.usrpLoc));
    end



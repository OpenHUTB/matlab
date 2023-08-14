function generateMATFile(h)




    matName=[h.mBuildInfo.FPGAProjectName,'.mat'];
    matFile=fullfile(h.mBuildInfo.OutputFolder,matName);
    msg=['Saving the current state of filWizard in ',matFile,' ...'];
    h.displayStatus(msg);
    h.LogMsg=sprintf('%s\n%s',h.LogMsg,dispFpgaMsg(msg));






    saveBuildInfo(h.mBuildInfo,matFile);



    fullDir=h.getFullDir(h.mBuildInfo.OutputFolder);
    matPath=fullfile(fullDir,matName);
    l_dispAndLog(h,matPath,2);
    l_dispAndLog(h,'',1);
    l_dispAndLog(h,'To restore filWizard: Use the MAT-file to launch FPGA-in-the-Loop wizard with data ',1);

    l_dispAndLog(h,'from current session: ',1);
    l_dispAndLog(h,sprintf('filWizard(''%s'')',matFile),2);

    function l_dispAndLog(h,str,indent)
        dispFpgaMsg(str,indent);
        h.LogMsg=[h.LogMsg,dispFpgaMsg(str,indent)];

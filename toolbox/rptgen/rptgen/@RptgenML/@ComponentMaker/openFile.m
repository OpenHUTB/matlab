function fid=openFile(h,fileName)






    fName=fullfile(h.ClassDir,fileName);

    rptgen.displayMessage(sprintf(getString(message('rptgen:RptgenML_ComponentMaker:writingFileMsg')),...
    fileName,h.ClassDir),4);

    if h.Safe&&...
        (exist(fName,'file')||...
        (strcmp(fName(end-1:end),'.m')&&exist([fName(1:end-2),'.p'],'file')))
        opt1=getString(message('rptgen:RptgenML_ComponentMaker:yesLabel'));
        opt3=getString(message('rptgen:RptgenML_ComponentMaker:yesToAllLabel'));
        opt2=getString(message('rptgen:RptgenML_ComponentMaker:cancelBuildLabel'));
        qResult=questdlg(getString(message('rptgen:RptgenML_ComponentMaker:overwriteFileMsg',fileName)),...
        getString(message('rptgen:RptgenML_ComponentMaker:overwriteComponentPrompt')),...
        opt1,opt3,opt2,opt2);
        if strcmp(qResult,opt2)
            error(message('rptgen:RptgenML_ComponentMaker:componentBuildCancelled'));
        elseif strcmp(qResult,opt3)
            h.Safe=false;
        end
    end

    [fid,errMsg]=fopen(fName,'w');

    if fid==0
        error(message('rptgen:RptgenML_ComponentMaker:fileOpenError',errMsg));
    end

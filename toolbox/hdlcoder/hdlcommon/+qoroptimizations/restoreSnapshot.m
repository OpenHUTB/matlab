function[iterCtrl,log,optimConfig]=restoreSnapshot(resumptionPoint,archDirParent,logFile,topModelName,dut)



    srcDir=fullfile(archDirParent,resumptionPoint);
    if(exist(srcDir,'dir')~=7)
        error(message('hdlcoder:optimization:CannotRestoreWorkingDir',resumptionPoint));
    end
    dstDir=pwd;
    s=copyfile(fullfile(srcDir,'*'),dstDir);
    if(~s)
        error(message('hdlcoder:optimization:CannotRestoreWorkingDir1',dstDir,resumptionPoint));
    end

    logFilePath=fullfile(dstDir,logFile);
    if(exist(logFilePath,'file')~=2)
        error(message('hdlcoder:optimization:CannotRestoreWorkingDir2',resumptionPoint,logFile));
    end

    cmd=qoroptimizations.checkhdlcmd(topModelName,dut);
    [~,~]=evalc(cmd);
    temp=qoroptimizations.loadFile(logFilePath,topModelName);
    lastToolVersion=temp.toolVersion;
    currentToolVersion=ver('HDLCoder');
    if(~isequal(currentToolVersion,lastToolVersion))
        error(message('hdlcoder:optimization:CannotRestoreForVersionChange',...
        resumptionPoint,evalc('disp(currentToolVersion)'),evalc('disp(lastToolVersion)')));
    end
    log=temp.log;
    iterCtrl=log(end).iterCtrl;
    optimConfig=temp.optimConfig;
end


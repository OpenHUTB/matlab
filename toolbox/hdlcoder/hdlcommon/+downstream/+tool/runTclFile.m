function[status,result]=runTclFile(tclFilePath,toolCmdStr,runExtShell,verboseMode)




    if nargin<4
        verboseMode=false;
    end

    if nargin<3
        runExtShell=false;
    end

    currentDir=pwd;
    [tclFileFolder,tname,text]=fileparts(tclFilePath);
    tclFileName=sprintf('%s%s',tname,text);
    cd(tclFileFolder);
    if~exist(tclFileName,'file')
        error(message('hdlcommon:workflow:NoTclFileWithName',tclFileName));
    end

    if runExtShell

        if ispc
            cmdStr=sprintf('%s %s &',toolCmdStr,tclFileName);
        else
            cmdStr=sprintf('xterm -hold -sb -sl 256 -e bash -e -c ''%s %s'' &',...
            toolCmdStr,tclFileName);
        end
        [statusSys,resultSys]=system(cmdStr);
        result=sprintf('%s\nRunning embedded system build outside MATLAB.\nPlease check external shell for system build progress.\n',...
        resultSys);
    else
        cmdStr=sprintf('%s %s',toolCmdStr,tclFileName);


        if verboseMode
            tic;
            [statusSys,resultSys]=system(cmdStr,'-echo');
            time=toc;
        else
            tic;
            [statusSys,resultSys]=system(cmdStr);
            time=toc;
        end

        result=sprintf('%s\nElapsed time is %s seconds.\n',resultSys,num2str(time));
    end

    status=~statusSys;
    if status

        search_result=regexp(resultSys,'ERROR:','once');
        if~isempty(search_result)
            status=false;
        end
    end

    cd(currentDir);
end


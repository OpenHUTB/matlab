function runSimulationEngine(simulationFilePaths,putInBackground,simulatorPath)

    oldDir=pwd;
    cleanupObj=onCleanup(@()cleanupFunc(oldDir));
    for idx=1:numel(simulationFilePaths)
        simulationFilePath=simulationFilePath{1};
        [projectDir,stateDir,simulationDir,qciBaseName,ext]=si.interface.simulationParts(simulationFilePath);
        fileName=string(qciBaseName)+ext;
        setenv("META_QUEUE","1")
        setenv("HSPWIN_GUI","0")
        setenv("PROJECT_SI_LIB",fullfile(projectDir,"si_lib"));
        toolboxRoot=fullfile(matlabroot,"toolbox","si");
        installDir=fullfile(toolboxRoot,"apps");
        setenv("SIA_INSTALL_DIR",installDir);
        setenv("SISOFT_SI_LIB",fullfile(installDir,"share","si_lib"));
        cd(simulationDir)
        setenv("SIA_PROCESS_ID_FILE",fullfile(stateDir,"run_status",qciBaseName+".running"));
        disp("running "+fileName)
        infoFile=qciBaseName+".info";
        fullInfoFile=fullfile(pwd,infoFile);
        fid=fopen(fullInfoFile,'w');
        fprintf(fid,'%s',infoFile+newline);
        arch=computer('arch');
        if nargin>2
            symCommand=simulatorPath;
        else
            switch ext
            case ".qci"
                if ispc
                    execName="sia_qcdengine";
                else
                    execName="qcdengine";
                end
            case ".ckt"
                execName="sia_isspice4";
            otherwise
                error(message('si:apps:fullPathRequired'))
            end
            if ispc
                computerName=getenv("computername");
            else
                [~,computerName]=system('hostname');
            end
            symCommand=fullfile(installDir,"libexec",arch,execName);
        end
        fprintf(fid,'%s',"HOSTNAME="+computerName+newline);
        fprintf(fid,'%s',"PLATFORM="+arch+newline);
        fprintf(fid,'%s',"SIMCMD="+symCommand+newline);
        fprintf(fid,"SYMTYPE=PCT"+newline);
        fprintf(fid,'%s',"SIMCMD="+symCommand+newline);
        fprintf(fid,"-----------------------------------------------"+newline);
        fprintf(fid,"Standard Output and Errors From Simulation job:"+newline);
        fprintf(fid,"-----------------------------------------------"+newline);
        fclose(fid);
        cmd=symCommand+" -f "+fileName+" >> "+infoFile+" 2>>&1";
        if putInBackground
            cmd=cmd+" &";
        end
        [status,cmdout]=system(cmd);
        if status~=0
            fid=fopen(fullInfoFile,'a');
            fprintf(fid,'%s',"Simulation return status = "+status+newline);
            if~isempty(cmdout)
                fprintf(fid,cmdout+newline);
            end
            fclose(fid);
        end
        doneFile=qciBaseName+".done";
        fullDoneFile=fullfile(pwd,doneFile);
        fid=fopen(fullDoneFile,'w');
        fprintf(fid,"");
        fclose(fid);
    end


    function cleanupFunc(oldDir)
        cd(oldDir)
    end
end


classdef gdb








    methods(Access=public,Static=true)

        function[qnxBase,gdbPath,gdbExe]=details()




            slrealtime.qnxSetupFcn();
            qnxBase=fullfile(getenv('SLREALTIME_QNX_SP_ROOT'),getenv('SLREALTIME_QNX_VERSION'));
            if strcmpi(computer('arch'),'win64')
                gdbPath=fullfile(qnxBase,'host','win64','x86_64','usr','bin');
                gdbExe=fullfile(gdbPath,'ntox86_64-gdb.exe');
            elseif strcmpi(computer('arch'),'glnxa64')
                gdbPath=fullfile(qnxBase,'host','linux','x86_64','usr','bin');
                gdbExe=fullfile(gdbPath,'ntox86_64-gdb');
            end
        end

        function results=stackTrace(tg)


            results=[];
            corefiles=tg.getCoreFiles();
            for ii=length(corefiles):-1:1
                corefile=corefiles{ii};
                [~,executable,~]=fileparts(corefile);
                rc=loc_receiveExecutable(tg,executable);
                if~rc
                    warning(message("slrealtime:target:couldNotGetExecutable",executable));
                end
                results(ii).name=executable;
                results(ii).stack=convertCharsToStrings(loc_stacktraceAndLog(corefile,executable));
            end
        end

        function attach(tg,executable)

























            rootssh=loc_getRootSSH(tg);

            pids=loc_getPID(tg,rootssh,executable);

            if(length(pids)>1)
                error("More than one process with name: '"+string(executable)+"'");
            end
            pid=pids{1};

            rc=loc_receiveExecutable(tg,executable);
            if~rc
                warning(['Failed to get executable: ',executable]);
            end


            gdbScript=loc_gdbAttachCommands(pid,tg,executable);
            srcPaths=loc_getTargetSrcPaths();
            for i=1:length(srcPaths)
                gdbScript=gdbScript+newline+"dir "+srcPaths(i);
            end


            loc_writeFile("commands.gdb",gdbScript);


            gdbCmd=loc_gdbCommand()+" -x commands.gdb";

            if strcmpi(computer('arch'),'win64')
                loc_writeFile("callGDB.bat",gdbCmd);

                winopen("callGDB.bat");
            elseif strcmpi(computer('arch'),'glnxa64')
                system(gdbCmd+" &");
            end

        end

        function debug(tg,executable)
















            rootssh=loc_getRootSSH(tg);

            pids=loc_getPID(tg,rootssh,executable);

            if(length(pids)>1)
                error("More than one process with name: '"+string(executable)+"'");
            end

            rc=loc_receiveExecutable(tg,executable);
            if~rc
                warning(['Failed to get executable: ',executable]);
            end


            gdbScript=loc_gdbDebugCommands(tg,executable);
            srcPaths=loc_getTargetSrcPaths();
            for i=1:length(srcPaths)
                gdbScript=gdbScript+newline+"dir "+srcPaths(i);
            end


            loc_writeFile("commands.gdb",gdbScript);


            gdbCmd=loc_gdbCommand()+" -x commands.gdb";

            if strcmpi(computer('arch'),'win64')
                loc_writeFile("callGDB.bat",gdbCmd);

                winopen("callGDB.bat");
            elseif strcmpi(computer('arch'),'glnxa64')

                system(gdbCmd);
            end

        end

        function[output]=getBackTrace(tg,executable)

            rootssh=loc_getRootSSH(tg);
            pids=loc_getPID(tg,rootssh,executable);

            rc=loc_receiveExecutable(tg,executable);
            if~rc
                warning(['Failed to get executable: ',executable]);
            end

            output=sprintf('Host system socket status: \n');
            output=[output,system('netstat -an')];

            output=[output,sprintf('Socket status: \n')];
            output=[output,tg.executeCommand('sockstat',rootssh).Output];
            output=[output,sprintf(['\nNumber of processes: ',num2str(length(pids)),'\n'])];
            output=[output,tg.executeCommand('pidin -p slrtd ',rootssh).Output];

            gdbCmd=loc_gdbCommand()+" --batch "+"-x commands.gdb";

            for i=1:length(pids)

                gdbScript=loc_gdbTraceCommands();


                loc_writeFile("commands.gdb",gdbScript);


                [rc,out]=system(gdbCmd);

                if rc~=0
                    warning(['Failed to get backtrace for ',executable,' error: ',out]);
                end
                output=[output,out];%#ok<AGROW>
            end
        end

    end

end




function result=loc_receiveExecutable(tg,executable)
    apps=tg.getInstalledApplications();
    for ii=1:length(apps)
        candidate=sprintf("%s/%s/bin/%s",tg.appsDirOnTarget,apps{ii},executable);
        if tg.isfile(candidate)
            tg.receiveFile(candidate);
            result=true;
            return;
        end
    end

    candidate=sprintf("/usr/target/bin/%s",executable);
    if tg.isfile(candidate)
        tg.receiveFile(candidate);
        result=true;
        return;
    end

    result=false;
end



function[output]=loc_stacktraceAndLog(corefile,executable)

    gdbScript=loc_gdbTraceCommands();

    loc_writeFile("commands.gdb",gdbScript);

    gdbCmd=loc_gdbCommand()+executable+" "+corefile+" --batch "+"-x commands.gdb";

    [rc,output]=system(gdbCmd);
    if rc~=0
        warning(message('slrealtime:target:failedToDecodeCallstack',rc));
    end
end


function gdbScript=loc_gdbAttachCommands(pid,tg,executable)
    gdbScript=loc_gdbEnvCommands+...
    sprintf("target qnx %s:8000\n",tg.TargetSettings.address)+...
    sprintf("file %s\n",executable)+...
    sprintf("attach %s\n",pid);
end


function gdbScript=loc_gdbDebugCommands(tg,executable)
    gdbScript=loc_gdbEnvCommands+...
    sprintf("target qnx %s:8000\n",tg.TargetSettings.address)+...
    sprintf("file %s\n",executable)+...
    sprintf("upload %s /home/slrt/applications/%s/bin/%s\n",executable,executable,executable)+...
    sprintf("b main\n");
end


function gdbScript=loc_gdbTraceCommands()
    gdbScript=loc_gdbEnvCommands+...
    sprintf("info sharedlibrary\n"+...
    "info threads\n"+...
    "thread apply all backtrace\n");
end


function gdbScript=loc_gdbEnvCommands()
    import slrealtime.internal.gdb

    qnx_base=gdb.details();

    if strcmpi(computer('arch'),'win64')
        pathSep=";";
    elseif strcmpi(computer('arch'),'glnxa64')
        pathSep=":";
    end

    libSearchPath=[
    fullfile(qnx_base,"target","qnx7","x86_64","lib");
    fullfile(qnx_base,"target","qnx7","x86_64","usr","lib");
    fullfile(qnx_base,"target","qnx7","x86_64","usr","local","lib");
    fullfile(matlabroot,"toolbox","slrealtime","target","lib");
    fullfile(matlabroot,"derived","win64","toolbox","slrealtime","target","rtps","CMakeFiles","CMakeRelink.dir");
    fullfile(matlabroot,"derived","win64","toolbox","slrealtime","target","kernel","CMakeFiles","CMakeRelink.dir");
    ];

    if~isempty(which('sg.mw.getGdbResources'))
        libSearchPath=[libSearchPath;sg.mw.getGdbResources];
    end

    gdbScript="set solib-search-path ";
    for i=1:numel(libSearchPath)
        gdbScript=sprintf('%s%s%s',gdbScript,libSearchPath{i},pathSep);
    end
    gdbScript=sprintf('%s\n',gdbScript);
end


function gdbCmd=loc_gdbCommand()
    import slrealtime.internal.gdb

    [qnxbase,gdbPath,gdbExe]=gdb.details();

    if strcmpi(computer('arch'),'win64')
        gdbCmd="call "+qnxbase+"\qnxsdp-env.bat && "+"set PATH=%PATH%;"+gdbPath+" && call "+gdbExe+" ";
    elseif strcmpi(computer('arch'),'glnxa64')
        gdbCmd="source "+qnxbase+"/qnxsdp-env.sh ; "+"export PATH=$PATH:"+gdbPath+" ; "+gdbExe+" ";
    end
end



function paths=loc_getTargetSrcPaths()
    targetbins={dir(fullfile(toolboxdir('slrealtime'),'target','*/CMakeLists.txt')).folder}';

    paths={};
    if strcmpi(computer('arch'),'win64')
        wildcard='**\*.*';
    elseif strcmpi(computer('arch'),'glnxa64')
        wildcard='**/*.*';
    end
    for i=1:length(targetbins)
        paths=[paths;unique({dir(fullfile(targetbins{i},wildcard)).folder}')];%#ok<AGROW>
    end

    paths=cellfun(@(p)strrep(p,'\','/'),paths,'UniformOutput',false);
end


function loc_writeFile(filename,contents)
    fid=fopen(filename,"w");
    fprintf(fid,"%s",contents);
    fclose(fid);
end


function rootssh=loc_getRootSSH(tg)
    rootssh=matlabshared.network.internal.SSH(...
    tg.TargetSettings.address,...
    tg.TargetSettings.sshPort,...
    'root',tg.TargetSettings.rootPassword);
end


function pids=loc_getPID(tg,rootssh,executable)
    pids=tg.executeCommand(['pidin -p ',executable,' -f a'],rootssh);
    pids=pids.Output;
    pids=regexp(pids,'\d*','Match');
end


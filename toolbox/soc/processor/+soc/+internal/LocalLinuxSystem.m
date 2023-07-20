


classdef LocalLinuxSystem<matlabshared.internal.SystemInterface

    properties(Constant,Access=protected)
        COMMANDPREFIX='/bin/bash -c '''
        COMMANDSUFFIX='''';
    end


    methods(Access={?soc.internal.SystemInterfaceFactory})
        function obj=LocalLinuxSystem()
        end
    end

    methods
        function output=system(obj,command,sudo)
            if nargin==3
                sudo=validatestring(sudo,{'sudo'},'','sudo');
            else
                sudo='';
            end
            sudo=[sudo,' '];
            fullCommand=[sudo,obj.COMMANDPREFIX,strtrim(command),obj.COMMANDSUFFIX];
            [status,output]=system(fullCommand);
            if status
                error(message('soc:os:SystemError',fullCommand,output));
            end
        end

        function putFile(obj,localFile,remoteFile)%#ok<INUSL>
            if~exist(localFile,'file')
                error(message('soc:os:FileNotFound',localFile));
            end
            copyfile(localFile,remoteFile,'f');
        end

        function getFile(obj,remoteFile,localFile)
            putFile(obj,remoteFile,localFile);
        end

        function deleteFile(obj,fileName)%#ok<INUSL>
            delete(fileName);
        end

        function d=dir(obj,fileSpec)%#ok<INUSL>
            d=dir(fileSpec);
        end

        function ret=isrunning(obj,pid)
            validateattributes(str2double(pid),{'scalar','double'},{'nonnan'},'isrunning','str2double(process_id)');
            try
                system(obj,['kill -0 ',pid]);
                ret=true;
            catch ME %#ok<NASGU>
                ret=false;
            end
        end
    end
    methods(Hidden)
        function status=logProcess(obj,pid,cmdLogFile,cmdStatFile)
            validateattributes(str2double(pid),{'scalar','double'},{'nonnan'},'isrunning','str2double(pid)');
            validateattributes(cmdLogFile,{'char'},{'nonempty'},'','command_log_file',2);
            validateattributes(cmdStatFile,{'char'},{'nonempty'},'','command_status_file',3);
            if isunix
                done=false;
                logSize=0;
                while~done
                    done=~isrunning(obj,pid);
                    try
                        output=system(obj,['stat --format=%s ',cmdLogFile]);
                    catch

                        continue;
                    end
                    currLogSize=str2double(output);
                    if~isnan(currLogSize)&&(currLogSize>logSize)
                        try


                            logOut=system(obj,sprintf('tail -c +%d %s',logSize,cmdLogFile));
                            logSize=logSize+numel(logOut);
                            disp(logOut);
                        catch
                        end
                    end
                    pause(1);
                end
                status=str2double(system(obj,['cat ',cmdStatFile]));
            end
        end

        function filesys=getFilesystem(hwObj)
            filesys='';
            [status,out]=execute(hwObj,'cat /proc/cmdline');
            if(status)
                return
            else
                filesysStruct=regexp(out,'root=(?<filesystem>\S*)','names');
                if~isempty(filesysStruct)
                    filesys=filesysStruct.filesystem;
                end
            end
        end

        function[success,osinfo]=getVersionInfo(hwObj)
            success=false;
            osinfo=struct('ProcessorModel','<unknown>','Kernel','<unknown>',...
            'BuildUser','<unknown>','BuildComputer','<unknown>',...
            'GCC','<unknown>','NumProcessors',0);
            pat='version\s+(?<Kernel>\S*)\s+\((?<BuildUser>.*)@(?<BuildComputer>.*)\)\s+\(gcc\s*version\s*(?<GCC>\S*)';
            try
                versionText=system(hwObj,'cat /proc/version');
                verinfo=regexp(versionText,pat,'names');
                numCpusTxt=system(hwObj,'cat /proc/cpuinfo | grep processor -c');
                numCpus=str2double(strtrim(numCpusTxt));
                cpuModelTxt=system(hwObj,'cat /proc/cpuinfo | grep ''model name'' | uniq');
                cpuModel=regexp(cpuModelTxt,'model name\s*\:\s*(?<ProcessorModel>[^\t\r\n\f\v]*)','names');

                osinfo=cell2struct([struct2cell(cpuModel);struct2cell(verinfo)],...
                [fieldnames(cpuModel);fieldnames(verinfo)]);
                osinfo.NumProcessors=numCpus;
                success=true;
            catch
            end
        end

        function ret=hasPackageManagementSystem(hwObj)
            ret=true;
        end

    end
end


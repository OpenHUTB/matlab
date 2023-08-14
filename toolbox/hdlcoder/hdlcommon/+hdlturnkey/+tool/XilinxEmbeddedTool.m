


classdef(Abstract)XilinxEmbeddedTool<hdlturnkey.tool.EmbeddedTool


    properties


    end

    methods

        function obj=XilinxEmbeddedTool(hETool)

            obj=obj@hdlturnkey.tool.EmbeddedTool(hETool);
        end

    end

    methods(Access=protected)

        function[xilinxInstallPath,xilinxPlatformStr]=getISEInstalltionPath(~,absPathStr)


            regsepStr=filesep;
            if strcmp(regsepStr,'\')
                regsepStr='\\';
            end
            pathCell=regexp(absPathStr,regsepStr,'split');


            if length(pathCell)<3||~strcmpi(pathCell{end-1},'bin')
                error(message('HDLShared:setuptoolpath:InvalidXilinxPath',absPathStr));
            end


            xilinxPlatformStr=pathCell{end};
            xilinxInstallPath=strrep(absPathStr,[filesep,'ISE',filesep,fullfile('bin',xilinxPlatformStr)],'');

        end

        function[status,result]=runTclFile(obj,tclFilePath,toolCmdStr,runExtShell)


            if nargin<4
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
                hDI=obj.hETool.getDIObject;


                if(hDI.logDisplay)
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


            status=obj.checkForError(~statusSys,resultSys);
            cd(currentDir);
        end

        function status=checkForError(~,status,log)
            if status

                search_result=regexp(log,'ERROR','once');
                if~isempty(search_result)
                    status=false;
                end
            end
        end


    end

end





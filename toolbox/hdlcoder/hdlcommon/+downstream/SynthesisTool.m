



classdef SynthesisTool<handle


    properties


        ToolName='';
        ToolVersion='';
        ToolPath='';


        CurrentDir='';


        PluginPath='';
        PluginPackage='';


        ProjectName='';
        ProjectFileName='';
        ProjectDir='';


        CustomHDLFile={};
        CustomHDLFileStr='';
        CustomSourceFileStr='';


        CustomTclFile={};
        CustomTclFileStr='';


        cmd_openTargetTool='';
        cmd_runTclScript='';


        cmd_captureError='';


        cmd_logRegExp='';


        UnSupportedVersion=false;
        VersionWarningMsg='';

    end

    properties(Access=protected,Hidden=true)

        hToolDriver=0;
    end


    methods

        function obj=SynthesisTool(hToolDriver)


            obj.hToolDriver=hToolDriver;

            obj.CurrentDir=pwd;

        end

        function lockCurrentDir(obj)

            obj.CurrentDir=pwd;
        end

        function parseProjectDirStr(obj,projectDirStr)

            if isempty(projectDirStr)
                error(message('hdlcommon:workflow:InvalidProjectDir'));
            else
                obj.ProjectDir=projectDirStr;
            end

        end

        function[customFile,customTclFile]=parseCustomFileStrWithTcl(~,customFileStr)

            strCell=regexp(customFileStr,'\s*;\s*','split');

            customFile={};
            customTclFile={};
            for ii=1:length(strCell)
                strFile=strCell{ii};
                if~isempty(strFile)
                    if exist(strFile,'file')
                        [~,~,fileExt]=fileparts(strFile);
                        if~strcmpi(fileExt,'.tcl')
                            customFile{end+1}=strFile;%#ok<AGROW>
                        else
                            customTclFile{end+1}=strFile;%#ok<AGROW>
                        end
                    else
                        error(message('hdlcommon:workflow:InvalidCustomHDLFile',strFile));
                    end
                end
            end


            customFile=unique(customFile,'stable');
            customTclFile=unique(customTclFile,'stable');
        end

        function createCustomSourceTclHDLFileStrings(obj)
            obj.CustomHDLFileStr=strjoin([obj.CustomHDLFile,obj.CustomTclFile],';');
            if(~isempty(obj.CustomHDLFileStr))
                obj.CustomHDLFileStr(end+1)=';';
            end
            obj.CustomTclFileStr=strjoin(obj.CustomTclFile,';');
            if(~isempty(obj.CustomTclFileStr))
                obj.CustomTclFileStr(end+1)=';';
            end
            obj.CustomSourceFileStr=strjoin(obj.CustomHDLFile,';');
            if(~isempty(obj.CustomSourceFileStr))
                obj.CustomSourceFileStr(end+1)=';';
            end
        end
        function openTargetTool(obj)

            if isempty(obj.ProjectFileName)
                error(message('hdlcommon:workflow:ProjectFileNotCreated'));
            end
            isLiberoSoC=strcmpi(obj.ToolName,'Microchip Libero SoC');

            if isLiberoSoC
                projectPath=fullfile(obj.ProjectDir,obj.ProjectName,obj.ProjectFileName);
            else
                projectPath=fullfile(obj.ProjectDir,obj.ProjectFileName);
            end
            if~exist(projectPath,'file')
                hM=message('hdlcommon:workflow:NoProjectFile',projectPath);
                if obj.hToolDriver.hD.cmdDisplay
                    error(hM);
                else
                    errordlg(hM.getString,'Error','modal');
                    return;
                end
            end
            currentDir=pwd;
            if isLiberoSoC
                cd(fullfile(obj.ProjectDir,obj.ProjectName));
            else
                cd(obj.ProjectDir);
            end
            CmdStr=[fullfile(obj.ToolPath,obj.cmd_openTargetTool),' ',obj.ProjectFileName,' &'];
            system(CmdStr);
            cd(currentDir);
        end

        function link=getProjectLink(obj)
            cmd=[fullfile(obj.ToolPath,obj.cmd_openTargetTool),' ',obj.ProjectFileName,' &'];
            isLiberoSoC=strcmpi(obj.ToolName,'Microchip Libero SoC');
            if isLiberoSoC
                prj=fullfile(obj.ProjectDir,obj.ProjectName,obj.ProjectFileName);
            else
                prj=fullfile(obj.ProjectDir,obj.ProjectFileName);
            end

            link=sprintf(...
            '<a href="matlab:downstream.tool.openTargetTool(''%s'',''%s'',%d);">%s</a>',...
            cmd,...
            prj,...
            obj.hToolDriver.hD.cmdDisplay,...
            prj);

        end

        function[status,result]=runTclFile(obj,tclFileName)

            tic;
            currentDir=pwd;
            cd(obj.CurrentDir);
            cd(obj.ProjectDir);
            if~exist(tclFileName,'file')
                error(message('hdlcommon:workflow:NoTclFile'));
            end
            if strcmpi(obj.ToolName,'Microchip Libero SoC')
                CmdStr=[obj.getToolTclCmdStrfull,' ','SCRIPT:',tclFileName];
            else
                CmdStr=[obj.getToolTclCmdStrfull,' ',tclFileName];
            end

            [status,systemResult]=system(CmdStr);
            cd(currentDir);
            time=toc;
            result=sprintf('%s\nElapsed time is %s seconds.\n',systemResult,num2str(time));
        end

        function toolTclCmdStr=getToolTclCmdStrfull(obj)

            toolTclCmdStr=fullfile(obj.ToolPath,obj.cmd_runTclScript);
        end

    end

end






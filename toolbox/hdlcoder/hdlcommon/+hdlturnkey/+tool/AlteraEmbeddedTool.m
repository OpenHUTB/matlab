


classdef AlteraEmbeddedTool<hdlturnkey.tool.EmbeddedTool


    properties

    end

    properties(Access=protected)

    end

    properties(Constant,Abstract)

ProjectFileExt

    end

    properties(Constant)


        LocalIPFolder='ip';

        APIVer='13.1';

    end

    methods

        function obj=AlteraEmbeddedTool(hETool)

            obj=obj@hdlturnkey.tool.EmbeddedTool(hETool);
        end

    end


    methods

        function checkToolPath(obj)


            alteraToolPath=obj.hETool.hIP.hD.hToolDriver.getToolPath;
            obj.ToolPath=alteraToolPath;

        end
    end


    methods


        function name=getProjectName(obj)
            name=obj.ProjectName;
        end

        function folder=getRelProjectFolder(obj)
            folder=obj.ProjectFolder;
        end

        function name=getProjectFileName(obj)
            name=sprintf('%s.%s',obj.ProjectName,obj.ProjectFileExt);
        end

        function pcoreName=getIPCoreName(obj)
            pcoreName=obj.hETool.hIP.getIPCoreName;
        end

        function instName=getIPCoreInstanceName(obj)
            instName=sprintf('%s_0',obj.getIPCoreName);
        end

        function sigName=getIPCorePortExtSigName(obj,portName)
            sigName=sprintf('%s_%s',obj.getIPCoreInstanceName,portName);
        end

        function pinName=getIPCorePortExtPinName(obj,portName)
            pinName=sprintf('%s_pin',obj.getIPCorePortExtSigName(portName));
        end

        function cmdStrFull=getCmdStrFull(obj,cmdStr)

            cmdStrFull=fullfile(obj.ToolPath,cmdStr);
        end

    end

    methods

    end

    methods(Access=protected)

        function copyIPCoreToProjFolder(obj)

            sourcePath=obj.hETool.hIP.getIPCoreFolder;
            pcoreFolderName=obj.hETool.hIP.hIPEmitter.getIPCoreFolderName;
            targetPath=fullfile(obj.getProjectFolder,...
            obj.LocalIPFolder,pcoreFolderName);

            downstream.tool.createDir(fileparts(targetPath));
            copyfile(sourcePath,targetPath,'f');
        end

        function fpgaPartStr=getFPGADeviceStr(obj)

            deviceName=obj.hETool.hIP.hD.get('Device');
            fpgaPartStr=sprintf('%s',deviceName);
        end

        function fpgaFamily=getFPGAFamily(obj)

            familyName=obj.hETool.hIP.hD.get('Family');
            fpgaFamily=sprintf('%s',familyName);
        end

        function ioStr=portToPinRegEx(obj,ioStr,portName)
            pinName=obj.getIPCorePortExtPinName(portName);
            ioStr=regexprep(ioStr,[portName,'\>'],pinName);
        end

        function tclSourceFile(obj,fid,filePath)

            fprintf(fid,'source %s\n',obj.toRelTclPath(filePath));
        end

        function generateRDParameterTcl(~,fid,hRD)

            paramStruct=hRD.getParameterStructFormat;
            if~isempty(paramStruct)
                paramIDCell=fieldnames(paramStruct);
                for ii=1:length(paramIDCell)
                    paramID=paramIDCell{ii};
                    fprintf(fid,'set %s {%s}\n',paramID,paramStruct.(paramID));
                end
            end
        end

    end

    methods(Static)
        function[status,result]=run_cmd(cmdStr,errstr,logDisplay)


            if nargin<2
                errstr='';
            end

            if nargin<3
                logDisplay=false;
            end


            if(logDisplay)
                [status,result]=system(cmdStr,'-echo');
            else
                [status,result]=system(cmdStr);
            end

            result=regexprep(result,[char(27),'.*?m'],'');

            if~isempty(errstr)
                if~status
                    search_result=regexp(result,errstr,'once');
                    if~isempty(search_result)
                        status=true;
                    end
                end
            end


            status=~status;
        end
    end

end



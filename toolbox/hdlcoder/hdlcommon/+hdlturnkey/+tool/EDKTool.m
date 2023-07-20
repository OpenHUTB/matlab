


classdef EDKTool<hdlturnkey.tool.XilinxEmbeddedTool


    properties


        hMHSEmitter=[];

    end

    properties(Access=protected)


        ProjectFolder='edk_prj';

    end


    properties(Constant)

        CreateProjTcl='edk_create_proj.tcl';
        LoadMHSTcl='edk_resync.tcl';

        TclCmdStr='xps -nw -scr';

        LocalIPFolder='pcores';

        ProjectName='system';
    end

    methods

        function obj=EDKTool(hETool)

            obj=obj@hdlturnkey.tool.XilinxEmbeddedTool(hETool);
            obj.hMHSEmitter=hdlturnkey.tool.MHSEmitter(obj);
        end

        function checkToolPath(obj)

            iseToolPath=obj.hETool.hIP.hD.hToolDriver.getToolPath;
            [xilinxInstallPath,xilinxPlatformStr]=obj.getISEInstalltionPath(iseToolPath);
            obj.ToolPath=fullfile(xilinxInstallPath,'EDK','bin',xilinxPlatformStr);
            if~exist(obj.ToolPath,'dir')
                error(message('hdlcommon:workflow:ToolFileNotAvailable','EDK',obj.ToolPath));
            end
        end

        function[status,result]=runCreateProject(obj)



            hRD=obj.hETool.getRDPlugin;


            methodStr=hRD.IPInsertionMethod;
            if~strcmpi(methodStr,'Insert')&&~strcmpi(methodStr,'Replace')
                error(message('hdlcommon:workflow:IPInsertMethodInvalid'));
            end


            obj.removeRequiredFiles;


            tclFilePath=generateCreateProjTcl(obj);
            [status1,result1]=obj.runTclFile(tclFilePath,obj.getTclCmdStrFull);
            if~status1

                status=status1;
                result=result1;
                return;
            end


            copyRequiredFiles(obj,hRD);


            if strcmpi(methodStr,'Insert')
                obj.hMHSEmitter.insertIPCoreToMHSFile(hRD);
            elseif strcmpi(methodStr,'Replace')
                obj.hMHSEmitter.replaceIPCoreInMHSFile(hRD);
            else
                error(message('hdlcommon:workflow:IPInsertMethodInvalid'));
            end


            copyIPCoreToProjFolder(obj);


            tclFilePath=generateLoadMHSTcl(obj);
            [status2,result2]=obj.runTclFile(tclFilePath,obj.getTclCmdStrFull);

            status=status1&&status2;
            result=sprintf('%s%s',result1,result2);
        end


        function name=getProjectName(obj)
            name=obj.ProjectName;
        end
        function name=getProjectFileName(obj)
            name=sprintf('%s.xmp',obj.ProjectName);
        end
        function name=getMHSFileName(obj)
            name=sprintf('%s.mhs',obj.ProjectName);
        end
        function path=getBitstreamPath(obj)
            path=fullfile(obj.getProjectFolder,'implementation',...
            sprintf('%s.bit',obj.ProjectName));
        end

    end

    methods(Access=protected)

        function tclFilePath=generateCreateProjTcl(obj)



            hBoard=obj.hETool.getBoardObject;
            hCodeGen=obj.hETool.getCodeGenObject;
            if hCodeGen.isVHDL
                targetL='vhdl';
            else
                targetL='verilog';
            end


            tclFilePath=fullfile(obj.getProjectFolder,obj.CreateProjTcl);
            fid=downstream.tool.createTclFile(tclFilePath,obj.hETool.hIP.getCurrentDir);

            fprintf(fid,'# Create new project\n');
            fprintf(fid,'xload new %s\n',obj.getProjectFileName);
            fprintf(fid,'xset arch %s\n',hBoard.FPGAFamily);
            fprintf(fid,'xset dev %s\n',hBoard.FPGADevice);
            fprintf(fid,'xset package %s\n',hBoard.FPGAPackage);
            fprintf(fid,'xset speedgrade %s\n',hBoard.FPGASpeed);
            fprintf(fid,'xset hdl %s\n',targetL);
            fprintf(fid,'xset parallel_synthesis yes\n');


            ipRepositoryPath=obj.hETool.hIP.getIPRepository;
            if~isempty(ipRepositoryPath)
                ipRepositoryFolder=downstream.tool.filterBackSlash(...
                downstream.tool.getAbsoluteFolderPath(ipRepositoryPath));
                fprintf(fid,'xset searchpath %s\n',ipRepositoryFolder);
            end



            fprintf(fid,'save proj\n');
            fprintf(fid,'exit\n');
            fclose(fid);
        end

        function tclFilePath=generateLoadMHSTcl(obj)


            tclFilePath=fullfile(obj.getProjectFolder,obj.LoadMHSTcl);
            fid=downstream.tool.createTclFile(tclFilePath,obj.hETool.hIP.getCurrentDir);

            fprintf(fid,'# Load project\n');
            fprintf(fid,'xload xmp %s\n',obj.getProjectFileName);
            fprintf(fid,'# Load MHS file\n');
            fprintf(fid,'run resync\n');
            fprintf(fid,'# Perform design rule check\n');
            fprintf(fid,'run drc\n');
            fprintf(fid,'save proj\n');
            fprintf(fid,'exit\n');
            fclose(fid);
        end


        function copyIPCoreToProjFolder(obj)




            ipRepositoryPath=obj.hETool.hIP.getIPRepository;
            if~isempty(ipRepositoryPath)
                return;
            end

            sourcePath=obj.hETool.hIP.getIPCoreFolder;
            pcoreFolderName=obj.hETool.hIP.hIPEmitter.getIPCoreFolderName;
            targetPath=fullfile(obj.getProjectFolder,...
            obj.LocalIPFolder,pcoreFolderName);

            downstream.tool.createDir(fileparts(targetPath));
            copyfile(sourcePath,targetPath,'f');
        end

        function copyRequiredFiles(obj,hRD)

            edkFolder=hRD.RequiredEDKFolder;
            mhsFile=hRD.CustomEDKMHS;
            fileList=hRD.RequiredEDKFiles;


            sourceMHSPath=fullfile(edkFolder,mhsFile);
            targetMHSPath=obj.getMHSFileName;
            obj.copyFileFromRD(sourceMHSPath,targetMHSPath,hRD);


            for ii=1:length(fileList)
                afile=fileList{ii};
                sourceFile=fullfile(edkFolder,afile);
                targetFile=afile;
                obj.copyFileFromRD(sourceFile,targetFile,hRD);
            end


            obj.copyCustomFiles(hRD);


            obj.copyIPRepositories(hRD);
        end

        function removeRequiredFiles(obj)

            mhsFilePath=fullfile(obj.getProjectFolder,obj.getMHSFileName);


            if exist(mhsFilePath,'file')
                delete(mhsFilePath);
            end

        end

    end

    methods(Static)
        function[status,result]=downloadBit(bitstreamPath,toolPath,chainPosition)



            if nargin<3||isempty(chainPosition)
                chainPosition=2;
            end

            if nargin<2
                toolPath='';
            end


            bitstreamPath=regexprep(bitstreamPath,'\\','/');


            downloadTclFileName='xmd_download.tcl';
            fid=downstream.tool.createTclFile(downloadTclFileName);

            fprintf(fid,'fpga -debugdevice devicenr %d -f %s\n',chainPosition,bitstreamPath);
            fprintf(fid,'exit');
            fclose(fid);


            xmdCmdPath=fullfile(toolPath,'xmd');
            cmdStr=sprintf('%s -tcl %s',xmdCmdPath,downloadTclFileName);
            [statusSys,result]=system(cmdStr);

            status=~statusSys;
        end

    end

end





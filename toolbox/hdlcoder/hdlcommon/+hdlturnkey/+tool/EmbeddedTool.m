


classdef(Abstract)EmbeddedTool<handle


    properties


        hETool=[];


        ToolPath='';
    end

    properties(Abstract,Access=protected)


ProjectFolder

    end

    methods
        function obj=EmbeddedTool(hETool)

            obj.hETool=hETool;
        end
    end

    methods(Abstract)

        checkToolPath(obj)
    end

    methods


        function folder=getProjectFolder(obj)
            folder=fullfile(obj.hETool.hIP.hD.getProjectFolder,obj.ProjectFolder);
        end


        function SlackTolerance=getSlackTolerance(obj)


            if obj.hETool.hIP.getReportTimingFailureTolerance>0
                SlackTolerance=obj.hETool.hIP.getReportTimingFailureTolerance;
            else
                SlackTolerance=obj.hETool.getRDPlugin.ReportTimingFailureTolerance;
            end
        end

    end

    methods(Access=public)
        function unzipFileFromRD(obj,sourceFile,targetFile,hRD)
            [sourcePath,targetPath]=obj.getFilePathFromRD(sourceFile,targetFile,hRD);
            obj.unzipFile(sourcePath,targetPath);
        end
    end

    methods(Access=protected)

        function copyConstrainFiles(obj,hRD)

            fileList=hRD.CustomConstraints;
            for ii=1:length(fileList)
                afile=fileList{ii};
                sourceFile=afile;
                targetFile=afile;
                obj.copyFileFromRD(sourceFile,targetFile,hRD);

                obj.ConstraintFiles{end+1}=afile;
            end
        end


        function copyConstraintFiles(obj,ConstraintFileExt)


            pcoreSrcList=obj.hETool.hIP.hIPEmitter.IPCoreSrcFileList;
            for ii=1:length(pcoreSrcList)
                srcFileStruct=pcoreSrcList{ii};
                srcFile=srcFileStruct.FilePath;


                [~,fileName,extName]=fileparts(srcFile);
                if~(strcmpi(extName,ConstraintFileExt)||strcmpi(extName,'.tcl'))
                    continue;
                end


                txt=fileread(srcFile);
                s=regexp(txt,'^[^#\s].*','lineanchors');
                if(isempty(s))
                    continue;
                end

                sourcePath=srcFile;
                targetPath=fullfile(obj.getProjectFolder,[fileName,extName]);

                targetFileFolder=fileparts(targetPath);
                downstream.tool.createDir(targetFileFolder);


                copyfile(sourcePath,targetPath,'f');


                obj.ConstraintFiles{end+1}=[fileName,extName];
            end


        end


        function copyIPRepositories(obj,hRD)

            ipRepositories=hRD.IPRepositories;
            for ii=1:length(ipRepositories)
                ipRepo=ipRepositories{ii};
                if nargout(ipRepo)==1


                    ipList=feval(ipRepo);
                    ipRepoPath=which(ipRepo);
                    [ipDir,~,~]=fileparts(ipRepoPath);
                elseif nargout(ipRepo)==2

                    [ipList,ipDir]=feval(ipRepo);
                else
                    error(message('hdlcommon:plugin:InvalidOutputIPRepositoryFunction',...
                    ipRepo));
                end


                if isempty(ipList)
                    dirList=dir(ipDir);
                    for jj=1:length(dirList)
                        name=dirList(jj).name;
                        [~,~,fileExt]=fileparts(name);


                        if~strcmp(name,'.')&&~strcmp(name,'..')&&~strcmp(fileExt,'.m')
                            sourcePath=fullfile(ipDir,name);
                            targetPath=fullfile(obj.getProjectFolder,obj.LocalIPFolder,name);
                            obj.copyFile(sourcePath,targetPath)
                        end
                    end
                else
                    for jj=1:length(ipList)
                        sourcePath=fullfile(ipDir,ipList{jj});
                        targetPath=fullfile(obj.getProjectFolder,obj.LocalIPFolder,ipList{jj});
                        obj.copyFile(sourcePath,targetPath);
                    end
                end
            end

        end
        function copyCustomFiles(obj,hRD)

            fileList=hRD.CustomFiles;
            for ii=1:length(fileList)
                afile=fileList{ii};
                sourceFile=afile;
                targetFile=afile;
                obj.copyFileFromRD(sourceFile,targetFile,hRD);
            end
        end

        function copyFileList(obj,fileList,hRD)

            for ii=1:length(fileList)
                sourceFile=fileList{ii}{1};
                targetFile=fileList{ii}{2};
                obj.copyFileFromRD(sourceFile,targetFile,hRD);
            end
        end

        function copyFileListOptional(obj,fileList,hRD)

            for ii=1:length(fileList)
                sourceFile=fileList{ii}{1};
                targetFile=fileList{ii}{2};
                if~isempty(sourceFile)
                    obj.copyFileFromRD(sourceFile,targetFile,hRD);
                end
            end
        end

        function copyFileFromRD(obj,sourceFile,targetFile,hRD)
            [sourcePath,targetPath]=obj.getFilePathFromRD(sourceFile,targetFile,hRD);
            obj.copyFile(sourcePath,targetPath);
        end

        function[sourcePath,targetPath]=getFilePathFromRD(obj,sourceFile,targetFile,hRD)

            sourcePath=hRD.getFilePathFromRD(sourceFile);


            sourcePath=downstream.tool.fixFileSep(sourcePath);
            targetFile=downstream.tool.fixFileSep(targetFile);


            obj.checkRequiredFiles(sourcePath);
            targetPath=fullfile(obj.getProjectFolder,targetFile);
        end


        function tclCmdStrFull=getTclCmdStrFull(obj)
            if obj.hETool.hIP.hD.isQuartusPro
                tclCmdStrFull=fullfile(obj.ToolPath,obj.TclCmdStrQPro);
            else

                tclCmdStrFull=fullfile(obj.ToolPath,obj.TclCmdStr);
            end
        end

        function ioPath=toRelTclPath(obj,ioPath)

            ioPath=strrep(ioPath,obj.getProjectFolder,'.');

            ioPath=strrep(ioPath,'\','/');
        end

        function fid=createFile(obj,filePath)


            currentDir=pwd;
            cd(obj.hETool.hIP.getCurrentDir);
            fileFolder=fileparts(filePath);
            downstream.tool.createDir(fileFolder);

            fid=fopen(filePath,'w');
            if fid==-1
                error(message('hdlcommon:workflow:UnableCreateFile',filePath));
            end
            cd(currentDir);
        end

        function checkRequiredFiles(~,filePath)
            if~(exist(filePath,'file')||exist(filePath,'dir'))
                error(message('hdlcommon:workflow:RequiredFileUnavailable',filePath));
            end
        end

        function copyFile(~,sourcePath,targetPath)
            [directory,~,~]=fileparts(targetPath);
            downstream.tool.createDir(directory);
            copyfile(sourcePath,targetPath,'f');
            fileattrib(targetPath,'+w');
        end

        function unzipFile(~,sourcePath,targetPath)
            [directory,~,~]=fileparts(targetPath);
            downstream.tool.createDir(directory);
            unzip(sourcePath,targetPath);
            fileattrib(targetPath,'+w');
        end

        function fileNameStr=getFileName(~,filePath)
            [~,fileName,fileExt]=fileparts(filePath);
            fileNameStr=sprintf('%s%s',fileName,fileExt);
        end

    end

end































classdef AttachmentManager<handle

    properties
filePath
    end

    properties(Hidden,Constant)
        ATTACHMENTS='ATTACHMENTS';

        PATH_SEP='/';
    end

    methods(Access=private)













        function filePath=getFilePath(this,reqSet)
            if isa(reqSet,'slreq.das.RequirementSet')
                filePath=reqSet.Filepath;
            elseif isa(reqSet,'slreq.ReqSet')
                filePath=reqSet.Filename;
            elseif isa(reqSet,'slreq.data.RequirementSet')
                filePath=reqSet.filepath;
            else
                error('Illegal argument');
            end
        end





        function packagePath=getPackagePathForAttachment(this,reqId,attachmentName)



            basePath=this.getBasePath();
            if~isempty(reqId)
                basePath=[basePath,reqId,this.PATH_SEP];
            end
            packagePath=[basePath,attachmentName];
        end




        function basePath=getBasePath(this)
            basePath=[this.PATH_SEP,this.ATTACHMENTS,this.PATH_SEP];
        end
    end

    methods






        function this=AttachmentManager(filePath)
            this.filePath=filePath;
        end




        function out=get.filePath(this)
            out=this.filePath;
        end












        function addAttachment(this,reqSet,reqId,attachedFile)

            [attachedFilePath,attachedFileName,attachedExt]=fileparts(attachedFile);

            attachmentName=[attachedFileName,attachedExt];
            packagePath=this.getPackagePathForAttachment(reqId,attachmentName);

            package=slreq.opc.Package(this.filePath);
            package.addFile(attachedFile,packagePath);
        end






        function attachments=getAttachments(this,reqSet,reqId)









            package=slreq.opc.Package(this.filePath);

            attachments={};


            fileList=package.getFileList();
            for i=1:length(fileList)
                afile=fileList{i};


                tokens=strsplit(afile,'/');



                if length(tokens)<2
                    continue;
                end

                if~strcmp(tokens{2},this.ATTACHMENTS)
                    continue;
                end

                if isempty(reqId)



                    if length(tokens)==3
                        attachmentName=tokens{3};
                    else

                        continue;
                    end
                else



                    if length(tokens)==4

                        if~strcmp(reqId,tokens{3})

                            continue;
                        end

                        attachmentName=tokens{4};
                    else

                        continue;
                    end
                end

                attachments{end+1}=attachmentName;%#ok<AGROW>
            end
        end








        function downloadAttachment(this,reqSet,reqId,attachmentName,downloadLocation)

            packagePath=this.getPackagePathForAttachment(reqId,attachmentName);

            package=slreq.opc.Package(this.filePath);

            downloadPath=fullfile(downloadLocation,attachmentName);

            try
                package.copyFile(packagePath,downloadPath);
            catch ex


            end
        end








        function deleteAttachment(this,reqSet,reqId,attachmentName)


            packagePath=this.getPackagePathForAttachment(reqId,attachmentName);

            package=slreq.opc.Package(this.filePath);

            package.removeFile(packagePath);
        end


        function updateAttachment(this,reqSet,reqId,filePath)
        end




        function out=hasPackage(this)



            package=slreq.opc.Package(this.filePath);
            out=package.isValidPackage();
        end


        function out=needsCopying(this,newFilePath)
            out=this.hasPackage()&&...
            ~strcmp(this.filePath,newFilePath);
        end


        function updateFilePath(this,newFilePath)

            this.filePath=newFilePath;
        end








        function copyAttachments(this,otherFilePath)
            currentPackage=slreq.opc.Package(this.filePath);

            allFiles=currentPackage.getFileList();

            basePath=this.getBasePath();
            basePathLength=length(basePath);

            pkgPaths={};
            for i=1:length(allFiles)
                attachedFile=allFiles{i};
                if strcmp(attachedFile(1:basePathLength),basePath)
                    pkgPaths{end+1}=attachedFile;%#ok<AGROW>
                end
            end



            if isempty(pkgPaths)
                return;
            end


            tempDir=slreq.opc.getUsrTempDir();
            actualPaths={};







            for i=1:length(pkgPaths)
                packagePath=pkgPaths{i};

                actualPath=fullfile(tempDir,packagePath);
                actualPaths{end+1}=actualPath;%#ok<AGROW>

                currentPackage.copyFile(packagePath,actualPath);
            end






            otherPackage=slreq.opc.Package(otherFilePath);
            otherPackage.addFiles(actualPaths,pkgPaths);
        end

    end
end
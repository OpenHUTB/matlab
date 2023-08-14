classdef PackageCreator<handle




    properties
        TargetPart(1,1)
        ProjectFolder(1,:)char=''
        InfoFilePath(1,:)char=''
        ExportFilePath(1,:)char=''
    end

    methods
        function obj=PackageCreator()
            obj.ProjectFolder=pwd;


            obj.InfoFilePath=fullfile('.packageInfo','packageInfo.json');
        end

        function obj=generateProject(obj)


            if isempty(obj.TargetPart);return;end
            obj.TargetPart.populateAllFileList();
            obj.TargetPart.populateAllInformation();


            obj.addTargetPartToProject(obj.ProjectFolder,obj.TargetPart);


            obj.generateInfoFile();


            if isempty(obj.ExportFilePath)
                errMsg=message('ssm:actorMetadata:PackageExportFilePathEmpty');
                error(errMsg);
            end
            zip(obj.ExportFilePath,fullfile(obj.ProjectFolder,obj.TargetPart.PartName));
            rmdir(obj.TargetPart.PartName,'s');
        end

        function set.TargetPart(obj,val)
            if isempty(val)
                error('ProjectCreator.Part cannot set to empty');
            end

            if~isa(val,'ssm.sl_agent_metadata.internal.part.Part')
                error('ProjectCreator.Part must be a child of ssm.sl_agent_metadata.internal.part.Part');
            end

            obj.TargetPart=val;
        end
    end

    methods(Access=private)

        function obj=generateInfoFile(obj)

            if isempty(obj.TargetPart);return;end

            [filepath,name,ext]=fileparts(obj.InfoFilePath);
            filepath=fullfile(obj.TargetPart.PartName,filepath);


            if exist(fullfile(filepath),'dir')~=7
                mkdir(fullfile(filepath));
            end


            fullFileName=fullfile(filepath,[name,ext]);
            fid=fopen(fullFileName,'w');
            encodedJSON=jsonencode(obj.TargetPart.InformationStruct);
            fprintf(fid,encodedJSON);
            fclose(fid);


            protoPkgInfo=ssm.sl_agent_metadata.MxArrayToProto(obj.TargetPart.InformationStruct);
            protoPkgInfo.serializeToFile(fullfile(filepath,[name,'.rrprotodata']));
        end

        function addTargetPartToProject(~,projFolder,TargetPart)

            fInfoList=TargetPart.FileList;
            projFolder=fullfile(projFolder,TargetPart.PartName);


            for idx=1:numel(fInfoList)
                finfo=fInfoList(idx);

                dstFolder=fullfile(projFolder,finfo.DstFolder);

                if exist(dstFolder,'dir')~=7
                    mkdir(dstFolder);
                end

                fullSrcFilePath=fullfile(finfo.SrcFolder,finfo.FileName);
                copyfile(fullSrcFilePath,dstFolder,'f');
            end
        end
    end
end



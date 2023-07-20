classdef Package






    properties
        modelSid;
    end

    properties(GetAccess=public,SetAccess=private)
        filepath;
    end

    properties(Constant,Hidden)
        SLREQS_PART_NAME='slrequirements/data.xml';
        SLREQS_METADATA_PART_NAME='/slrequirements/destsummary.xml';
        SLREQS_LINK_METADATA_SHORT_NAME='destsummary.xml';
    end

    methods
        function this=Package(filepath)
            this.filepath=filepath;
        end


        function save(this,serialisedData,saveOptions)
            if nargin<3
                saveOptions=[];
            end
            try
                iconPath=fullfile(matlabroot,'toolbox','shared','reqmgt','icons','Note.png');

                if~isempty(saveOptions)
                    partName=slreq.internal.generatePartName(saveOptions);
                    SLX_SLREQS_PART_NAME=[partName,this.modelSid,'/data.xml'];

                    p=Simulink.loadsave.SLXPartDefinition(SLX_SLREQS_PART_NAME,...
                    '/simulink/blockdiagram.xml',...
                    'application/vnd.mathworks.simulink.requirements.setData',...
                    'http://schemas.mathworks.com/simulink/2016/relationships/reqData',...
                    'SfReqTable');

                    saveOptions.writerHandle.writePartFromString(p,serialisedData);
                else
                    if exist(this.filepath,'file')~=2
                        slreq.opc.Package.ensureDestPathIfEmbeddedLink(this.filepath);
                        slreq.opc.opc('create',this.filepath,serialisedData,...
                        'Stores tracebility link data',...
                        'Simulink Link Data',...
                        iconPath);
                    else
                        slreq.opc.opc('write',this.filepath,this.SLREQS_PART_NAME,false,serialisedData);
                    end
                end
            catch ex
                if contains(ex.message,'filesystem:AccessDenied')
                    error(message('Slvnv:slreq:UnableToSave',this.filepath));
                elseif contains(ex.message,'filesystem:PathNotFound')
                    rmiut.warnNoBacktrace([ex.message,newline...
                    ,'This could be due to insufficient cleanup between automated testpoints.']);
                    linkSet=slreq.utils.getLinkSet(this.filepath);
                    if~isempty(linkSet)
                        linkSet.discard();
                    end
                elseif contains(ex.message,'Could not open source package')




                    [~,~,fExt]=fileparts(this.filepath);
                    fExt=lower(fExt);
                    if strcmp(fExt,'.slreqx')
                        msgId='Slvnv:slreq:InvalidCorruptSLREQXFile';
                    elseif strcmp(fExt,'.slmx')
                        msgId='Slvnv:slreq:InvalidCorruptSLMXFile';
                    end
                    error(message(msgId,this.filepath));
                else
                    rethrow(ex);
                end
            end
        end


        function saveLinkMetadata(this,serialisedMetaData,saveOptions)
            if nargin<3
                saveOptions=[];
            end

            try
                if~isempty(saveOptions)
                    partName=slreq.internal.generatePartName(saveOptions);
                    SLX_SLREQS_METADATA_PART_NAME=[partName,this.modelSid,'/destsummary.xml'];
                    p=Simulink.loadsave.SLXPartDefinition(SLX_SLREQS_METADATA_PART_NAME,...
                    '/simulink/blockdiagram.xml',...
                    'application/vnd.mathworks.simulink.requirements.setData',...
                    'http://schemas.mathworks.com/simulink/2016/relationships/reqData',...
                    'SfReqTable');

                    saveOptions.writerHandle.writePartFromString(p,serialisedData);
                else
                    if isfile(this.filepath)
                        slreq.opc.opc('write',this.filepath,this.SLREQS_METADATA_PART_NAME,false,serialisedMetaData);
                    end
                end
            catch ex
                if contains(ex.message,'filesystem:AccessDenied')
                    error(message('Slvnv:slreq:UnableToSave',this.filepath));
                elseif contains(ex.message,'filesystem:PathNotFound')
                    linkSet=slreq.utils.getLinkSet(this.filepath);
                    if~isempty(linkSet)
                        linkSet.discard();
                    end
                elseif contains(ex.message,'Could not open source package')

                else
                    rethrow(ex);
                end
            end
        end






        function data=readFile(this,fileName,loadOptionsOrCopyFile)

            if nargin<2||isempty(fileName)
                fileName=this.SLREQS_PART_NAME;
            end

            loadOptions=[];
            copyFileName=[];

            if nargin==3
                if isa(loadOptionsOrCopyFile,'Simulink.internal.BDLoadOptions')
                    loadOptions=loadOptionsOrCopyFile;
                end
                if ischar(loadOptionsOrCopyFile)
                    copyFileName=loadOptionsOrCopyFile;
                end
            end

            if~isempty(loadOptions)
                partName=slreq.internal.generatePartName(loadOptions);
                fileName=[partName,this.modelSid,'/data.xml'];
                data=loadOptions.readerHandle.readPartToString(fileName);
                return;
            end

            if~isempty(copyFileName)
                data=slreq.opc.opc('read',this.filepath,fileName,copyFileName);
                return;
            end

            data=slreq.opc.opc('read',this.filepath,fileName);
        end



        function data=readFiles(this,fileNames,loadOptions)
            if nargin<3
                loadOptions=[];
            end
            if isempty(loadOptions)
                data=slreq.opc.opc('read',this.filepath,fileNames);
            else

            end
        end

        function data=readMetadata(this,loadOptions)
            if nargin<2
                loadOptions=[];
            end

            if isempty(loadOptions)
                data=slreq.opc.opc('read',this.filepath,this.SLREQS_METADATA_PART_NAME);
            else

            end
        end


        function copyFile(this,packagePath,targetFilePath)
            slreq.opc.opc('read',this.filepath,slreq.opc.Package.ensureRootPath(packagePath),targetFilePath);
        end


        function copyFiles(this,packagePaths,targetFilePaths,loadOptions)
            if nargin<4||isempty(loadOptions)
                slreq.opc.opc('read',this.filepath,slreq.opc.Package.ensureRootPaths(packagePaths),targetFilePaths);
            else
                for i=1:length(targetFilePaths)
                    fpath=targetFilePaths{i};
                    packagePath=packagePaths{i};
                    loadOptions.readerHandle.readPartToFile(packagePath,fpath);
                end
            end
        end


        function addFile(this,filepath,packagePath,saveOptions)
            if nargin<4
                saveOptions=[];
            end
            if isempty(saveOptions)
                slreq.opc.opc('write',this.filepath,slreq.opc.Package.ensureRootPath(packagePath),true,filepath);
            else
            end
        end


        function addFiles(this,filepaths,packagePaths,saveOptions)
            if nargin<4
                saveOptions=[];
            end
            if isempty(saveOptions)
                slreq.opc.opc('write',this.filepath,slreq.opc.Package.ensureRootPaths(packagePaths),true,filepaths);
            else
                for i=1:length(filepaths)
                    fpath=filepaths{i};
                    packagePath=packagePaths{i};
                    [~,~,ext]=fileparts(fpath);
                    partName=slreq.internal.generatePartName(saveOptions);
                    p=Simulink.loadsave.SLXPartDefinition([partName,packagePath],...
                    '',...
                    ['image/',ext(2:end)],...
                    'http://schemas.mathworks.com/simulink/2016/relationships/reqData',...
                    ['ReqImage',num2str(i)]);

                    saveOptions.writerHandle.writePartFromFile(p,fpath);
                end
            end
        end

        function r=removeFile(this,packagePath)
            r=slreq.opc.opc('delete',this.filepath,packagePath);
        end

        function removeLinkMetadata(this)
            slreq.opc.opc('delete',this.filepath,this.SLREQS_LINK_METADATA_SHORT_NAME);
        end

        function out=hasLinkMetadata(this)
            out=any(ismember(this.getFileList(),this.SLREQS_LINK_METADATA_SHORT_NAME));
        end

        function out=isValidPackage(this)





            out=slreq.opc.opc('exists',this.filepath,this.SLREQS_PART_NAME);
        end

        function files=getFileList(this)
            files=slreq.opc.opc('list',this.filepath);
        end
    end

    methods(Static,Access=private)

        function out=ensureRootPaths(in)
            out=cell(length(in),1);
            for i=1:length(in)
                out{i}=slreq.opc.Package.ensureRootPath(in{i});
            end
        end


        function out=ensureRootPath(in)

            if in(1)=='/'
                out=in;
            else
                out=['/',in];
            end
        end

        function ensureDestPathIfEmbeddedLink(destFilePath)





            if endsWith(destFilePath,[filesep,'_linkset.slmx'])
                destDir=fileparts(destFilePath);
                if~isfolder(destDir)
                    unpakcedLocation=fileparts(destDir);
                    if isfolder(unpakcedLocation)
                        mkdir(destDir);
                    end



                end
            end
        end
    end

end


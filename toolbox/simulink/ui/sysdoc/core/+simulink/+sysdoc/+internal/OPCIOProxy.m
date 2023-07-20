

classdef OPCIOProxy<handle
    properties(Constant,Hidden)
        BINDING_FILE_NAME='bindings.txt';
        LAST_BIND_FILE_NAME='lastbindings.txt';


        RTC_EXT='.json';
        RTC_BACK_EXT='.json~';
        DOC_EXTENSION='_doc.mldatx';
        DOC_EXTENSION_TEMP='_doc.mldatx~';
        RELATION_FILE_NAME_NO_EXT='relationships';
        RELATION_FILE_RELATIVE_PATH='/relationships.txt';
        VERSION_FILE='/version.txt';
        MODEL_INFO_FILE='/modelinfo.txt';

        CORE_PROPERTIES_RELATIVE_PATH='/coreProperties.xml';
        MW_CORE_PROPERTIES_RELATIVE_PATH='/mwcoreProperties.xml';


        CURRENT_VERSION='1.0.0';
    end

    properties(Access=protected)

        m_tempFolderPath=[];
        m_zipFilePath=[];

        m_opcBoundModelName=[];
        m_opcBoundModelVersion=[];
    end

    methods(Access=public)
        function obj=OPCIOProxy(zipFilePath)
            import simulink.sysdoc.internal.SysDocUtil;
            import simulink.sysdoc.internal.OPCIOProxy;

            obj.m_tempFolderPath=tempname;
            obj.m_zipFilePath=zipFilePath;
        end




        function success=new(this,fileName)
            success=false;
            this.setZipFilePath(fileName);
            try
                this.reset();
            catch
                warning(['OPCIOProxy::new - '...
                ,message('simulink_ui:sysdoc:resources:CannotClearFolder',fileName).getString()]);
            end
            if~checkPermission(this.getZipFilePath())||~this.createTemporaryFolder()
                return;
            end
            success=true;
        end

        function success=readFromZipFile(this,path)
            success=false;
            if~exist(path,'file')
                return;
            end
            this.reset();
            if~this.createTemporaryFolder()
                return;
            end

            try
                unzipDoc(path,this.getTempFolderPath());
            catch e
                if~strcmp(e.identifier,'MATLAB:io:archive:unzip:invalidZipFile')
                    warning('Debug assert: unexpected error during unzipping.');
                end
                return;
            end
            success=true;
        end

        function writeToZipFile(this,path)
            if exist(path,'file')

                delete(path);
            end


            repackageTempFolder(this.getTempFolderPath(),path);
        end

        function success=open(this)
            success=false;
            if~this.readFromZipFile(this.getZipFilePath())
                return;
            end
            if~this.isCurrentFileValid()
                return;
            end
            success=true;
        end

        function save(this)
            if~isempty(this.m_opcBoundModelName)
                this.writeModelInfo();
            end
            repackageTempFolder(this.getTempFolderPath(),this.getZipFilePath());
        end

        function reset(this)
            if exist(this.getTempFolderPath(),'dir')
                rmdir(this.getTempFolderPath(),'s');
            end
        end




        function writeToRTCFile(this,fileName,content)
            writeToFile(this.getRTCFilePath(fileName),content);
        end

        function content=readFromRTCFile(this,fileName)
            content=readFromFile(this.getRTCFilePath(fileName));
        end

        function deleteRTCFile(this,fileName)
            deleteFile(this.getRTCFilePath(fileName));
        end

        function exists=fileExists(this,fileName)
            exists=exist(this.getRTCFilePath(fileName),'file');
        end




        function bindingMap=populateBindings(this,filename)
            bindingMap=[];
            textFile=[this.getTempFolderPath(),'/',filename];
            if~exist(textFile,'file')


                return;
            end

            bindingMap=containers.Map;
            fileID=fopen(textFile,'r');
            file=textscan(fileID,'%s','Delimiter','\n');
            fclose(fileID);

            strings=file{1};
            numOfValues=3;
            if~isempty(strings)
                i=numOfValues;
                numStrings=size(strings);
                numStrings=numStrings(1);
                while i<=numStrings
                    type=str2double(strings(i-1));
                    bindingMap(char(strings(i-2)))={type,char(strings(i))};
                    i=i+numOfValues;
                end
            end
        end


        function bindingMap=populateCurrentBindings(this)
            import simulink.sysdoc.internal.OPCIOProxy;
            bindingMap=this.populateBindings(OPCIOProxy.BINDING_FILE_NAME);
        end


        function bindingMap=populateLastBindings(this)
            import simulink.sysdoc.internal.OPCIOProxy;
            bindingMap=this.populateBindings(OPCIOProxy.LAST_BIND_FILE_NAME);
        end


        function exportBindings(this,filename,bindingMap)
            textFile=[this.getTempFolderPath(),'/',filename];
            fileID=fopen(textFile,'w');
            keySet=keys(bindingMap);
            for key=keySet
                sKey=key{1};
                value=bindingMap(sKey);
                fprintf(fileID,'%s\n',sKey);
                fprintf(fileID,'%s\n',num2str(value{1}));
                fprintf(fileID,'%s\n',value{2});
            end
            fclose(fileID);
        end


        function exportCurrentBindings(this,bindingMap)
            import simulink.sysdoc.internal.OPCIOProxy;
            this.exportBindings(OPCIOProxy.BINDING_FILE_NAME,bindingMap);
        end


        function exportLastBindings(this,bindingMap)
            import simulink.sysdoc.internal.OPCIOProxy;
            this.exportBindings(OPCIOProxy.LAST_BIND_FILE_NAME,bindingMap);
        end


        function readModelInfo(this)
            import simulink.sysdoc.internal.OPCIOProxy;
            textFile=[this.getTempFolderPath(),OPCIOProxy.MODEL_INFO_FILE];
            if~exist(textFile,'file')


                return;
            end

            fileID=fopen(textFile,'r');
            if fileID<0
                return;
            end
            file=textscan(fileID,'%s','Delimiter','\n');
            fclose(fileID);

            strings=file{1};
            if length(strings)<2
                return;
            end
            this.m_opcBoundModelName=strings{1};
            this.m_opcBoundModelVersion=strings{2};
        end

        function writeModelInfo(this)
            if isempty(this.m_opcBoundModelName)
                return;
            end
            if bdIsLoaded(this.m_opcBoundModelName)
                this.m_opcBoundModelVersion=get_param(this.m_opcBoundModelName,'ModelVersion');
            end
            import simulink.sysdoc.internal.OPCIOProxy;
            writeToFile([this.getTempFolderPath(),OPCIOProxy.MODEL_INFO_FILE],...
            sprintf('%s\n%s',this.m_opcBoundModelName,this.m_opcBoundModelVersion));
        end




        function modelName=getModelName(this)
            modelName=this.m_opcBoundModelName;
        end

        function modelVersion=getModelVersion(this)
            modelVersion=this.m_opcBoundModelVersion;
        end


        function setModelName(this,modelName)
            this.m_opcBoundModelName=modelName;
        end

        function isMatch=isModelAndVersionMatch(this,modelName)
            assert(bdIsLoaded(modelName));
            isMatch=strcmp(this.m_opcBoundModelName,modelName);
        end
    end


    methods(Access={?simulink.sysdoc.internal.MixedMapRouter,...
        ?sysdoc.NotesTester,...
        ?SysDocTestInterface})




        function setZipFilePath(this,zipFilePath)
            this.m_zipFilePath=zipFilePath;
        end

        function path=getZipFilePath(this)
            path=this.m_zipFilePath;
        end

        function path=getTempFolderPath(this)
            path=this.m_tempFolderPath;
        end

        function setTempFolderPath(this,tempFolderPath)
            this.m_tempFolderPath=tempFolderPath;
        end





        function clearAll(this)
            if exist(this.getZipFilePath(),'file')
                delete(this.getZipFilePath());
            end

            if exist(this.getTempFolderPath(),'dir')
                rmdir(this.getTempFolderPath(),'s');
            end
        end


    end

    methods(Access=protected)
        function filepath=getRTCFilePath(this,fileName)
            import simulink.sysdoc.internal.OPCIOProxy;
            filepath=[this.m_tempFolderPath,'/',fileName,OPCIOProxy.RTC_EXT];
        end

        function success=createTemporaryFolder(this)
            [success,msg,msgID]=mkdir(this.getTempFolderPath());
            if~success
                error(message('simulink_ui:sysdoc:resources:CannotCreateTempFolder',this.getTempFolderPath()));
            end
        end

        function valid=isCurrentFileValid(this)
            import simulink.sysdoc.internal.OPCIOProxy;
            versionFile=[this.getTempFolderPath(),OPCIOProxy.VERSION_FILE];
            bindingFile=[this.getTempFolderPath(),OPCIOProxy.RELATION_FILE_RELATIVE_PATH];
            valid=exist(versionFile,'file')&&exist(bindingFile,'file');
        end
    end

    methods(Static)
    end

end








function writeToFile(filePath,content)
    if isempty(filePath)
        return;
    end
    try
        if exist(filePath,'file')
            delete(filePath);
        end


        [fileID,errmsg]=fopen(filePath,'w','n','utf-8');
        if isempty(errmsg)
            c=onCleanup(@()(fclose(fileID)));
            fprintf(fileID,'%s',content);
        end
    catch
        warning(message('simulink_ui:sysdoc:resources:FailedToWriteFile',filePath));
    end
end

function content=readFromFile(filePath)
    content=[];
    if~exist(filePath,'file')
        return;
    end
    try
        [fileID,errmsg]=fopen(filePath,'r','n','utf-8');
        if isempty(errmsg)
            c=onCleanup(@()(fclose(fileID)));
            content=fread(fileID,'*char')';
        end
    catch
        warning(message('simulink_ui:sysdoc:resources:FailedToReadFile',filePath));
    end
end

function deleteFile(filePath)
    if isempty(filePath)
        return;
    end

    if exist(filePath,'file')
        delete(filePath);
    end
end

function cleanUpForPermissionCheck(needClose,fid,needDelete,filePath)
    if needClose
        fclose(fid);
    end
    if~needDelete
        return;
    end
    if exist(filePath,'file')
        delete(filePath);
    end
end

function hasPermission=checkPermission(filePath)



    hasPermission=false;
    needDelete=~exist(filePath,'file');
    [fid,errmsg]=fopen(filePath,'w');
    if~isempty(errmsg)
        error(message('simulink_ui:sysdoc:resources:CannotWriteFile',filePath));
    end
    fclose(fid);
    if needDelete&&exist(filePath,'file')
        delete(filePath);
    end
    hasPermission=true;
end

function repackageTempFolder(tempFolderPath,dstSMLFile)
    if~exist(tempFolderPath,'dir')
        return;
    end

    if~checkPermission(dstSMLFile)
        return;
    end

    import simulink.sysdoc.internal.OPCIOProxy;
    import simulink.sysdoc.internal.SysDocUtil;


    writeToFile([tempFolderPath,OPCIOProxy.VERSION_FILE],OPCIOProxy.CURRENT_VERSION);


    listing=dir(tempFolderPath);

    persistent sCoreProps;
    persistent sMwCoreProps;
    if isempty(sMwCoreProps)
        content=fileread([SysDocUtil.getContentPath(),OPCIOProxy.CORE_PROPERTIES_RELATIVE_PATH]);
        sCoreProps=replace(content,...
        {'{0}','{1}'},...
        {message('simulink_ui:sysdoc:resources:SysDocOPCDescription').getString(),...
        message('simulink_ui:sysdoc:resources:SysDocOPCDescription').getString()});
        content=fileread([SysDocUtil.getContentPath(),OPCIOProxy.MW_CORE_PROPERTIES_RELATIVE_PATH]);
        sMwCoreProps=replace(content,...
        {'{0}','{1}'},...
        {message('simulink_ui:sysdoc:resources:SysDocOPCType').getString(),...
        ['R',version('-release')]});
    end


    metadataPath=[tempFolderPath,'/metadata'];
    if~exist(metadataPath,'dir')
        try
            mkdir(metadataPath);
        catch

        end
    end

    j=1;
    metaFilePath=['/metadata',OPCIOProxy.CORE_PROPERTIES_RELATIVE_PATH];
    rFile=[tempFolderPath,metaFilePath];
    writeToFile(rFile,sCoreProps);
    parts(j)=mlreportgen.dom.OPCPart(metaFilePath,rFile);
    parts(j).ContentType='application/vnd.openxmlformats-package.core-properties+xml';
    parts(j).RelationshipType='http://schemas.openxmlformats.org/package/2006/relationships/metadata/core-properties';
    parts(j).RelationshipId=['rId',int2str(j)];
    j=j+1;


    metaFilePath=['/metadata',OPCIOProxy.MW_CORE_PROPERTIES_RELATIVE_PATH];
    rFile=[tempFolderPath,metaFilePath];
    writeToFile(rFile,sMwCoreProps);
    parts(j)=mlreportgen.dom.OPCPart(metaFilePath,rFile);
    parts(j).ContentType='application/vnd.mathworks.package.coreProperties+xml';
    parts(j).RelationshipType='http://schemas.mathworks.com/package/2012/relationships/coreProperties';
    parts(j).RelationshipId=['rId',int2str(j)];
    j=j+1;


    rFile=[tempFolderPath,OPCIOProxy.RELATION_FILE_RELATIVE_PATH];
    fclose(fopen(rFile,'w'));
    parts(j)=mlreportgen.dom.OPCPart(OPCIOProxy.RELATION_FILE_RELATIVE_PATH,rFile);
    parts(j).RelationshipId=['rId',int2str(j)];

    j=j+1;
    for i=3:size(listing)
        [pathstr,name,ext]=fileparts(listing(i).name);
        if strcmp(name,'relationships')==false
            if strcmp(ext,'.html')||strcmp(ext,'.json')||strcmp(ext,'.m')||strcmp(ext,'.txt')
                path=[listing(i).folder,'/',listing(i).name];
                zippath=['/',listing(i).name];

                parts(j)=mlreportgen.dom.OPCPart(zippath,path);
                parts(j).RelatedPart=OPCIOProxy.RELATION_FILE_RELATIVE_PATH;
                parts(j).RelationshipType='http://schemas.mathworks.com/sysdoc/relationships/main';
                parts(j).RelationshipId=['rId',int2str(j)];

                if~isempty(ext)&&~strcmp(ext,'.html')&&~strcmp(ext,'.txt')
                    parts(j).ContentType=[ext,'/',ext(2:end)];
                end
                j=j+1;
            end
        end
    end

    mlreportgen.dom.Document.createPackage(dstSMLFile);
    mlreportgen.dom.Document.addPackage(dstSMLFile,parts);
end


function unzippedFiles=unzipDoc(templateFilename,varargin)
    import simulink.sysdoc.internal.SysDocUtil;



























    narginchk(1,2);
    nargoutchk(0,1);


    CT_XML='[Content_Types].xml';
    RELS_EXT='.rels';


    [~,archiveFilename,archiveExt]=fileparts(templateFilename);

    if isempty(archiveExt)
        zipFilename=[archiveFilename,'.htmtx'];
    else
        zipFilename=templateFilename;
    end

    if numel(varargin)==0

        files=unzip(zipFilename,archiveFilename);
        zipFolder=archiveFilename;
    else
        files=unzip(zipFilename,varargin{:});
        zipFolder=varargin{1};
    end

    unzippedFiles={};



    dirList={};

    for i=1:length(files)
        [archivePath,archiveName,archiveExt]=fileparts(files{i});
        filename=[archiveName,archiveExt];
        if strcmp(CT_XML,filename)||strcmp(RELS_EXT,archiveExt)
            delete(files{i});
            dirList{end+1}=archivePath;%#ok<AGROW>
        else
            unzippedFiles{end+1}=files{i};%#ok<AGROW>
        end
    end


    for i=1:length(dirList)
        filename=dirList{i};
        [fileIsDir,dirContents]=SysDocUtil.isDirectory(filename);
        if fileIsDir&&isempty(dirContents)
            rmdir(filename);
        end
    end
end

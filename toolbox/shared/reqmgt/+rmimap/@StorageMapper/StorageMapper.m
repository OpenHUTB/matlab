classdef(Sealed=true)StorageMapper<handle

    properties
        storageMap;
        mapfilename;
    end


    methods(Access='private')

        function obj=StorageMapper()
            obj.mapfilename=rmimap.StorageMapper.storageMapFile();
            if exist(obj.mapfilename,'file')==2
                obj.storageMap=rmimap.StorageMapper.loadFromFile(obj.mapfilename);
            else
                obj.storageMap={'RmiSrc','RmiData',date()};
            end
        end


        function oldMap=clear(this)
            oldMap=this.storageMap;
            this.storageMap={'RmiSrc','RmiData',date()};
            storageMap=this.storageMap;%#ok<*NASGU>
            save(this.mapfilename,'storageMap');
        end

    end


    methods(Access='private',Static=true)
        function extension=getLinkfileExtension()

            extension='.slmx';
        end
    end


    methods
        function store(this,newMap)
            if~iscell(newMap)
                error(message('Slvnv:reqmgt:StorageMapper:InvalidNewMapCellArrayNeeded'));
            elseif size(newMap,2)~=3
                error(message('Slvnv:reqmgt:StorageMapper:InvalidNewMapColumnNeeded'));
            elseif~strcmp(newMap{end,1},'RmiSrc')||~strcmp(newMap{end,2},'RmiData')
                newMap=[newMap;{'RmiSrc','RmiData',date()}];
            end
            this.storageMap=newMap;
            storageMap=this.storageMap;%#ok<PROPLC>
            save(this.mapfilename,'storageMap');
        end


        function set(this,srcName,storageName)
            if ispc
                srcMatch=strcmpi(this.storageMap(:,1),srcName);
            else
                srcMatch=strcmp(this.storageMap(:,1),srcName);
            end
            if any(srcMatch)
                if ispc
                    storageMatch=strcmpi(this.storageMap(:,2),storageName);
                else
                    storageMatch=strcmp(this.storageMap(:,2),storageName);
                end
                if any(storageMatch)
                    match=srcMatch&storageMatch;
                    if any(match)
                        this.storageMap(match,:)=[];
                    end
                end
            end
            update={srcName,storageName,date()};
            this.storageMap=[update;this.storageMap];
            storageMap=this.storageMap;%#ok<PROPLC>
            save(this.mapfilename,'storageMap');
        end


        function out=get(this,srcName)
            if ispc
                matches=find(strcmpi(this.storageMap(:,1),srcName));
            else
                matches=find(strcmp(this.storageMap(:,1),srcName));
            end
            if isempty(matches)
                out={};
            else
                out=this.storageMap(matches,2);
            end
        end


        function forget(this,model,all)
            if~ischar(model)
                try
                    model=get_param(model,'FileName');
                catch Mex
                    error(message('Slvnv:reqmgt:StorageMapper:CannotResolve',model));
                end
            elseif~exist(model,'file')
                warning(message('Slvnv:reqmgt:StorageMapper:FileNotExist',model));
            end
            if ispc
                matches=find(strcmpi(this.storageMap(:,1),model));
            else
                matches=find(strcmp(this.storageMap(:,1),model));
            end
            if all
                this.storageMap(matches,:)=[];
            elseif~isempty(matches)
                this.storageMap(matches(1),:)=[];
            end
            storageMap=this.storageMap;%#ok<PROPLC>
            save(this.mapfilename,'storageMap');
        end

        function[storageName,usingDefault]=getStorageForModel(this,model)
            modelH=get_param(model,'Handle');
            [storageName,usingDefault]=this.getStorageFor(modelH);
        end


        function[storageName,usingDefault]=getStorageFor(this,srcPath,asVersion)
            if nargin<3
                asVersion='';
            end

            if~ischar(srcPath)
                srcPath=get_param(srcPath,'FileName');
                if isempty(srcPath)
                    error(message('Slvnv:rmidata:StorageMapper:unsavedModel'));
                end
            end

            storageNames=this.get(srcPath);
            if isempty(storageNames)
                storageName=this.getDefaultStorageName(srcPath,asVersion);
                usingDefault=true;
            else
                storageName=storageNames{1};
                usingDefault=false;
            end
        end


        function sourceFile=getSourceFor(this,linkSetPath)
            if ispc
                matches=find(strcmpi(this.storageMap(:,2),linkSetPath));
            else
                matches=find(strcmp(this.storageMap(:,2),linkSetPath));
            end
            if isempty(matches)
                sourceFile={};
            else
                sourceFile=this.storageMap(matches,1);
            end
        end


        function result=promptForReqFile(this,src,shouldExist)
            [storage,wasDefault]=this.getStorageFor(src);
            if shouldExist
                [filename,pathname]=uigetfile({['*',this.getLinkfileExtension()],'RMI data files'},...
                'Select a file to load RMI data',storage);
            else
                [filename,pathname]=uiputfile({['*',this.getLinkfileExtension()],'RMI data files'},...
                'Select a file to store RMI data',storage);
            end
            if~ischar(filename)
                result='';
            else
                result=fullfile(pathname,filename);
                if strcmp(storage,result)

                else

                    if~ischar(src)
                        src=get_param(src,'FileName');
                    end
                    if~strcmp(result,this.getDefaultStorageName(src))

                        this.set(src,result);
                    elseif~wasDefault

                        this.forget(src,true);
                    end
                end
            end
        end
    end


    methods(Static=true)

        function singleObj=getInstance
            persistent localStorageMap;
            if isempty(localStorageMap)||~isvalid(localStorageMap)
                localStorageMap=rmimap.StorageMapper();
            end
            singleObj=localStorageMap;
        end


        function linkPath=defaultLinkPath(artPath,artBase,artExt,asVersion)
            if nargin<4
                asVersion='';
            end

            if isempty(asVersion)&&reqmgt('rmiFeature','IncArtExtInLinkFile')
                switch(artExt)
                case '.slx'
                    linkBase=[artBase,'~mdl'];
                case '.slmx'
                    linkBase=artBase;
                otherwise
                    linkBase=[artBase,'~',artExt(2:end)];
                end
            else
                switch(artExt)
                case{'.slx','.slreqx','.mdl','.m','.slmx'}
                    linkBase=artBase;
                case '.sldd'
                    if mdlPathConflict(artPath,artBase)
                        linkBase=[artBase,'_dd'];
                    else
                        linkBase=artBase;
                    end
                case '.mldatx'
                    if mdlPathConflict(artPath,artBase)
                        linkBase=[artBase,'_st'];
                    else
                        linkBase=artBase;
                    end
                otherwise
                    linkBase=[artBase,'~',artExt(2:end)];
                end
            end

            linkPath=fullfile(artPath,[linkBase,'.slmx']);

            function out=mdlPathConflict(artPath,artBase)
                basePath=fullfile(artPath,artBase);
                out=(exist([basePath,'.slx'],'file')==4)||(exist([basePath,'.mdl'],'file')==4);
            end
        end


        function linkPaths=legacyLinkPaths(artPath,artBase,artExt)
            if reqmgt('rmiFeature','IncArtExtInLinkFile')
                switch(artExt)
                case{'.slx','.slreqx','.mdl','.m'}
                    linkPaths={fullfile(artPath,[artBase,'.slmx'])};
                case '.sldd'
                    linkPaths={fullfile(artPath,[artBase,'.slmx']),...
                    fullfile(artPath,[artBase,'_dd.slmx'])};
                case '.mldatx'
                    linkPaths={fullfile(artPath,[artBase,'.slmx']),...
                    fullfile(artPath,[artBase,'_st.slmx'])};
                otherwise
                    linkPaths={};
                end
            else
                linkPaths={};
            end
        end


        function reqPath=legacyReqPath(artPath,artBase,artExt)
            reqPath=fullfile(artPath,[artBase,'.req']);
        end


        function defaultPath=getDefaultStorageName(srcPath,asVersion)
            persistent defaults

            if nargin<2
                asVersion='';
            end

            if strcmp(srcPath,'clear')

                if~isempty(defaults)
                    defaultPath=defaults.Count;
                    defaults=[];
                else
                    defaultPath=0;
                end
                return;
            end

            if isempty(defaults)

                defaults=containers.Map('KeyType','char','ValueType','char');
                defaults('_SRC_PATH_')='_REQ_PATH_';
            end

            if isKey(defaults,srcPath)
                defaultPath=defaults(srcPath);
            else
                [srcLocation,srcFile,srcExt]=fileparts(srcPath);
                defaultPath=rmimap.StorageMapper.defaultLinkPath(srcLocation,srcFile,srcExt,asVersion);

                if(exist(defaultPath,'file')~=2)


                    legacyPaths=rmimap.StorageMapper.legacyLinkPaths(srcLocation,srcFile,srcExt);
                    for idx=1:numel(legacyPaths)
                        if(exist(legacyPaths{idx},'file')==2)
                            defaultPath=legacyPaths{idx};
                        end
                    end
                end
                defaults(srcPath)=defaultPath;
            end
        end


        function clearAll()
            rmimap.StorageMapper.getInstance.clear();
        end


        function cellArray=listAll()
            singletonObj=rmimap.StorageMapper.getInstance();
            cellArray=singletonObj.storageMap;
            totalRows=size(cellArray,1);
            for i=1:totalRows
                if i<totalRows
                    fprintf('%s ->\n\t%s\n',cellArray{i,1},cellArray{i,2});
                else
                    cellArray(i,:)=[];
                end
            end
        end

    end


    methods(Static=true,Access='private')

        function out=storageMapFile()
            out=fullfile(prefdir,'rmi_storage.mat');
        end


        function loadedMap=loadFromFile(filename)

            fileinfo=dir(filename);
            if fileinfo.datenum<datenum('01-May-2011')
                rmimap.StorageMapper.removeDefaultMappings(filename);
            end

            loaded=load(filename);
            loadedMap=loaded.storageMap;
        end


        function removeDefaultMappings(filename)
            loaded=load(filename);
            loadedMap=loaded.storageMap;
            storageMap=cell(0,3);%#ok<*PROP>
            for i=1:size(loadedMap,1)
                row=loadedMap(i,:);
                if~strcmp(row{1,1},strrep(row{1,2},'.req','.mdl'))
                    storageMap=[loadedMap(i,:);storageMap];%#ok<AGROW>
                end
            end
            save(filename,'storageMap');
        end

    end
end


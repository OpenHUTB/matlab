function filename=saveSession(this,varargin)




    thumbnailURL='';
    if nargin>3
        thumbnailURL=varargin{3};
    end

    fullFileName='';
    if nargin>2
        fullFileName=varargin{2};
    end

    bSaveAs=false;
    if nargin>1
        bSaveAs=varargin{1};
    end
    appName=this.AppName;


    originalFilename=this.FileName;
    originalPathname=this.PathName;
    originalDirtyFlag=this.Dirty;

    if~isempty(fullFileName)
        if~bSaveAs


            pathname=this.PathName;
            [~,filename,extension]=fileparts(fullFileName);
            if isempty(extension)
                extension='.mldatx';
            end
            filename=[filename,extension];
        else
            [pathname,filename,extension]=fileparts(fullFileName);
            if isempty(extension)
                extension='.mldatx';
            end
            filename=[filename,extension];
        end
        [~,~,extension]=fileparts(filename);
        if~isempty(extension)&&~strcmp(extension,'.mldatx')&&~strcmp(extension,'.mat')




            filename=[filename,'.mldatx'];

            titleString=getString(message('SDI:sdi:InvalidExtensionTitle'));
            msgString=getString(message('SDI:sdi:SessionSaveInvalidExtension',extension,filename));
            okStr=getString(message('SDI:sdi:OKShortcut'));

            Simulink.sdi.internal.controllers.SessionSaveLoad.displayMsgBox(...
            appName,...
            titleString,...
            msgString,...
            {okStr},...
            0,...
            -1,...
            []);
        end
        if bSaveAs||~strcmpi(filename,this.FileName)



            this.cacheSessionInfo(filename,pathname);
            this.updateGUITitle();
        end
    elseif bSaveAs||isempty(this.PathName)||isempty(this.FileName)
        MATFilter=getString(message('SDI:sdi:MATFilter'));
        MLDATXFilter=getString(message('SDI:sdi:MLDATXFilter'));
        MATDesc=getString(message('SDI:sdi:MATDesc'));
        MLDATXDesc=getString(message('SDI:sdi:MLDATXDesc'));
        saveTitle=getString(message('SDI:sdi:SessionSaveTitle'));
        [filename,pathname]=...
        uiputfile({MLDATXFilter,MLDATXDesc;...
        MATFilter,MATDesc;...
        '*.*',getString(message('SDI:sdi:AllFileTypesDesc'))},saveTitle,this.DefaultName);

        if isequal(filename,0)||isequal(pathname,0)
            filename='';
            return;
        end
        [~,filename,extension]=fileparts(filename);
        if isempty(extension)
            extension='.mldatx';
        end
        filename=[filename,extension];
        this.cacheSessionInfo(filename,pathname);
    else
        filename=this.FileName;
    end



    [~,~,pathExt]=fileparts(this.PathName);
    if isempty(pathExt)
        fullFileName=fullfile(this.PathName,this.FileName);
    else
        fullFileName=this.PathName;
    end
    wasCancelled=[];

    this.OriginalFileName=originalFilename;
    this.OriginalPathName=originalPathname;
    this.OriginalDirtyFlag=originalDirtyFlag;
    try
        wasCancelled=this.Engine.save(fullFileName,thumbnailURL,false,'appName',appName);
    catch me
        this.cacheSessionInfo('','');
        okStr=getString(message('SDI:sdi:OKShortcut'));

        Simulink.sdi.internal.controllers.SessionSaveLoad.displayMsgBox(...
        appName,...
        Simulink.sdi.internal.StringDict.mgSaveError,...
        me.message,...
        {okStr},...
        0,...
        -1,...
        []);

        if strcmpi(appName,'siganalyzer')
            filename='';
        end

        this.FileName='';
        this.ActionInProgress=false;
    end
    if wasCancelled
        this.cacheSessionInfo(originalFilename,originalPathname,originalDirtyFlag);
    elseif strcmp(appName,'siganalyzer')&&~isempty(this.FileName)
        [~,~,extension]=fileparts(this.FileName);
        isMldatx=~isempty(extension)&&strcmp(extension,'.mldatx');

        if~isMldatx&&~this.Dirty&&~this.ActionInProgress


            fullFileName=fullfile(this.PathName,this.FileName);
            m_session=matfile(fullFileName,'Writable',true);
            mlss_filename=Simulink.sdi.Instance.getSetSAUtils().getStorageLSSFilename();

            if exist(mlss_filename,'file')==2

                MLSS=load(mlss_filename);
                m_session.MLSS=MLSS;
            end
        end
    end



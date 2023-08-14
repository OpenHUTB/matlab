function loadSession(this,varargin)






    appName=this.AppName;


    if nargin>1&&~isempty(varargin{1})
        fullFileName=varargin{1};
        [pathname,shortFilename,extension]=fileparts(fullFileName);
        if isempty(extension)
            filename=[shortFilename,'.mldatx'];
        else
            filename=[shortFilename,extension];
        end
    else
        MATFilter=getString(message('SDI:sdi:MATFilter'));
        MATDesc=getString(message('SDI:sdi:MATDesc'));
        MATLoadTitle=getString(message('SDI:sdi:MATLoadTitle'));
        MLDATXFilter=getString(message('SDI:sdi:MLDATXFilter'));
        MLDATXDesc=getString(message('SDI:sdi:MLDATXDesc'));
        [filename,pathname]=...
        uigetfile({sprintf('%s;%s',MLDATXFilter,MATFilter),...
        [getString(message('SDI:sdi:AllSDIFileTypesDesc')),sprintf(' (%s, %s)',MLDATXFilter,MATFilter)];...
        MLDATXFilter,MLDATXDesc;...
        MATFilter,MATDesc;
        '*.*',sprintf('%s (*.*)',getString(message('SDI:sdi:AllFileTypesDesc')))},MATLoadTitle);

        if isequal(filename,0)||isequal(pathname,0)
            return
        end
        fullFileName=fullfile(pathname,filename);
        [pathname,shortFilename,extension]=fileparts(fullFileName);
    end






    isMldatx=~isempty(extension)&&strcmp(extension,'.mldatx');
    if isMldatx
        setupData=struct;
        setupData.dataIO='begin';
        setupData.Msg=getString(message('SDI:sdi:InitializingProgress'));
        setupData.isMldatx=isMldatx;
        setupData.filename=shortFilename;
        setupData.appName=appName;
        message.publish('/sdi2/progressUpdate',setupData);
    end



    bIsSessionFile=Simulink.sdi.isSessionFile(fullFileName);
    if~bIsSessionFile
        titleStr=getString(message('SDI:sdi:InvalidMLDATXSessionFileTitle'));
        if strcmpi(appName,'siganalyzer')
            msgStr=getString(message('SDI:sigAnalyzer:InvalidMLDATXSessionFile',filename));
        else
            msgStr=getString(message('SDI:sdi:InvalidMLDATXSessionFile',filename));
        end
        okStr=getString(message('SDI:sdi:OKShortcut'));

        Simulink.sdi.internal.controllers.SessionSaveLoad.displayMsgBox(...
        appName,...
        titleStr,...
        msgStr,...
        {okStr},...
        0,...
        -1,...
        []);

        setupData=struct;
        setupData.dataIO='error';
        setupData.Msg=getString(message('SDI:sdi:mgError'));
        setupData.isMldatx=isMldatx;
        setupData.appName=appName;
        message.publish('/sdi2/progressUpdate',setupData);

        return
    end


    initRunCount=length(this.Engine.getAllRunIDs(appName));
    if strcmpi(appName,'siganalyzer')

        loadSessionAppendConfirm(this,filename,pathname,fullFileName,1,varargin{:});
    elseif length(varargin)>1
        if ischar(varargin{2})
            if strcmpi(varargin{2},'append')
                varargin{2}=0;
            else
                varargin{2}=1;
            end
        end
        loadSessionAppendConfirm(this,filename,pathname,fullFileName,varargin{2},varargin{:});
    elseif initRunCount>0&&bIsSessionFile
        msgStr=getString(message('SDI:sdi:AppendOrClearHTML'));
        titleStr=getString(message('SDI:sdi:AppendOrClearTitle'));
        appendStr=getString(message('SDI:sdi:mgAppendShortcut'));
        clearStr=getString(message('SDI:sdi:mgClearShortcut'));
        cancelStr=getString(message('SDI:sdi:CancelShortcut'));


        Simulink.sdi.internal.controllers.SessionSaveLoad.displayMsgBox(...
        appName,...
        titleStr,...
        msgStr,...
        {appendStr,clearStr,cancelStr},...
        2,...
        2,...
        @(x)this.loadSessionAppendConfirm(filename,pathname,fullFileName,x,varargin{:}));

    else
        loadSessionAppendConfirm(this,filename,pathname,fullFileName,0,varargin{:});
    end
end

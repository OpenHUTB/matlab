function loadSessionAppendConfirm(this,filename,pathname,fullFileName,appendOrClear,varargin)


    appName=this.AppName;
    initRunCount=this.Engine.getRunCount(appName);
    bIsSessionFile=Simulink.sdi.isSessionFile(fullFileName);
    isAppending=false;
    if initRunCount>0&&bIsSessionFile
        validSDIMatFile=...
        Simulink.sdi.internal.Util.getSDIMatFileVersion(fullFileName)>0;

        switch appendOrClear
        case 0
            isAppending=true;


            comparisonRunIDs=this.Engine.sigRepository.getAllRunIDs('SDIComparison');
            comparisonSigIDs=[];
            for compareIdx=1:length(comparisonRunIDs)
                comparisonSigIDs=[comparisonSigIDs...
                ,this.Engine.sigRepository.getAllSignalIDs(comparisonRunIDs(compareIdx))];%#ok<AGROW>
            end
            this.Engine.deleteRunsAndSignals([comparisonRunIDs;comparisonSigIDs],...
            'SDIComparison',true,...
            'appName',this.AppName);
        case 1
            if validSDIMatFile
                try
                    Simulink.sdi.clear(true);
                catch me
                    okStr=DAStudio.message('SDI:sdi:OKShortcut');

                    Simulink.sdi.internal.controllers.SessionSaveLoad.displayMsgBox(...
                    appName,...
                    Simulink.sdi.internal.StringDict.mgError,...
                    me.message,...
                    {okStr},...
                    0,...
                    -1,...
                    []);
                    return
                end
            end

        otherwise
            assert(appendOrClear==2);

            message.publish('/sdi2/progressUpdate',struct('dataIO','end','appName',appName));
            return;
        end
    end


    [~,shortFilename,extension]=fileparts(fullFileName);
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
    dirtyBit=(appendOrClear==0&&initRunCount~=0);
    try
        [isValidMATFile,wasCancelled]=this.Engine.load(fullFileName,false,filename,pathname,dirtyBit,'appName',appName);
    catch me %#ok<NASGU>
        isValidMATFile=false;
    end
    if isAppending&&bIsSessionFile
        dirty=true;
        this.Engine.dirty=dirty;
        this.setDirty(dirty,true);
    end


    if~isValidMATFile
        if strcmp(appName,'siganalyzer')
            if isMldatx
                msgStr=DAStudio.message('SDI:sigAnalyzer:mgMLDATXErrorSigApp');
            else
                msgStr=DAStudio.message('SDI:sigAnalyzer:mgMATErrorSigApp');
            end
            titleStr=DAStudio.message('SDI:sigAnalyzer:mgMATErrorTitleSigApp');
            okStr=DAStudio.message('SDI:sdi:OKShortcut');

            Simulink.sdi.internal.controllers.SessionSaveLoad.displayMsgBox(...
            appName,...
            titleStr,...
            msgStr,...
            {okStr},...
            0,...
            -1,...
            []);
            return;
        elseif length(varargin)>2
            this.importMATfileDuringLoad(fullFileName,isAppending,varargin{3});
        else
            msgStr=DAStudio.message('SDI:sdi:mgMATError');
            titleStr=DAStudio.message('SDI:sdi:AppendOrClearTitle');
            yesStr=DAStudio.message('SDI:sdi:YesShortcut');
            noStr=DAStudio.message('SDI:sdi:NoShortcut');

            Simulink.sdi.internal.controllers.SessionSaveLoad.displayMsgBox(...
            appName,...
            titleStr,...
            msgStr,...
            {yesStr,noStr},...
            0,...
            1,...
            @(x)this.importMATfileDuringLoad(fullFileName,isAppending,x));
        end
    else
        if wasCancelled


            return;
        end
        if~strcmp(extension,'.mldatx')
            this.ActionInProgress=false;


            if bIsSessionFile
                this.cacheSessionInfo(...
                filename,...
                pathname);
            end
        end
    end

    if~strcmp(extension,'.mldatx')
        this.Engine.publishUpdateLabelsNotification();
    end
end

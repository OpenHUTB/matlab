function newSessionConfirmation(this,choice)



    appName=this.AppName;
    tmp=onCleanup(@()updateGUITitle(this));
    this.ActionInProgress=false;

    switch choice
    case 0
        filename=this.saveSession(true);
        if isempty(filename)
            return;
        end

    case 2
        return;

    otherwise
        assert(choice==1);
    end


    try
        Simulink.sdi.clear(true,'appName',appName);
    catch me
        okStr=getString(message('SDI:sdi:OKShortcut'));

        Simulink.sdi.internal.controllers.SessionSaveLoad.displayMsgBox(...
        this.AppName,...
        Simulink.sdi.internal.StringDict.mgError,...
        me.message,...
        {okStr},...
        0,...
        -1,...
        []);
        return
    end

    if strcmp(appName,'siganalyzer')
        matname=Simulink.sdi.Instance.getSetSAUtils().getStorageLSSFilename();
        if exist(matname,'file')==2
            m=matfile(matname,'Writable',true);
            mFields=fields(m);
            for idx=1:length(mFields)
                if isa(m.(mFields{idx}),'signallabelutils.internal.labeling.LightWeightLabeledSignalSet')
                    m.(mFields{idx})=NaN;
                end
            end
        end
    end

    this.Engine.publishUpdateLabelsNotification();
    this.cacheSessionInfo('','',false);
end

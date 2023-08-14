function importStreaming(this)














    if~this.isConnected()
        this.connect;
    end

    [file,path]=uigetfile('*.mat',message('slrealtime:target:importInstrumentTitle').getString());

    if file==0

        return
    end

    [filepath,fname,ext]=fileparts(fullfile(path,file));
    if~strcmp(ext,'.mat')
        this.throwError('slrealtime:target:importInstrument');
    end

    originalState(1)=warning('off','MATLAB:load:classErrorNoCtor');
    originalState(2)=warning('off','MATLAB:load:classError');
    originalState(3)=warning('off','MATLAB:class:LoadInvalidDefaultElement');
    c=onCleanup(@()warning(originalState));
    try
        S=load(fullfile(filepath,fname));
    catch
        this.throwError('slrealtime:target:importInstrument');
    end

    if~isfield(S,'BindModeDataMap')||...
        ~isfield(S,'pInst')||...
        ~isfield(S,'BindModeModelName')
        this.throwError('slrealtime:target:importInstrument');
    end

    try
        this.removeInstrument(this.BindModeInstrument);
    catch
    end

    this.BindModeDataMap=S.BindModeDataMap;
    this.BindModeInstrument=S.pInst;
    this.BindModeModelName=S.BindModeModelName;

    this.addInstrument(this.BindModeInstrument);

    this.synchAllToolStrips();
end

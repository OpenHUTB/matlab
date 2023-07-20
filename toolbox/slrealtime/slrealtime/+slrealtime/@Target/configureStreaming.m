function configureStreaming(this,varargin)



















    if~this.isConnected()
        this.connect;
    end

    if nargin>1
        modelName=varargin{1};
        validateattributes(modelName,{'char','string'},{'scalartext'});
        this.BindModeModelName=convertStringsToChars(modelName);
    elseif this.isLoaded()
        this.BindModeModelName=this.tc.ModelProperties.ModelName;
    else
        this.throwError('slrealtime:target:configureInstrument',this.TargetSettings.name);
    end

    open_system(this.BindModeModelName);
    bindObj=slrealtime.internal.SLRTBindModeSourceData(...
    this.BindModeModelName,...
    slrealtime.internal.SLRTBindModeSourceData.SIGNALS,...
    @(d)processBindModeSignals(this,d),this.BindModeDataMap);
    BindMode.BindMode.enableBindMode(bindObj);

    this.BindModeActive=true;
    this.synchAllToolStrips();
end

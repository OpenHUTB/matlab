function URL=getSLVisualURL(this,varargin)




    clientID=this.ClientID;
    featureFlag=this.getSLFeature();

    prodString='simulink';
    if dig.isProductInstalled('Simscape')
        prodString='simscape';
    elseif dig.isProductInstalled('DSP System Toolbox')
        prodString='dsp';
    end
    if uiservices.onOffToLogical(get_param(this.FullPath,'IsFloating'))
        isFloating='On';
    else
        isFloating='Off';
    end

    if slfeature('ShowScopeDockControls')
        dock='On';
    else
        dock='Off';
    end

    URL='toolbox/shared/spcuilib/sltimescope/web/sltimescope/timescope-simulink';
    postFix=sprintf('.html?%s',matlabshared.scopes.getQueryString(...
    'ClientID',clientID,...
    'Toolstrip','On',...
    'Statusbar','On',...
    'DockControls',dock,...
    'Product',prodString,...
    'Deployed','Off',...
    'Floating',isFloating,varargin{:}));

    if featureFlag<2||featureFlag>3
        URL=[URL,'-debug'];
    end


    URL=connector.getUrl([URL,postFix]);
end

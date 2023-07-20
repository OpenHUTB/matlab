function URL=getSLVisualURL(this,varargin)




    clientID=this.ClientID;
    featureFlag=this.getSLFeature();

    dock=utils.logicalToOnOff(slfeature('ShowScopeDockControls'));

    [~,product]=Simulink.scopes.SpectrumAnalyzerUtils.isPhysicalModelingMode();

    URL='toolbox/shared/dsp/webscopes/slspectrumanalyzer/web/slspectrumanalyzer/spectrumanalyzer-simulink';
    postFix=sprintf('.html?%s',matlabshared.scopes.getQueryString(...
    'ClientID',clientID,...
    'Toolstrip','On',...
    'Statusbar','On',...
    'DockControls',dock,...
    'Product',product,...
    'Deployed','Off',...
    'Floating',get_param(this.FullPath,'IsFloating'),...
    varargin{:}));
    if featureFlag<2||featureFlag>3
        URL=[URL,'-debug'];
    end


    URL=connector.getUrl([URL,postFix]);
end

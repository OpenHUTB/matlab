function URL=getSLVisualURL(this,varargin)




    clientID=this.ClientID;
    featureFlag=this.getSLFeature();
    URL='toolbox/comm/webscopes/slconstellationdiagram/web/constellationdiagram-simulink';
    postFix=sprintf('.html?%s',matlabshared.scopes.getQueryString(...
    'ClientID',clientID,...
    'Toolstrip','On',...
    'Statusbar','On',...
    'Floating',get_param(this.FullPath,'IsFloating')),...
    varargin{:});

    if featureFlag<2||featureFlag>3
        URL=[URL,'-debug'];
    end


    URL=connector.getUrl([URL,postFix]);
end

function URL=getSLVisualURL(this)



    clientID=this.ClientID;
    featureFlag=this.getSLFeature();
    URL='toolbox/phased/phased/webscopes/sldtiwebscope/web/sldtiwebscope/dtiscope-simulink';
    postFix=['.html?ClientID=',clientID,'&Toolstrip=On&Statusbar=Off'];
    if featureFlag<2||featureFlag>3
        URL=[URL,'-debug'];
    end


    URL=connector.getUrl([URL,postFix]);

end

function URL=getURL(clientID)




    URL='/toolbox/shared/spcuilib/logicanalyzer/web/logicanalyzer/logicanalyzer-simulink';
    postFix=['.html?ClientID=',clientID];
    feature=slfeature('slLogicAnalyzerApp');

    if feature<2||feature>3
        URL=[URL,'-debug'];
    end


    URL=connector.getUrl([URL,postFix]);

end


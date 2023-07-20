function initBaseDialog(dlgsrc,rootSystem)






    if isa(rootSystem,'char')
        dlgsrc.rootSystem=get_param(rootSystem,'Object');
    else
        dlgsrc.rootSystem=rootSystem;
    end




    dlgsrc.retainXMLSource=false;



    dlgsrc.noView=false;



    dlgsrc.initReportProperties();



    dlgsrc.installModelCloseListener();

end
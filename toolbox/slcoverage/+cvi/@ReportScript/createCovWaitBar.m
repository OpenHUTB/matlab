function waitbarH=createCovWaitBar(cvhtmlSettings,itemName)





    waitbarH=[];
    try
        if cvhtmlSettings.showReport&&~cvhtmlSettings.mathWorksTesting
            waitbarH=DAStudio.WaitBar;
            waitbarH.show;
            waitbarH.setWindowTitle([getString(message('Slvnv:simcoverage:cvmodelview:Coverage')),': ',itemName]);
            waitbarH.setLabelText(getString(message('Slvnv:simcoverage:cvhtml:CollectingCoverageData')));
            waitbarH.setValue(0);
        end
    catch

        waitbarH=[];
    end





function createInspectProgressBar(aObj)

    if aObj.fViaGUI
        if aObj.getGenerateCode
            aObj.fInspectProgressBar=DAStudio.WaitBar;
            aObj.fInspectProgressBar.setWindowTitle(DAStudio.message('Slci:ui:InspectAndGenCodeProgressTitle',aObj.getModelName()));
            aObj.setInspectProgressBarLabel('GenCode');
        else
            aObj.fInspectProgressBar=DAStudio.WaitBar;
            aObj.fInspectProgressBar.setWindowTitle(DAStudio.message('Slci:ui:InspectProgressTitle',aObj.getModelName()));
            aObj.setInspectProgressBarLabel('Inspect');
        end
        aObj.fInspectProgressBar.setCircularProgressBar(true);
        aObj.fInspectProgressBar.show();
    end
end

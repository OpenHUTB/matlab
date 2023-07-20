function setInspectProgressBarLabel(aObj,aStage)





    if~isempty(aObj.fInspectProgressBar)
        aObj.fInspectProgressBar.setLabelText(DAStudio.message(['Slci:ui:',aStage,'ProgressText']));
    end
end

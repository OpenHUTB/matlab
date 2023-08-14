function updateDevicePanel(this)








    javaPeer=java(this.javaPeer);
    formatNodePanel=javaPeer.getFormatNodePanel();

    vidObj=iatbrowser.Browser().currentVideoinputObject;

    sourceInfo=propinfo(vidObj,'SelectedSourceName');

    formatNodePanel.updateSourceCombo(sourceInfo.ConstraintValue,vidObj.SelectedSourceName);

    mcossource=getselectedsource(vidObj);

    props=imaqgate('privateConvertVideoSourcePropinfoToList',mcossource);

    formatNodePanel.updatePropertyEditor(getselectedsource(vidObj),props);

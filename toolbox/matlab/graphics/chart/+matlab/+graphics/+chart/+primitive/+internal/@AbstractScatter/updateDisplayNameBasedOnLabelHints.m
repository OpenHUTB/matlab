function updateDisplayNameBasedOnLabelHints(hObj,labelHints)




    channels=["X","Y","Z"];
    varNames=hObj.getChannelDisplayNames(channels);
    hObj.updateDisplayNameBasedOnLabelHintsHelper(...
    channels,varNames,labelHints);

end

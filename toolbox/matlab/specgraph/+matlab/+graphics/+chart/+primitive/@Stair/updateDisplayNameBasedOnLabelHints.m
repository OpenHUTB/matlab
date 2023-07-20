function updateDisplayNameBasedOnLabelHints(hObj,labelHints)




    channels=["X","Y"];
    varNames=hObj.getChannelDisplayNames(channels);
    hObj.updateDisplayNameBasedOnLabelHintsHelper(...
    channels,varNames,labelHints);

end

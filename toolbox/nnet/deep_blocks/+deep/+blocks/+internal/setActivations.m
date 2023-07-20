function setActivations(block)




    mask=Simulink.Mask.get(block);
    activationsListBox=mask.getParameter('Activations');

    networkToLoad=deep.blocks.internal.getSelectedNetwork(block);

    try
        networkInfo=deep.blocks.internal.getNetworkInfo(block,networkToLoad);
        layerNames=networkInfo.ActivationNames;
    catch
        layerNames={};
    end

    currentActivations=eval(activationsListBox.Value);
    newActivations=deep.blocks.internal.cell2str(intersect(layerNames,currentActivations));

    activationsListBox.set('TypeOptions',layerNames);
    activationsListBox.set('Value',newActivations);

end

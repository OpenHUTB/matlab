function nominalPostSet(hDialog,hSource,~,~)




    hDialog.setEnabled('SimscapeNominalValues',...
    NetworkEngine.SystemScaling.isNominalValueViewerEnabled(hSource,[]));

end
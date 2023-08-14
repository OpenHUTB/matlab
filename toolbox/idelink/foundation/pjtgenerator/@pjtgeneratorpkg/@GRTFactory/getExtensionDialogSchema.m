function widgets=getExtensionDialogSchema(hSrc,schemaName)





    tgtWidgets=linkfoundation.util.getSharedIDELinkExtensionDialogSchema(hSrc,false);

    hCtrl=hSrc.getDialogController;
    GRTWidgets=hCtrl.getGRTDialogSchema(schemaName);

    widgets={GRTWidgets,tgtWidgets};

end

function[Tabs]=getExtensionDialogSchema(hSrc,schemaName)

    [tgtTab]=tlmg.private.UtilTargetCC.getExtensionDialogSchema(hSrc,schemaName);

    hCtrl=hSrc.getDialogController;
    [GRTtab]=hCtrl.getGRTDialogSchema(schemaName);

    Tabs={GRTtab,tgtTab};

end

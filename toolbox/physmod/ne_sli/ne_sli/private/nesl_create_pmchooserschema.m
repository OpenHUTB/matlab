function dlgSchema=nesl_create_pmchooserschema(componentName,hSlBlk)













    compChooser=NetworkEngine.PmNeComponentChooserPanel(hSlBlk);
    myBlder=PMDialogs.PmDlgBuilder(hSlBlk);
    myBlder.Items=compChooser;

    dlgSchema=[];
    [status,dlgSchema]=myBlder.getPmSchema(dlgSchema);%#ok
end
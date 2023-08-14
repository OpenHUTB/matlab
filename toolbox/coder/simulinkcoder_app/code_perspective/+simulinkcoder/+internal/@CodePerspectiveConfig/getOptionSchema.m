function optionPanel=getOptionSchema(obj)




    etc.Type='checkbox';
    etc.Name='Edit-time checking';
    etc.Tag='EditTimeChecking';
    etc.Value=true;
    etc.ObjectMethod='dialogCallback';
    etc.MethodArgs={'%tag','%value'};
    etc.ArgDataTypes={'string','mxArray'};

    scs.Type='checkbox';
    scs.Name='Storage class on signals';
    scs.Tag='StorageClassOnSignals';
    scs.Value=false;
    scs.ObjectMethod='dialogCallback';
    scs.MethodArgs={'%tag','%value'};
    scs.ArgDataTypes={'string','mxArray'};

    optionPanel.Type='group';
    optionPanel.Name='Options';
    optionPanel.Items={etc,scs};
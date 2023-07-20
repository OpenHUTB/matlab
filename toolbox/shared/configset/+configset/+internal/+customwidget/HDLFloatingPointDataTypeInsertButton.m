function updateDeps=HDLFloatingPointDataTypeInsertButton(cs,~)



    updateDeps=false;
    cs=cs.getConfigSet;
    hdlcc=cs.getComponent('HDL Coder');
    cli=hdlcc.getCLI;
    adp=configset.internal.getConfigSetAdapter(cs);

    fp=cli.FloatingPointTargetConfiguration;
    if adp.tmpWidgetValues.isKey('FloatingPointDataTypeString')
        val=adp.tmpWidgetValues('FloatingPointDataTypeString');
    else
        return;
    end
    newfp=fp.copy();
    newfp.IPConfig.customizeOrInsert('Convert',val);
    cli.FloatingPointTargetConfiguration=newfp;

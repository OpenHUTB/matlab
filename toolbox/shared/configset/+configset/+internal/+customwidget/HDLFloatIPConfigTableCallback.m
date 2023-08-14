function HDLFloatIPConfigTableCallback(src,row,col,val)






    dlg=src.getDialogHandle;

    controller=src.getDialogController;
    adp=controller.csv2;

    cs=src.getConfigSet;
    if isempty(cs)
        cs=src;
    end
    hdlcc=cs.getComponent('HDL Coder');
    cli=hdlcc.getCLI;

    fp=cli.FloatingPointTargetConfiguration;

    table=fp.IPConfig.outputInString();
    table.(table.Properties.VariableNames{col+1})(row+1)={val};
    newfp=fp.copy();
    newfp.IPConfig.inputInString(table);
    newfp.IPConfig.consolidate();



    msg.name='FloatingPointTargetConfiguration';
    msg.value=newfp;
    msg.data=adp.getParamData('FloatingPointTargetConfiguration');
    msg.dialog=dlg;

    adp.dialogCallback(msg);




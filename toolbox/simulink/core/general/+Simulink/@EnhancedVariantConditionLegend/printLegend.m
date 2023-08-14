function printLegend(h,modelName)




    figH=getAsHGFigure(h,modelName);

    if figH~=-1
        printdlg(figH)
        close(figH)
    else
        dp=DAStudio.DialogProvider;
        dp.warndlg(DAStudio.message('Simulink:utility:NoVariantConditionLegendDataToPrint'),'Warning',true);
    end

function DSMaskSelectedSignalChanged(dlg,varargin)






    dlgSource=dlg.getDialogSource();
    imd=DAStudio.imDialog.getIMWidgets(dlg);
    selectionWidget=get(find(imd,'WidgetId','signalSelect'));
    dlgSource.selection=selectionWidget.currentText;
end
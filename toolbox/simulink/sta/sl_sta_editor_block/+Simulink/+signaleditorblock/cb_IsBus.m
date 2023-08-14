function[ret,msg]=cb_IsBus(obj)





    imd=DAStudio.imDialog.getIMWidgets(obj);
    isBus=find(imd,'Tag','IsBus');
    datatypewidget_Tag=Simulink.DataTypePrmWidget.getDataTypeWidgetTag('OutputBusObjectStr');
    obj.setVisible(datatypewidget_Tag,isBus.checked);
    Simulink.signaleditorblock.cb_signalPropertiesChanged(obj);
    ret=true;
    msg='No error';

end
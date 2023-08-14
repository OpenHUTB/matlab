function DngBacklinkCheckbox_callback(this,dlg)

    value=dlg.getWidgetValue('DngBacklinkCheckbox');
    this.make2way=value;

    rmipref('BiDirectionalLinking',value);

end

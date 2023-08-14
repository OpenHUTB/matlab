function bindingTableCellSelectionCB(this)





    if numel(this.BindingTable.Selection)==1
        if this.isTableSelectionParameter()

            this.showParameterPropertyPanels();
            this.updateParameterPropertyPanels(this.BindingTable.Selection);
        else

            if strcmp(this.BindingData{this.BindingTable.Selection}.ControlType,'Axes')
                this.showSignalWithLinePropertyPanels();
            else
                this.showSignalPropertyPanels();
            end
            this.updateSignalPropertyPanels(this.BindingTable.Selection);
        end
    else
        this.hideAllPropertyPanels();
    end

    this.updateEditButtonEnable();

    this.syncUI();

    this.closePropertyInspector();
end

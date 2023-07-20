function refreshStyles(this)










    this.BindingTable.removeStyle();

    for nRow=1:numel(this.BindingData)


        if this.isBindingParameter(nRow)
            iconStyle=this.parameterIconStyle;
        else
            iconStyle=this.signalIconStyle;
        end
        addStyle(this.BindingTable,iconStyle,'cell',[nRow,this.BindingTableTypeColIdx]);



        if~this.BindingData{nRow}.Valid
            addStyle(this.BindingTable,this.invalidBindingStyle,'row',nRow);
        end
    end
end

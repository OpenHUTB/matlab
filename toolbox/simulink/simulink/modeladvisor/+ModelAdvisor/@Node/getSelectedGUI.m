function valueToCaller=getSelectedGUI(this,valueStored)




    if this.InTriState
        valueToCaller='partial';
    elseif this.Selected
        valueToCaller='checked';
    else
        valueToCaller='unchecked';
    end

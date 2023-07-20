function propname=getCheckableProperty(this)





    if~this.ShowCheckbox||this.InLibrary
        propname='';
    else
        propname='SelectedGUI';
    end

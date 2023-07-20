function propname=getCheckableProperty(this)



    if~this.ShowCheckbox||strcmp(this.Type,'Container')
        propname='';
    else
        propname='SelectedGUI';
    end

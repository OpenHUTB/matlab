function validateEntry(this,dlghandle)








    dlghandle.apply;
    TflDesigner.setcurrentlistnode(this);
    if isempty(this.applyerrorlog)
        TflDesigner.doValidateEntry(this,false);
        this.applyinvalid=false;
        this.firepropertychanged;
    else
        this.applyinvalid=true;
        this.firepropertychanged;
    end



function dlgSetElemXForm(this,value,dlg)




    currElem=getCurrElem(this);

    if value==0
        this.CurrElemXForm=currElem.getDefaultXForm();
        currElem.XForm='';
    else
        currElem.XForm=currElem.getDefaultXForm();
    end

    dlg.refresh;


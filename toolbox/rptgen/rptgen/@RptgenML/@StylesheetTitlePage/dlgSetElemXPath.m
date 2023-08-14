function dlgSetElemXPath(this,value,dlg)




    currElem=getCurrElem(this);

    if value==0
        this.CurrElemXPath=currElem.getDefaultXPath();
        currElem.XPath='';
    else
        currElem.XPath=currElem.getDefaultXPath();
    end

    dlg.refresh;


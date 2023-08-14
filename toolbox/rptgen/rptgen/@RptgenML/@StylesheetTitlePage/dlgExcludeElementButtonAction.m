function dlgExcludeElementButtonAction(this,dlg)







    exElement=this.IncludedElementNames{this.CurrIncludeElementIdx+1};
    this.excludeElement(exElement);
    dlg.refresh();











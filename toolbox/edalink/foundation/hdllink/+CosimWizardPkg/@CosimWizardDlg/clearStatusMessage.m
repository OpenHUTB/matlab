function clearStatusMessage(this,dlg)



    this.Status='';
    if~isempty(dlg),dlg.refresh;end



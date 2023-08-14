function refreshHTMLView(cs)






    adp=cs.getDialogController.csv2;
    if~isempty(adp)
        adp.refresh();
    end

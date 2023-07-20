function resetHTMLView(cs)







    adp=cs.getDialogController.csv2;
    if isa(adp,'configset.internal.data.ConfigSetAdapter')
        adp.resetAdapter();
    end

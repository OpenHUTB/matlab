function refreshWidgets(cs,param)






    adp=cs.getDialogController.csv2;
    if~isempty(adp)
        adp.update(cs,param);
    end

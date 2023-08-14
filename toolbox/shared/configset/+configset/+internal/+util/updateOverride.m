function updateOverride(csref)


    adp=csref.getDialogController.csv2;
    if~isempty(adp)
        if adp.isLocked
            adp.needUpdateOverride=true;
        else
            adp.updateOverride();
        end
    end


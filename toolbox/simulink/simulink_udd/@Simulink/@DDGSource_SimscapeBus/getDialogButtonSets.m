function buttonsets=getDialogButtonSets(this)





    if slfeature('CUSTOM_BUSES')==1
        buttonsets.StandaloneButtonSet={'Help','Apply'};
        buttonsets.EmbeddedButtonSet={'Help','Apply'};
    else
        buttonsets.StandaloneButtonSet={'Help'};
        buttonsets.EmbeddedButtonSet={'Help'};
    end

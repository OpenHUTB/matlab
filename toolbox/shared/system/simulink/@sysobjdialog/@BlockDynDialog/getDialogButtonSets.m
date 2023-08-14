function buttonsets=getDialogButtonSets(this)







    if~this.DialogManager.IsSystemObjectValid||this.DialogManager.ShowSystemParameter
        buttonsets.StandaloneButtonSet={'Ok','Cancel','Help'};
        buttonsets.EmbeddedButtonSet={'Revert','Help','Apply'};
    else
        buttonsets.StandaloneButtonSet={'Ok','Cancel','Help','Apply'};
        buttonsets.EmbeddedButtonSet={'Revert','Help','Apply'};
    end
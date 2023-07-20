function splitOrTabConstViewCallback(cbinfo)




    currVal=cbinfo.Context.Object.App.ConstraintViewType;
    if strcmp(message(currVal).getString(),'Split View')
        cbinfo.Context.Object.App.ConstraintViewType='Simulink:VariantManagerUI:ConstraintTabViewText';
    else
        cbinfo.Context.Object.App.ConstraintViewType='Simulink:VariantManagerUI:ConstraintSplitViewText';
    end
end

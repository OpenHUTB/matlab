function constantBlockValueActionRF(cbinfo,action)





    selection=cbinfo.getSelection;
    if(isempty(selection)||length(selection)>1||~isa(selection,'Simulink.Constant'))

        return;
    elseif(~isscalar(selection))

        return;
    end

    action.text=get_param(selection.Handle,'Value');
end
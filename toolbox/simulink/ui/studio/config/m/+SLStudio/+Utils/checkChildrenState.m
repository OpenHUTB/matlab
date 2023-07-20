function state=checkChildrenState(cbinfo,checkFcns)












    state='Hidden';
    for index=1:length(checkFcns)
        next_state=checkFcns{index}(cbinfo);
        switch next_state
        case 'Enabled'
            state='Enabled';
            return
        case 'Disabled'
            state='Disabled';
        end
    end
end

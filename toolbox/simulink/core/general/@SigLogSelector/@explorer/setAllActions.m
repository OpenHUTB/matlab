function setAllActions(h,state)






    locCacheActionState(h);


    actNames=locGetActionNames(h);
    for i=1:numel(actNames)
        h.getAction(actNames{i}).Enabled=state;
    end


    h.hOverrideCombo.setEnabled(strcmpi(state,'on'));

end


function names=locGetActionNames(h)


    numActions=h.actions.getCount;
    names=cell(numActions,1);
    for idx=1:numActions
        names{idx}=h.actions.getKeyByIndex(idx);
    end

end


function locCacheActionState(h)


    actNames=locGetActionNames(h);
    h.actionstate.Clear;
    for idx=1:numel(actNames)
        action=actNames{idx};
        state=h.getAction(action).Enabled;
        h.actionstate.insert(action,state);
    end

end

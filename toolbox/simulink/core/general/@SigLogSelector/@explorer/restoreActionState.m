function restoreActionState(h)






    numActions=h.actionstate.getCount;
    for idx=1:numActions
        action=h.actionstate.getKeyByIndex(idx);
        state=h.actionstate.getDataByIndex(idx);
        h.getAction(action).Enabled=state;
    end


    h.hOverrideCombo.setEnabled(true);

end

function setallactions(h,state)




    actionnames=h.actions.keys;
    for i=1:numel(actionnames)
        h.getaction(actionnames{i}).Enabled=state;
    end


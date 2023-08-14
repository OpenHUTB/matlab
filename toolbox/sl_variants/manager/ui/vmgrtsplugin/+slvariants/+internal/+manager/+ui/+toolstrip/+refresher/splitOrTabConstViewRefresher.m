function splitOrTabConstViewRefresher(cbinfo,action)




    currVal=cbinfo.Context.Object.App.ConstraintViewType;
    if strcmp(message(currVal).getString(),'Split View')
        action.icon='splitView';
    else
        action.icon='tabView';
    end
    action.text=message(currVal).getString();
end

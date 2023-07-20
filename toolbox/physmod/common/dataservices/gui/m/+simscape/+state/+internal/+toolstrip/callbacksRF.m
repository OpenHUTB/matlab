function callbacksRF(userData,cbInfo,action)





    pm_assert(~isempty(cbInfo));
    pm_assert(~isempty(action));
    pm_assert(~isempty(userData));

    obj=cbInfo.Context.Object;
    switch lower(userData)
    case 'tree'
        if obj.FlatView
            action.selected=false;
            action.enabled=true;
        else
            action.selected=true;
            action.enabled=false;
        end
    case 'flat'
        if obj.FlatView
            action.selected=true;
            action.enabled=false;
        else
            action.selected=false;
            action.enabled=true;
        end
    case{'expand','collapse'}
        if obj.FlatView
            action.enabled=false;
        else
            action.enabled=true;
        end
    otherwise

    end

end

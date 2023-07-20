function callbacks(userData,cbInfo)





    pm_assert(~isempty(cbInfo));
    pm_assert(~isempty(userData));

    obj=cbInfo.Context.Object;
    switch lower(userData)
    case 'tree'
        simscape.state.internal.toolstrip.viewerContext.setFlatView(obj,false);



        simscape_variable_viewer_tree_view(obj.ModelHandle,...
        {'physmod:common:dataservices:gui:app:ButtonExpandActionId',...
        'physmod:common:dataservices:gui:app:ButtonCollapseActionId'});
    case 'flat'
        simscape.state.internal.toolstrip.viewerContext.setFlatView(obj,true);



        simscape_variable_viewer_flat_view(obj.ModelHandle,...
        {'physmod:common:dataservices:gui:app:ButtonExpandActionId',...
        'physmod:common:dataservices:gui:app:ButtonCollapseActionId'});
    case 'expand'
        simscape_variable_viewer_expand_all(obj.ModelHandle,obj.DataModelId);
    case 'collapse'
        simscape_variable_viewer_collapse_all(obj.ModelHandle,obj.DataModelId);
    case 'basic'
        simscape_variable_viewer_basic(obj.ModelHandle);
    case 'advanced'
        simscape_variable_viewer_advanced(obj.ModelHandle);
    case 'update'
        simscape.state.internal.refreshViewer(obj.ModelHandle);
        obj.ViewerInSync=true;
        obj.TypeChain={'ModelInSync'};




        simscape_variable_viewer_status_update(obj.ModelHandle,...
        get_param(obj.ModelHandle,'ModifiedTimeStamp'),obj.ViewerInSync);
    case 'clearfilters'
        simscape_variable_viewer_clear_filters(obj.ModelHandle);
    case 'save'
        simscape_variable_viewer_save_preferences(obj.ModelHandle);
    case 'help'
        simscape.state.internal.help;
    otherwise
        pm_assert(false);
    end

end

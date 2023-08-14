function packageName(cbInfo,action)














    coder.internal.toolstrip.refresher.configParam('PackageName',cbInfo,action);
    action.placeholderText=[get_param(cbInfo.model.handle,'Name'),'.zip'];

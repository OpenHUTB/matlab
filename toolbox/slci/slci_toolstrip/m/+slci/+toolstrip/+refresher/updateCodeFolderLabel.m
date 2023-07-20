


function updateCodeFolderLabel(cbinfo,action)

    ctx=cbinfo.studio.App.getAppContextManager.getCustomContext('slciApp');

    action.enabled=ctx.getSingleFolderCodePlacement();

end
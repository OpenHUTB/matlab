


function updateCodeFolder(cbinfo,action)

    ctx=cbinfo.studio.App.getAppContextManager.getCustomContext('slciApp');

    action.enabled=ctx.getSingleFolderCodePlacement();
    action.text=ctx.getCodeFolder();

end
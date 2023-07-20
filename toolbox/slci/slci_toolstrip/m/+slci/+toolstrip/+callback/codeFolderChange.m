


function codeFolderChange(cbinfo)

    ctx=cbinfo.studio.App.getAppContextManager.getCustomContext('slciApp');
    ctx.setCodeFolder(cbinfo.EventData);

end
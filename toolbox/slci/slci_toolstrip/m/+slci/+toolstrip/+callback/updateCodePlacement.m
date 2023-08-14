


function updateCodePlacement(cbinfo)

    ctx=cbinfo.studio.App.getAppContextManager.getCustomContext('slciApp');

    codePlacement=cbinfo.EventData;
    isSingleFolder=strcmp(codePlacement,'singlefolder');
    ctx.setSingleFolderCodePlacement(isSingleFolder);

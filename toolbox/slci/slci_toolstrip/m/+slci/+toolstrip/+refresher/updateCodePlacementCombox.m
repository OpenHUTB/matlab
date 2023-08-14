


function updateCodePlacementCombox(cbinfo,action)

    ctx=cbinfo.studio.App.getAppContextManager.getCustomContext('slciApp');

    selected='default';
    if ctx.getSingleFolderCodePlacement()
        selected='singlefolder';
    end
    action.selectedItem=selected;

end
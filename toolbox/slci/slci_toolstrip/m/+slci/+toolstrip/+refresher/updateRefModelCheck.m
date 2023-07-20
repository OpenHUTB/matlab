


function updateRefModelCheck(cbinfo,action)

    ctx=cbinfo.studio.App.getAppContextManager.getCustomContext('slciApp');
    action.selected=~ctx.getTopModel();




function updateInspectText(cbinfo,action)

    ctx=cbinfo.studio.App.getAppContextManager.getCustomContext('slciApp');
    isTop=ctx.getTopModel();

    if isTop
        action.description=DAStudio.message('Slci:toolstrip:InspectAsTopActionDescription');
    else
        action.description=DAStudio.message('Slci:toolstrip:InspectAsRefActionDescription');
    end

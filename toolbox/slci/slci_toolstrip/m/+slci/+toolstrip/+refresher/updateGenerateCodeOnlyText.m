


function updateGenerateCodeOnlyText(cbinfo,action)

    ctx=cbinfo.studio.App.getAppContextManager.getCustomContext('slciApp');
    isTop=ctx.getTopModel();

    if isTop
        action.text=DAStudio.message('Slci:toolstrip:GenerateCodeOnlyTopActionText');
    else
        action.text=DAStudio.message('Slci:toolstrip:GenerateCodeOnlyRefActionText');
    end

    if isTop
        action.description=DAStudio.message('Slci:toolstrip:GenerateCodeOnlyTopActionDescription');
    else
        action.description=DAStudio.message('Slci:toolstrip:GenerateCodeOnlyRefActionDescription');
    end
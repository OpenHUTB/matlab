


function updateGenerateCodeText(cbinfo,action)

    ctx=cbinfo.studio.App.getAppContextManager.getCustomContext('slciApp');

    isTop=ctx.getTopModel();

    if isTop
        action.text=DAStudio.message('Slci:toolstrip:GenerateCodeTopActionText');
        action.description=DAStudio.message('Slci:toolstrip:GenerateCodeTopActionDescription');
    else
        action.text=DAStudio.message('Slci:toolstrip:GenerateCodeRefActionText');
        action.description=DAStudio.message('Slci:toolstrip:GenerateCodeRefActionDescription');
    end




function updateGenerateCodeAndBuildText(cbinfo,action)

    ctx=cbinfo.studio.App.getAppContextManager.getCustomContext('slciApp');

    isTop=ctx.getTopModel();

    if isTop
        action.text=DAStudio.message('Slci:toolstrip:GenerateCodeAndBuildTopActionText');
    else
        action.text=DAStudio.message('Slci:toolstrip:GenerateCodeAndBuildRefActionText');
    end

    if isTop
        action.description=DAStudio.message('Slci:toolstrip:GenerateCodeAndBuildTopActionDescription');
    else
        action.description=DAStudio.message('Slci:toolstrip:GenerateCodeAndBuildRefActionDescription');
    end
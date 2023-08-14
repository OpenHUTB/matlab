


function updateAnalyzeAsTopRF(cbinfo,action)

    ctx=cbinfo.studio.App.getAppContextManager.getCustomContext('slciApp');

    if ctx.getTopModel()
        action.text=DAStudio.message('Slci:toolstrip:AnalyzeAsTopActionText');
        action.description=DAStudio.message('Slci:toolstrip:AnalyzeAsTopActionDescription');
    else
        action.text=DAStudio.message('Slci:toolstrip:AnalyzeAsRefActionText');
        action.description=DAStudio.message('Slci:toolstrip:AnalyzeAsRefActionDescription');
    end



function updateDisableNonInlinedFuncBodyVerificationCheck(cbinfo,action)

    ctx=cbinfo.studio.App.getAppContextManager.getCustomContext('slciApp');

    action.selected=ctx.getDisableNonInlinedFuncBodyVerification();
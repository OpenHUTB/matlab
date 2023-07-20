function viewSDP(model)


    isFC=coder.internal.toolstrip.util.getPlatformType(model);
    if isFC

        sldd=get_param(model,'EmbeddedCoderDictionary');
        simulinkcoder.internal.app.ViewSDP(sldd);
    else

        simulinkcoder.internal.app.ViewSDP(model);
    end


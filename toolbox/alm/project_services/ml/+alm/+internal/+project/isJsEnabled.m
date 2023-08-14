


function b=isJsEnabled()

    b=settings().matlab.project.JsEnabled.ActiveValue||...
    matlab.internal.project.util.useWebFrontEnd();
end

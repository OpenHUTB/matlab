function startProxying()

    persistent isCallbackRegistered;
    if isempty(isCallbackRegistered)
        isCallbackRegistered=false;
        mlock;
    end

    if usejava('jvm')


        if~isempty(which('com.mathworks.mlwidgets.html.HTMLPrefs.setProxySettings'))

            feval('com.mathworks.mlwidgets.html.HTMLPrefs.setProxyHost','');
            feval('com.mathworks.mlwidgets.html.HTMLPrefs.setProxyPort','');
            feval('com.mathworks.mlwidgets.html.HTMLPrefs.setUseProxy',false);
            feval('com.mathworks.mlwidgets.html.HTMLPrefs.setProxySettings');
        end

        java.lang.System.clearProperty('http.proxyHost');
        java.lang.System.clearProperty('http.proxyPort');
        java.lang.System.clearProperty('tmw.proxyHost');
        java.lang.System.clearProperty('tmw.proxyPort');
    end

    if~isCallbackRegistered

        matlab.prefdir.internal.regCallbackPrefdirUpdated(@connector.internal.lifecycle.workerStarting.startProxying);
        isCallbackRegistered=true;
    end
end

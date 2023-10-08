function ok=consoleInit(product)

    import si.utilities.*
    if~strcmpi(product,'siViewer')
        runningApps=findConsole(product);
        if~isempty(runningApps)
            oldWarnState=warning('off','backtrace');
            warning(message('si:apps:AlreadyRunning',qxx2FullName(product)))
            warning(oldWarnState.state,'backtrace')
            ok=false;
            return
        end
    end

    if builtin('license','test','RF_Toolbox')
        builtin('license','checkout','RF_Toolbox');
    end
    if~okFeature('RF_Toolbox')
        oldWarnState=warning('off','backtrace');
        warning(message('si:apps:NoRFT'))
        warning(oldWarnState.state,'backtrace')
        ok=false;
        return
    end
    ok=true;
end

function debug(this)
    feature=slfeature('slBirdsEyeScopeApp');

    if feature>2&&~isempty(this.WebWindow)
        URL=sprintf('http://localhost:%d',this.WebWindow.RemoteDebuggingPort);
        if strcmpi(computer,'maci64')
            system(['open -a Google\ Chrome "',URL,'" --args --incognito']);
        elseif strcmpi(computer,'pcwin64')
            system(['start chrome "',URL,'" --incognito']);
        elseif strcmpi(computer,'glnxa64')
            system(['chromium "',URL,'"&']);
        end
    end
function completeOverride=executeMWALogin(hStep,command,varargin)




    completeOverride=false;
    switch(command)
    case 'initialize',
    case 'initDisplay',
    case 'next'
        hSetup=hStep.getSetup();
        alreadyLoggedIn=hSetup.MWALogin.ResultIsValid&&hSetup.MWALogin.IsLoggedIn;

        if alreadyLoggedIn
            completeOverride=false;
        else
            hSetup.MWALogin.initiateDefaultLoginWorkflow(@postLoginCallback);
            completeOverride=true;
        end

    case 'callback',
        completeOverride=true;
        switch(varargin{1})
        case 'Help',
            hwconnectinstaller.helpView('mwalogin');
        otherwise,
            completeOverride=false;
        end

    end


    function postLoginCallback(~)


        if ishandle(hSetup.Explorer)
            if hSetup.MWALogin.ResultIsValid&&hSetup.MWALogin.IsLoggedIn
                hStep.next([]);
            end

            hSetup.Explorer.getDialog().refresh;
            hSetup.Explorer.show();
        end
    end

end

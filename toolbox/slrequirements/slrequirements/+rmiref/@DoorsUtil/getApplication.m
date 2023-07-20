function app=getApplication(use_current)



    if nargin>0&&use_current
        if rmidoors.isAppRunning('nodialog')
            app=rmidoors.comApp();
        else
            error(message('Slvnv:rmiref:DocCheckDoors:DoorsNotRunning'));
        end
    elseif rmidoors.isAppRunning();
        app=rmidoors.comApp();
    else
        error(message('Slvnv:rmiref:DocCheckDoors:DoorsNotRunning'));
    end
end

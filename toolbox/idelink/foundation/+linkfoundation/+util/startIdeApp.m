function startIdeApp(app_exe)



    dos([app_exe,'&']);
    disp(['Waiting for application to start from: ',app_exe]);
    pause(5);disp('Done waiting.');



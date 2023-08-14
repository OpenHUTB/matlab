function close(mdlName)








    app=getRunningAppInstance(mdlName);
    if(~isempty(app))

        apphandle=app.getFigureHandle;

        close(apphandle);
    end

end
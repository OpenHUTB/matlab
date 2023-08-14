function rename(oldName,currentName)








    app=getRunningAppInstance(oldName);
    if(~isempty(app))

        app.updateMdlName(currentName);
    end
end
function save(app,newFileName)





















    if nargin==0
        save_system(gcs);
        return;
    else

        if(isa(app,'Simulink.SystemArchitecture.internal.ApplicationManager'))
            appName=app.getName();
        else
            appName=app;
        end

        if(nargin==2)
            try
                save_system(appName,newFileName);
            catch ME
                if strcmpi(ME.identifier,'Simulink:LoadSave:InvalidBlockDiagramName')


                    error('SystemArchitecture:LoadSave:InvalidArchName',...
                    'Invalid architecture name');
                else
                    rethrow(ME);
                end
            end
        else
            save_system(appName);
            return
        end
    end
end

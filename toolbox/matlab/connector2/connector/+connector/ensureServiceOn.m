function hostInfo=ensureServiceOn

    if nargout==1
        hostInfo=connector.internal.doEnsureServiceOn();
    else
        connector.internal.doEnsureServiceOn();
    end

    s=dbstack;
    if numel(s)>1
        if strcmp(s(2).name,'connector_scratch')
            disp('Starting http port for connector fixture');
            connector.internal.ensureRestMatlabOn;

            if usejava('jvm')&&~isempty(which('com.mathworks.matlabserver.connector.api.Connector.ensureServiceOn'))
                feval('com.mathworks.matlabserver.connector.api.Connector.ensureServiceOn');
            end
        end
    end

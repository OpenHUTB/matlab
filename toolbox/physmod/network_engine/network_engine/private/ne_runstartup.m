function ne_runstartup




    STARTUP_FUNCTION='ne_startup';

    startupFunctions=which(STARTUP_FUNCTION,'-all');

    directories=cell(size(startupFunctions));
    for i=1:length(startupFunctions)
        directories{i}=fileparts(startupFunctions{i});
    end

    directories=unique(directories);

    for i=1:length(directories)
        fcn=pm_pathtofunctionhandle(directories{i},STARTUP_FUNCTION);

        try
            fcn();
        end

    end

end

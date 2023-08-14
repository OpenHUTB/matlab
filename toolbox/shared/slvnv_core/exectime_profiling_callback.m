function exectime_profiling_callback(method,modelH)




    persistent isActive;

    mlock;

    if isempty(isActive)
        isActive=false;
    end

    switch method
    case 'activate'
        isActive=true;
    case 'deActivate'
        isActive=false;
    otherwise
        if isActive

assert...
            (any(strcmp...
            (method,{'init','close','forceClose','postLoad'})))

            if~strcmpi(get_param(modelH,'type'),'block_diagram')
                return;
            end
            lAnnotateManager=coder.profile.AnnotateManager.getAnnotateManagerInstance;

            lAnnotateManager.processCallback(modelH,method);
        end
    end
end


function sim0(model,uiMode)













    if nargin<1
        try
            pm_error('physmod:common:dataservices:sli:simulate:InvalidArguments');
        catch ME
            ME.throwAsCaller();
        end
    else

        if nargin<2
            uiMode=false;
        end
    end

    lSimulate(model,uiMode);

end

function lSimulate(model,uiMode)





    settings.dirty=get_param(model,'Dirty');
    settings.timeStamp=get_param(model,'ModifiedTimeStamp');

    settings.oldConfigSet=getActiveConfigSet(model);
    settings.newConfigSet=initializeConfigset(settings.oldConfigSet);

    if uiMode



        attachConfigSet(model,settings.newConfigSet);
        setActiveConfigSet(model,settings.newConfigSet.name);
        set_param(model,'ModifiedTimeStamp',settings.timeStamp);

        c2=onCleanup(@()(lUndoConfigsetModifications(model,settings)));


        [~,out]=evalc('sim(model, ''CaptureErrors'', ''on'')');


        meta=out.SimulationMetadata;


        numWarnings=numel(meta.ExecutionInfo.WarningDiagnostics);
        for idx=1:numWarnings
            meta.ExecutionInfo.WarningDiagnostics(idx).Diagnostic.reportAsWarning();
        end


        if~isempty(meta.ExecutionInfo.ErrorDiagnostic)
            meta.ExecutionInfo.ErrorDiagnostic.Diagnostic.reportAsError();
        end
    else
        sim(model,settings.newConfigSet);
    end
end

function lUndoConfigsetModifications(model,settings)



    setActiveConfigSet(model,settings.oldConfigSet.name);
    detachConfigSet(model,settings.newConfigSet.name);
    set_param(model,'Dirty',settings.dirty);


    set_param(model,'ModifiedTimeStamp',settings.timeStamp);


end

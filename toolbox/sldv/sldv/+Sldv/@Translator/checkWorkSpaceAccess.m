function status=checkWorkSpaceAccess(obj)












    status=sldvprivate('globalWsCheckAccess',obj.mExtractedModelH,true);







    if(status&&1==slfeature('ObserverSldv')&&~isempty(obj.mCompatObserverModelHs))
        observerModelHs=obj.mCompatObserverModelHs;
        for currObs=1:numel(observerModelHs)
            status=sldvprivate('globalWsCheckAccess',observerModelHs(currObs),true);
            if~status
                break;
            end
        end
    end
    if~status
        obj.logNewLines(getString(message('Sldv:Setup:CheckingCompatibilityFailed')));
        if obj.mShowUI
            obj.logNewLines(getString(message('Sldv:Setup:ReferDiagnosticsWindow')));
        end
        obj.errorHalt(true);

        obj.clearDiagnosticInterceptor();
        obj.mErrorMsg=sldvshareprivate('avtcgirunsupdialog',obj.mExtractedModelH,obj.mShowUI);
    end
end

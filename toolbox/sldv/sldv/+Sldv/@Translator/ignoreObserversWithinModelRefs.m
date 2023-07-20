function ignoreObserversWithinModelRefs(obj)












    if(0==slfeature('ObserverSLDV'))
        return;
    end
    session=sldvprivate('sldvGetActiveSession',obj.mRootModelH);
    if isempty(session)
        return;
    end


    mdlRefs=find_mdlrefs(obj.mExtractedModelH,'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices,'ReturnTopModelAsLastElement',false);
    try
        for idx=1:length(mdlRefs)
            if~bdIsLoaded(mdlRefs{idx})
                load_system(mdlRefs{idx});
                oc=onCleanup(@()close_system(mdlRefs{idx}));
            end
            obsRefBlks=Simulink.observer.internal.getObserverRefBlocksInBD(get_param(mdlRefs{idx},'Handle'));
            if~isempty(obsRefBlks)

                msgID='Sldv:Compatibility:ModelReferenceHasObserverReferenceBlocks';
                msg=getString(message(msgID,get_param(mdlRefs{idx},'Name')));
                sldvshareprivate('avtcgirunsupcollect','push',...
                obj.mExtractedModelH,'sldv_warning',msg,msgID);
                obj.clearDiagnosticInterceptor;
                sldvshareprivate('avtcgirunsupdialog',obj.mExtractedModelH,obj.mShowUI);
                obj.setDiagnosticInterceptor;






                sldvshareprivate('avtcgirunsupcollect','clear');
            end

            for i=1:numel(obsRefBlks)
                observerModel=get_param(obsRefBlks(i),'ObserverModelName');
                if~bdIsLoaded(observerModel)


                    load_system(observerModel);
                end
                obsMdlH=get_param(observerModel,'Handle');
                session.addToIncompatObserverList(obsMdlH);
                obj.mCompatObserverModelHs(obj.mCompatObserverModelHs==obsMdlH)=[];
            end
        end
    catch MEx %#ok<NASGU> 
    end
end

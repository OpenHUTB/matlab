function[observerModelNames,isObserverPreLoaded,errMsg,errID]=loadObserverModelsForBD(modelH,standaloneMode)






    if nargin<2
        standaloneMode=true;
    end
    errMsg='';
    errID='';

    obsRefBlks=Simulink.observer.internal.getObserverRefBlocksInBD(modelH);

    observerModelHs=cell(1,numel(obsRefBlks));
    observerModelNames=cell(1,numel(obsRefBlks));
    isObserverPreLoaded=zeros(1,numel(obsRefBlks));

    for i=1:numel(obsRefBlks)
        observerModelNames{i}=get_param(obsRefBlks(i),'ObserverModelName');
        isObserverPreLoaded(i)=bdIsLoaded(observerModelNames{i});

        try
            observerModelHs{i}=load_system(observerModelNames{i});
        catch MEx
            errID=MEx.identifier;
            errMsg=MEx.message;
            return;
        end

        try
            contextBlk=Simulink.observer.internal.getContextForBlockInObsMdl(observerModelHs{i});


            if~isequal(contextBlk,-1)&&~isequal(contextBlk,obsRefBlks(i))
                errID='Sldv:Observer:CtxMdlAlreadyOpenInAnotherContext';
                errMsg=getString(message(errID,observerModelNames{i},getfullname(contextBlk)));
                if~standaloneMode&&i>1




                    switchContextOnError(observerModelHs(1:i-1),obsRefBlks(1:i-1));
                end
                return;
            end

            if~standaloneMode&&isequal(contextBlk,-1)

                Simulink.sltblkmap.internal.convertStandaloneMdlToContexted(observerModelHs{i},obsRefBlks(i));
            end
        catch MEx
            errID=MEx.identifier;
            errMsg=MEx.message;
            return;
        end
    end
end

function switchContextOnError(obsMdlHs,obsRefBlks)
    for currMdl=1:length(obsMdlHs)
        Simulink.sltblkmap.internal.convertContextedMdlToStandalone(obsMdlHs{currMdl},obsRefBlks(currMdl));
    end
end
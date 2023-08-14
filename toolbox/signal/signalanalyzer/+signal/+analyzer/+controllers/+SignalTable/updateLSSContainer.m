function flag=updateLSSContainer(data)




    flag=true;
    eng=Simulink.sdi.Instance.engine;
    clientID=data.clientID;
    selectedViewIndices=data.selectedViewIndices;
    selectedSigIDs=signal.sigappsshared.SignalUtilities.getSelectedSignalIDs(eng,clientID,selectedViewIndices);

    matname=signal.sigappsshared.SignalUtilities.getStorageLSSFilename();
    if exist(matname,'file')==2
        m=matfile(matname,'Writable',true);

        for idx=1:numel(selectedSigIDs)
            if strcmp(eng.getSignalTmMode(selectedSigIDs(idx)),'inherentLabeledSignalSet')
                lssKey=signal.sigappsshared.SignalUtilities.getKeyLabeledSignalSet(eng,selectedSigIDs(idx));
                if~isempty(lssKey)
                    m.(lssKey)=NaN;
                end
            end
        end
    end
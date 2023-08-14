function duplicateSignalTransaction(runIDs,sigIDs)





    eng=Simulink.sdi.Instance.engine;


    if(~isempty(runIDs))
        safeTransaction(eng,@handleDuplicateSignalTransaction,eng,runIDs,sigIDs);
    end


    if signal.analyzer.Instance.isSDIRunning()
        if~eng.dirty
            eng.dirty=true;
            gui=signal.analyzer.Instance.gui();
            gui.updateSessionInfo();
        end
    end


    message.publish('/sdi2/signalCreationCompleted','');
end


function handleDuplicateSignalTransaction(eng,runIDs,sigIDs)



    matname=signal.sigappsshared.SignalUtilities.getStorageLSSFilename();
    m=[];
    for idx=1:length(sigIDs)
        sigID=sigIDs(idx);


        if strcmp(eng.getSignalTmMode(sigID),'inherentLabeledSignalSet')&&exist(matname,'file')==2
            if isempty(m)
                m=matfile(matname,'Writable',true);
            end


            lssKey=signal.sigappsshared.SignalUtilities.getKeyLabeledSignalSet(eng,sigID);
            if isempty(lssKey)||~isprop(m,lssKey)
                continue;
            end
            storedLW=m.(lssKey);




            newKey=regexprep(tempname('_'),'_|\\|/','');
            while isprop(m,newKey)
                newKey=regexprep(tempname('_'),'_|\\|/','');
            end


            memberIDs=string(eng.getSignalChildren(sigID));
            memberIDs=memberIDs(:);
            setMemberNames(storedLW,memberIDs);


            m.(newKey)=storedLW;



            allIDs=[sigID;signal.sigappsshared.SignalUtilities.recurseGetAllChildren(eng,sigID)];
            for aIdx=1:length(allIDs)
                signal.sigappsshared.SignalUtilities.setKeyLabeledSignalSet(eng,allIDs(aIdx),newKey);
            end
        end
    end

    runIDs=unique(runIDs);
    for idx=1:length(runIDs)
        runID=runIDs(idx);
        signal.analyzer.SignalUtilities.notifySignalsInsertedEvent(runID);
    end
end
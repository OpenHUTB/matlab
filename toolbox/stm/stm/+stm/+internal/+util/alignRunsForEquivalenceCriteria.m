function[removeSignalsFromRun1,notFoundInRun1]=alignRunsForEquivalenceCriteria(refRun,run1)








    eng=Simulink.sdi.Instance.engine;
    repo=sdi.Repository(1);



    algorithms=[Simulink.sdi.AlignType.DataSource
    Simulink.sdi.AlignType.BlockPath
    Simulink.sdi.AlignType.SID
    Simulink.sdi.AlignType.SignalName];
    EXPAND_MATRICES=true;


    Simulink.sdi.doAlignment(eng.sigRepository,refRun,run1,int32(algorithms),EXPAND_MATRICES);

    LHSSignalIDs=eng.getAllSignalIDs(refRun,'expanded leaf');
    numSignals=length(LHSSignalIDs);





    notFoundInRun1=int32(zeros(numSignals,1));
    notFoundInRun1Counter=0;


    foundInRun1=int32(zeros(numSignals,1));
    foundInRun1Counter=0;

    for i=1:numSignals

        lhsSignalID=LHSSignalIDs(i);
        rhsSignalID=Simulink.sdi.getAlignedID(lhsSignalID);



        if isempty(rhsSignalID)

            notFoundInRun1Counter=notFoundInRun1Counter+1;
            notFoundInRun1(notFoundInRun1Counter)=lhsSignalID;
        else

            foundInRun1Counter=foundInRun1Counter+1;
            foundInRun1(foundInRun1Counter)=rhsSignalID;


            absTol=eng.getSignalAbsTol(lhsSignalID);
            leadingTol=repo.getSignalForwardTimeTol(lhsSignalID);
            laggingTol=repo.getSignalBackwardTimeTol(lhsSignalID);
            relTol=eng.getSignalRelTol(lhsSignalID);
            interp=eng.getSignalInterpMethod(lhsSignalID);
            sync=eng.getSignalSyncMethod(lhsSignalID);

            eng.setSignalAbsTol(rhsSignalID,absTol);
            eng.setSignalRelTol(rhsSignalID,relTol);
            eng.setSignalInterpMethod(rhsSignalID,interp);
            eng.setSignalSyncMethod(rhsSignalID,sync);
            repo.setSignalForwardTimeTol(rhsSignalID,leadingTol);
            repo.setSignalBackwardTimeTol(rhsSignalID,laggingTol);
        end
    end


    if(notFoundInRun1Counter<numSignals)
        notFoundInRun1(notFoundInRun1Counter+1:end)=[];
    end

    if(foundInRun1Counter<numSignals)
        foundInRun1(foundInRun1Counter+1:end)=[];
    end



    signalsInRun1=eng.getAllSignalIDs(run1,'all saved');


    removeSignalsFromRun1=setdiff(signalsInRun1,foundInRun1);


    for i=1:length(foundInRun1)
        removeSignalsFromRun1=filterParentSignals(eng,foundInRun1(i),removeSignalsFromRun1);
    end
end

function removeSignalsFromRun1=filterParentSignals(eng,id,removeSignalsFromRun1)
    parentID=eng.getSignalParent(id);
    if(parentID>0)
        removeSignalsFromRun1(removeSignalsFromRun1==parentID)=[];


        if eng.sigRepository.getSignalComplexityAndLeafPath(parentID).IsComplex

            sigIDToFilter=setdiff(eng.getSignalChildren(parentID),id);
            removeSignalsFromRun1(removeSignalsFromRun1==sigIDToFilter)=[];
        end
        removeSignalsFromRun1=filterParentSignals(eng,parentID,removeSignalsFromRun1);
    end
end

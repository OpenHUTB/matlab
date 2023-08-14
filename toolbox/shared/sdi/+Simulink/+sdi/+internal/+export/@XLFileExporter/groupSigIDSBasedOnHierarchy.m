function retSigIDs=groupSigIDSBasedOnHierarchy(~,eng,sigIDs)





    retSigIDs=[];
    for i=1:length(sigIDs)
        currSigID=sigIDs(i);
        if(find(retSigIDs==currSigID))
            continue;
        end
        currSig=Simulink.sdi.getSignal(currSigID);
        dims=currSig.Dimensions;
        if isnumeric(dims)&&max(dims)>1
            parentSigID=eng.sigRepository.getSignalParent(currSigID);
            parentSig=Simulink.sdi.getSignal(parentSigID);
            childrenSigIDs=eng.sigRepository.getSignalChildren(parentSigID);
            if strcmpi(parentSig.Complexity,'complex')
                childrenSigIDs=childrenSigIDs(1);
            end
            retSigIDs=[retSigIDs,childrenSigIDs];%#ok
        else
            retSigIDs=[retSigIDs,currSigID];%#ok
        end
    end
end

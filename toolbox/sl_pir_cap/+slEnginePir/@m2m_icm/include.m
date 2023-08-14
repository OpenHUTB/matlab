function msg=include(this,aBlk)



    try
        blkSID=Simulink.ID.getSID(aBlk);
        if isKey(this.fObj2IdxMap,blkSID)
            candIdx=this.fObj2IdxMap(blkSID);
            this.fCandidateInfo(candIdx(1)).Objects(candIdx(2)).isExcluded=0;
            objInfo=this.fCandidateInfo(candIdx(1)).Objects(candIdx(2));
            includedSIDs={};
            includedSIDs=[includedSIDs;objInfo.DSM];
            includedSIDs=[includedSIDs;{objInfo.FcnCalls.LinkedSS}'];
            includedSIDs=[includedSIDs;objInfo.GetCalls];
            includedSIDs=[includedSIDs;objInfo.SetCalls];
            disp('Following candidate blocks are added into transformation:');
            msg={};
            for bIdx=1:length(includedSIDs)
                msg=[msg;{getfullname(includedSIDs{bIdx})}];%#ok
            end
        else
            msg=['''',char(aBlk),''' is not a candidate. Nothing is added to transformation'];
        end
    catch
        msg=['''',char(aBlk),''' is not a valid block. Nothing is added to tranformation'];
    end
end

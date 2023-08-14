function msg=exclude(this,aBlk)



    msg=[];
    try
        blkSID=Simulink.ID.getSID(aBlk);
        if isKey(this.fObj2IdxMap,blkSID)
            candIdx=this.fObj2IdxMap(blkSID);
            this.fCandidateInfo(candIdx(1)).Objects(candIdx(2)).isExcluded=1;
            objInfo=this.fCandidateInfo(candIdx(1)).Objects(candIdx(2));
            excludedSIDs={};
            excludedSIDs=[excludedSIDs;objInfo.DSM];
            excludedSIDs=[excludedSIDs;{objInfo.FcnCalls.LinkedSS}'];
            excludedSIDs=[excludedSIDs;objInfo.GetCalls];
            excludedSIDs=[excludedSIDs;objInfo.SetCalls];
            disp('Following candidate blocks are excluded from transformation:');
            msg={};
            for bIdx=1:length(excludedSIDs)
                msg=[msg;{getfullname(excludedSIDs{bIdx})}];%#ok
            end
        else
            msg=['''',char(aBlk),''' is not a candidate. Nothing is excluded.'];
        end
    catch
        msg=['''',char(aBlk),''' is not a valid block. Nothing is excluded.'];
    end
end

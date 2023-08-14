function changed_datasetIdxVec=peaksUpdateLocationList(p,forceDatasetIdx)














    [changed_datasetIdxVec,changed_isZero]=findPeaksPropertyChanges(p,forceDatasetIdx);

    del_idx=[];
    Nc=numel(changed_datasetIdxVec);
    if Nc>0



        peaksLocList=p.pPeakLocationList;
        NLoc=numel(peaksLocList);
        for i=1:Nc
            ds_idx=changed_datasetIdxVec(i);
            if changed_isZero(i)


                peaksIdx=[];
            else

                peaksIdx=peaks(p,ds_idx);












                if(NLoc>=ds_idx)&&isequal(peaksIdx,peaksLocList{ds_idx})
                    del_idx=[del_idx,i];%#ok<AGROW>
                end
            end
            peaksLocList{ds_idx}=peaksIdx;
        end
        p.pPeakLocationList=peaksLocList;


        changed_datasetIdxVec(del_idx)=[];

    end

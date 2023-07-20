














function postProcessReqSet(this,mfReqSet)

    mfReqSet.uniquifyAllCustomIds(slreq.datamodel.CustomIdNumbering.SID);
    locResetReqEditorTypesForOldVersion(mfReqSet);
    setIsLockedStatus(mfReqSet);
end


function locResetReqEditorTypesForOldVersion(mfReqSet)










    if ismember(mfReqSet.MATLABVersion,{'(R2017b)','(R2018a)'})
        mfReqs=mfReqSet.items.toArray;
        for index=1:length(mfReqs)
            cmfReq=mfReqs(index);
            cmfReq.descriptionEditorType='';
            cmfReq.rationaleEditorType='';
        end
    end
end



function setIsLockedStatus(mfReqSet)
    if contains(mfReqSet.MATLABVersion,{'(R2017b)','(R2018a)','(R2018b)'})
        mfItems=mfReqSet.rootItems.toArray;
        for n=1:length(mfItems)
            mfItem=mfItems(n);
            if isa(mfItem,'slreq.datamodel.ExternalRequirement')
                mfItem.setLockedRecursively(true);
            end
        end
    end
end


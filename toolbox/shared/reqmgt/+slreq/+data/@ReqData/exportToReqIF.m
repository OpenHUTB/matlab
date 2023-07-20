
function[mfReqIf,mfReqIfModel]=exportToReqIF(this,dataReqSet,dataRootItem,mapping)





    mfReqSet=dataReqSet.getModelObj();
    if~isempty(dataRootItem)
        mfRootItem=dataRootItem.getModelObj();
    else
        mfRootItem=slreq.datamodel.ExternalRequirement.empty();
    end


    mfReqIfModel=mf.zero.Model();
    adapter=slreq.datamodel.ReqIFAdapter(mfReqIfModel);
    mfReqIf=adapter.exportToReqIf(mfReqSet,mfRootItem,mapping);


    adapter.destroy();
end

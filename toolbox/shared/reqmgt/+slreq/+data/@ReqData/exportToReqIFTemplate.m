
function[mfReqIf,mfReqIfModel]=exportToReqIFTemplate(this,dataReqSet,dataRootItem,mfTemplate,mapping,linkOptions)





    if nargin<6

        linkOptions=struct('exportLinks',true,'minimalAttributes',false);
    end


    this.preProcessLinksForExport(dataReqSet);

    mfReqSet=dataReqSet.getModelObj();
    if~isempty(dataRootItem)
        mfRootItem=dataRootItem.getModelObj();
    else
        mfRootItem=slreq.datamodel.ExternalRequirement.empty();
    end

    mfReqIfModel=mf.zero.Model();



    artifact=dataReqSet.filepath;
    domain='linktype_rmi_slreq';



    dataOutLinkSet=this.getLinkSet(artifact,domain);

    mfAdapter=slreq.datamodel.ReqIFAdapter(mfReqIfModel);


    if~isempty(dataOutLinkSet)
        mfAdapter.linkSet=dataOutLinkSet.getModelObj();
    end

    mfAdapter.exportLinks=linkOptions.exportLinks;
    mfAdapter.minimalAttributes=linkOptions.minimalAttributes;

    dataLinkSets=this.getLoadedLinkSets();
    if~isempty(dataLinkSets)
        for n=1:length(dataLinkSets)



            slreq.internal.addCustomAttributes(dataLinkSets(n),mapping);
        end
    end

    mfReqIf=mfAdapter.exportToReqIfFromTemplate(mfReqSet,mfRootItem,mfTemplate,mapping);


    mfAdapter.destroy();
end















function xml=prepareReqIFtemplate(mf0Xml)

    reqData=slreq.data.ReqData.getInstance();


    [mfReqIf]=reqData.importReqIFTemplate(mf0Xml,slreq.datamodel.MappingOptions.empty());


    mfSpecObjects=mfReqIf.coreContent.specObjects.toArray();
    for ii=1:length(mfSpecObjects)
        mfSpecObjects(ii).destroy();
    end


    mfSpecs=mfReqIf.coreContent.specifications.toArray();
    for ii=1:length(mfSpecs)
        mfSpecs(ii).destroy();
    end


    mfRelations=mfReqIf.coreContent.specRelations.toArray();
    for ii=1:length(mfRelations)
        mfRelations(ii).destroy();
    end


    mfRelationGroups=mfReqIf.coreContent.specRelationGroups.toArray();
    for ii=1:length(mfRelationGroups)
        mfRelationGroups(ii).destroy();
    end




    mfSpecTypes=mfReqIf.coreContent.specTypes.toArray();
    for ii=1:length(mfSpecTypes)
        if isa(mfSpecTypes(ii),'slreq.reqif.RelationGroupType')
            mfSpecTypes(ii).destroy();
        end
    end










    [xml,~]=reqData.serializeReqIF(mfReqIf);


    [templateFile,~,~]=slreq.internal.getReqIFTemplateName();
    slreq.utils.writeToXML(templateFile,xml);




    mfReqIf.destroy();
end


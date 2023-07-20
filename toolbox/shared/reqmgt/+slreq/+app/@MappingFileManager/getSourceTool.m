




function[info,mappingXml,errorDetails]=getSourceTool(this,srcDoc)

    errorDetails='';


    mappingXml='';

    info=[];
    specNames={};


    [~,~,fExt]=fileparts(srcDoc);
    if strcmpi(fExt,'.reqifz')
        try
            srcDoc=slreq.internal.scratchUnzipReqIF(srcDoc);
        catch ex

            errorDetails=ex.message;

            return;
        end
    end

    mf0Xml=slreq.utils.readFromXML(srcDoc);
    if isempty(mf0Xml)

        return;
    end


    mfModel=mf.zero.Model();


    mfMapping=slreq.datamodel.MappingOptions(mfModel);
    mapRequirement=slreq.datamodel.MappedType(mfModel);





    mapRequirement.thisType='SpecObject';
    mapRequirement.thatType='RequirementItem';
    mfMapping.types.add(mapRequirement);
    mfAdapter=slreq.datamodel.ReqIFAdapter(mfModel);


    try
        mfReqIf=mfAdapter.importFromReqIf(mf0Xml,mfMapping);
    catch ex
        errorDetails=ex.message;
        mfReqIf=[];

    end

    if isempty(mfReqIf)


        mfModel.destroy();
        return;
    end




    sourceToolId=mfReqIf.theHeader.reqIfToolId;


    if isempty(sourceToolId)||startsWith(sourceToolId,'Data Exchange')


        sourceToolId=mfReqIf.theHeader.sourceToolId;
    end

    coreContent=mfReqIf.coreContent;
    if isempty(coreContent)
        return;
    end

    mfSpecs=coreContent.specifications.toArray();
    for idx=1:length(mfSpecs)
        mfSpec=mfSpecs(idx);
        specName=mfSpec.longName;

        specType=mfSpec.type;
        if~isempty(specType)
            specTypeName=specType.longName;

            if contains(specTypeName,'linktype_rmi_')
                continue;
            end
        end



        if isempty(specName)
            specName=mfSpec.identifier;
        end

        specNames{end+1}=specName;
    end


    mfRelationsSequence=coreContent.specRelations;
    hasLinks=false;
    if~isempty(mfRelationsSequence)
        hasLinks=(mfRelationsSequence.Size>0);
    end




    mfModel.destroy();

    info.sourceToolId=sourceToolId;
    info.specNames=specNames;
    info.hasLinks=hasLinks;




end













function[mappingFile,mapping,specName]=writeMappingToFile(docPath,mappingData)

    reqIFname=docPath;
    [~,~,fExt]=fileparts(reqIFname);
    if strcmpi(fExt,'.reqifz')
        reqifzName=reqIFname;
        reqIFname=slreq.internal.scratchUnzipReqIF(reqIFname);
    end

    mf0Xml=slreq.utils.readFromXML(reqIFname);
    if isempty(mf0Xml)
        error(message('Slvnv:slreq_import:FileNotFound',reqIFname));
    end


    mfReqIfModel=mf.zero.Model();
    adapter=slreq.datamodel.ReqIFAdapter(mfReqIfModel);



    mfReqIf=adapter.importFromReqIf(mf0Xml,slreq.datamodel.MappingOptions.empty());


    mapUUIDstoNames=containers.Map('KeyType','char','ValueType','char');
    specTypes=mfReqIf.coreContent.specTypes.toArray;
    for i=1:length(specTypes)
        specType=specTypes(i);

        if~isa(specType,'slreq.reqif.SpecObjectType')
            continue;
        end

        specAttributes=specType.specAttributes.toArray();
        for j=1:length(specAttributes)
            specAttribute=specAttributes(j);
            mapUUIDstoNames(specAttribute.identifier)=specAttribute.longName;
        end
    end

    specName=getSpecificationName(mfReqIf);


    mfReqIfModel.destroy();


    reqData=slreq.data.ReqData.getInstance();
    mapping=reqData.createMapping();
    mapping.name=specName;
    type=mapping.types.toArray;
    externalAttribs=keys(mappingData);


    helper=slreq.internal.MappingHelper();

    for i=1:length(externalAttribs)
        externalName=externalAttribs{i};

        mappedToAttrib=mappingData(externalName);


        if mapUUIDstoNames.isKey(externalName)
            externalName=mapUUIDstoNames(externalName);
        end



        internalName=helper.toInternalName(mappedToAttrib);

        if helper.isBuiltIn(internalName)

            internalType=helper.getBuiltInTypeEnum(internalName);

            entry=reqData.createMapToBuiltIn(...
            externalName,slreq.datamodel.AttributeTypeEnum.Any,...
            internalName,internalType);
        else

            entry=reqData.createMapToCustomAttribute(...
            externalName,slreq.datamodel.AttributeTypeEnum.Any,...
            mappedToAttrib,slreq.datamodel.AttributeTypeEnum.Any,false);
        end

        type.attributes.add(entry);
    end

    mappingFile=[tempname,'.xml'];
    reqData.saveMapping(mapping,mappingFile);
end





function out=getSpecificationName(mfReqIf,index)
    out='';

    if nargin<3

        index=1;
    end

    if~isempty(mfReqIf)
        coreContent=mfReqIf.coreContent;
        if~isempty(coreContent)
            specifications=coreContent.specifications;
            if index<=specifications.Size
                specification=specifications(index);
                out=specification.longName;
            end
        end
    end
end

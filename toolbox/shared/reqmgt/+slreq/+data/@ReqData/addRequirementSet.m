function mfReqSet=addRequirementSet(this,givenName)







    if~isempty(this.repository.findReqSetByShortName(givenName))
        reqSetShortName=slreq.uri.getShortNameExt(givenName);
        error(message('Slvnv:slreq:RequirementSetAlreadyLoaded',reqSetShortName));
    end


    [destPath,shortName,~]=fileparts(givenName);
    if~this.isReservedReqSetName(shortName)&&isempty(destPath)
        destPath=pwd;
    end
    ext='.slreqx';


    mfReqSet=slreq.datamodel.RequirementSet(this.model);
    mfReqSet.name=shortName;
    mfReqSet.filepath=fullfile(destPath,[shortName,ext]);



    mfReqSet.idPrefix=slreq.data.RequirementSet.defaultPrefix;
    mfReqSet.idDelimiter=slreq.data.RequirementSet.defaultDelimiter;
    mfReqSet.revision=0;
    mfReqSet.defaultTypeName=slreq.custom.RequirementType.Functional.getTypeName();
    this.updateModificationInfo(mfReqSet);

    mfReqSet.MATLABVersion=version;
    this.repository.requirementSets.add(mfReqSet);




end

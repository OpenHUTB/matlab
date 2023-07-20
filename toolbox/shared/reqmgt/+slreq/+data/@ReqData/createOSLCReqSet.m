function[mfReqSet,mfRootItem]=createOSLCReqSet(this,reqSetName,serviceName,projectInfo,topNodeInfo)





    mfReqSet=this.addRequirementSet(reqSetName);
    mfReqSet.createdOn=slreq.utils.getDateTime(datetime(),'Write');
    domain=[slreq.data.Requirement.OSLC_DOMAIN_PREFIX,serviceName];
    mfReqSet.setProperty('externalDomain',domain);
    mfReqSet.setProperty('serverName',projectInfo.serverName);
    mfReqSet.setProperty('projectName',projectInfo.name);
    mfReqSet.setProperty('projectUri',projectInfo.uri);
    mfReqSet.setProperty('serviceUri',projectInfo.serviceUri);
    mfReqSet.setProperty('queryBase',projectInfo.queryBase);


    sessionConfigUrl=oslc.getSessionConfigUri(projectInfo.name);
    mfReqSet.setProperty('configUri',sessionConfigUrl);


    reqInfo.domain=domain;
    reqInfo.typeName=slreq.custom.RequirementType.Container.char;
    reqInfo.id=topNodeInfo.id;
    reqInfo.summary=topNodeInfo.name;
    reqInfo.synchronizedOn=datetime('now','TimeZone','UTC');
    if strcmp(topNodeInfo.type,'module')
        reqInfo.artifactUri=topNodeInfo.uri;
    else
        reqInfo.artifactUri=topNodeInfo.params;
    end
    reqInfo.artifactId='';
    group=this.getGroup(reqInfo.artifactUri,domain,mfReqSet);
    reqInfo.group=group;
    rootItem=this.addExternalRequirement(this.wrap(mfReqSet),reqInfo);
    mfRootItem=this.getModelObj(rootItem);
    mfRootItem.createdOn=mfReqSet.createdOn;
    mfRootItem.createdBy=mfReqSet.createdBy;
    if~isempty(reqInfo.id)


        mfRootItem.sid=int32(str2num(reqInfo.id));%#ok<ST2NM>
        moduleLink=sprintf('<a href="%s">%s</a>',topNodeInfo.uri,topNodeInfo.name);
        projectLink=sprintf('<a href="%s">%s</a>',projectInfo.uri,projectInfo.name);
        mfRootItem.description=getString(message('Slvnv:slreq_import:DngModuleNameIn',moduleLink,projectLink));
    else



        mfRootItem.sid=0;
        mfRootItem.customId=topNodeInfo.params;
        mfRootItem.description=getString(message('Slvnv:slreq_import:DngRawQueryStringUsed',topNodeInfo.params));
    end
    mfRootItem.setProperty('importType',topNodeInfo.type);
    mfRootItem.modifiedBy=mfReqSet.modifiedBy;
    mfReqSet.modifiedOn=slreq.utils.getDateTime(datetime(),'Write');
    mfRootItem.modifiedOn=mfReqSet.modifiedOn;
    mfRootItem.synchronizedOn=mfRootItem.modifiedOn;
end

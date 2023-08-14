function[status,doorsInfo]=checkIncomingLink(slSource,obj,doc,id)




    status=false;
    doorsInfo=[doc,':',id];


    extLinks=rmidoors.getObjAttribute(doc,id,'ExternalLinks');

    usingIncomingLinks=rmipref('DoorsBacklinkIncoming');


    wantedDoorsLinkTypeFlag=~usingIncomingLinks;

    for i=1:size(extLinks,1)
        if extLinks{i,1}~=wantedDoorsLinkTypeFlag
            continue;
        end
        if isMatchedLink(extLinks{i,end},slSource,obj)
            status=true;
            return;
        end
    end

    childIds=rmidoors.getObjAttribute(doc,id,'ChildIds');
    for i=1:length(childIds)
        oneId=childIds{i};
        if~isscalar(oneId)


            continue;
        end
        if isMathworksReferenceObject(doc,oneId)
            navCmd=getNavCmdFromDoors(doc,oneId);
            if~isempty(navCmd)&&isMatchedNavCmd(navCmd,slSource,obj)
                status=true;
                return;
            end
        end
    end



    maxNameLength=40;
    doorsObjLabel=rmidoors.getObjAttribute(doc,id,'labelText');
    if length(doorsObjLabel)>maxNameLength
        doorsObjLabel=[doorsObjLabel(1:maxNameLength),'...'];
    end
    doorsNavCmd=['rmi.navigate(''linktype_rmi_doors'',''',doc,''',''',id,''');'];
    doorsNavLink=makeLink(doorsNavCmd,doorsObjLabel);
    doorsDocName=rmidoors.getModuleAttribute(doc,'Name');
    if length(doorsDocName)>maxNameLength
        doorsDocName=[doorsDocName(1:maxNameLength),'...'];
    end
    doorsInfo=sprintf('%s in %s',doorsNavLink,doorsDocName);
end

function hyperlink=makeLink(matlabCmd,label)
    hyperlink=['<a href="matlab:',matlabCmd,'">',label,'</a>'];
end

function yesno=isMathworksReferenceObject(doc,doorsId)
    objText=rmidoors.getObjAttribute(doc,doorsId,'Object Text');
    yesno=false||...
    strncmp(objText,'[Simulink reference: ',length('[Simulink reference: '))||...
    strncmp(objText,'[MATLAB reference: ',length('[MATLAB reference: '));
end

function navCmd=getNavCmdFromDoors(doc,doorsId)
    navCmd=rmidoors.getObjAttribute(doc,doorsId,'DmiSlNavCmd');
end

function yesno=isMatchedNavCmd(navCmd,mdlName,objH)

    if strncmp(navCmd,'rmiobjnavigate(',length('rmiobjnavigate('))

        match=regexp(navCmd,'''([^'']+)''','tokens');
        if isempty(match)
            yesno=false;
        else

            [~,mdlFileName]=fileparts(match{1}{1});
            if~strcmp(mdlName,mdlFileName)
                yesno=false;
            else

                for i=2:length(match)
                    objId=match{i}{1};
                    if objId(1)==':'
                        yesno=isMatchedSid(objH,mdlName,objId);
                    else
                        yesno=isMatchedGuid(objH,mdlName,objId);
                    end
                    if yesno
                        return;
                    end
                end
                yesno=false;
            end
        end
    else

        match=regexp(navCmd,'rmicodenavigate(''([^'']+)'',''([^'']+)''','tokens');


        if isempty(match)
            yesno=false;
        else
            [~,mFileName]=fileparts(match{1}{1});
            [~,givenFileName]=fileparts(mdlName);
            if~strcmp(mFileName,givenFileName)
                yesno=false;
            else
                yesno=strcmp(objH,match{1}{2});
            end
        end
    end
end

function yesno=isMatchedLink(connectorUrl,slSrc,slId)












    if contains(connectorUrl,'rmi.navigate')
        first=2;
    else
        first=1;
    end

    yesno=false;
    [~,slSrcName]=fileparts(slSrc);
    if isempty(slId)||(isnumeric(slId)&&get_param(slSrcName,'Handle')==slId)


        match=regexp(connectorUrl,'%22(.*?)%22','tokens');
        isTopDiagram=true;
    else
        match=regexp(connectorUrl,'%22(.+?)%22','tokens');
        isTopDiagram=false;
    end
    if isempty(match)
        return;
    end

    mdlFile=strrep(match{first}{1},'%5C%5C','\');
    if any(mdlFile(3:end)==':')

        if~strcmp(slSrc,mdlFile)
            return;
        end
        yesno=strcmp(match{first+1}{1},slId);
    else


        [~,srcName]=fileparts(mdlFile);

        if~strcmp(slSrcName,srcName)
            return;
        end




        if isTopDiagram
            yesno=isempty(match{first+1}{1});
        else
            for i=first+1:length(match)
                objId=match{i}{1};
                if objId(1)==':'
                    if isMatchedSid(slId,slSrc,objId)
                        yesno=true;
                        return;
                    end
                elseif any(objId=='.')
                    yesno=strcmp(objId,slId);
                    return;
                elseif strcmp(objId,'_suppress_browser')
                    break;
                elseif isMatchedGuid(slId,slSrc,objId)
                    yesno=true;
                    return;
                else
                    continue;
                end
            end

            yesno=false;
        end
    end
end

function yesno=isMatchedSid(slsfId,mdlName,storedId)
    if isnumeric(slsfId)
        [modelName,objKey]=rmidata.getRmiKeys(slsfId,(floor(slsfId)==slsfId));
        yesno=strcmp(modelName,mdlName)&&strcmp(objKey,storedId);
    else
        yesno=strcmp(slsfId,storedId);
    end
end

function yesno=isMatchedGuid(obj,mdlName,objGuid)
    if isnumeric(obj)

        modelH=get_param(mdlName,'Handle');
        objH=rmisl.guidlookup(modelH,objGuid);
        yesno=(~isempty(objH)&&objH==obj);
    else

        yesno=strcmp(obj,objGuid);
    end
end


function contextData=getRecentContextsByType(projName,type,connectionObj)





    if nargin<3
        connectionObj=oslc.connection();
    end


    javaProjName=char(connectionObj.getProject());
    if isempty(javaProjName)||~strcmp(javaProjName,projName)
        connectionObj.setProject(projName);
    end



    projObj=oslc.Project.get(projName);
    projURL=projObj.url;


    matched=regexp(projURL,'oslc_rm/([\w\-]+)/services.xml','tokens');
    if isempty(matched)
        error('unexpected format string returned for service URL');
    end
    projID=matched{1}{1};


    if any(strcmp(type,{'changeset','stream','baseline'}))
        jArray=connectionObj.getRecentConfigsByType(type);
    else
        error('Unsupported context type: %s',type);
    end
    totalItems=numel(jArray);
    contextData=cell(totalItems,2);
    if totalItems>0
        skip=false(totalItems,1);


        tag=['/cm/',type,'/'];
        changesetTagLength=length(tag);
        for i=1:totalItems
            oneLine=strrep(char(jArray(i)),'\/','/');
            csIdx=strfind(oneLine,tag);
            if isempty(csIdx)
                skip(i)=true;
            else
                sepIdx=find(oneLine(csIdx(1)+changesetTagLength:end)=='/');
                if isempty(sepIdx)
                    contextUri=oneLine;
                else
                    endOfContextID=csIdx(1)+changesetTagLength+sepIdx(1)-1;
                    contextUri=oneLine(1:endOfContextID-1);
                end
                if any(strcmp(contextUri,contextData(:,1)))
                    skip(i)=true;
                else
                    contextData{i,1}=contextUri;
                end
            end
        end
        if any(skip)
            contextData(skip,:)=[];
        end
        count=size(contextData,1);
        for i=count:-1:1
            contextData{i,2}=getContextName(contextData{i,1},connectionObj,projID);
            if isempty(contextData{i,2})
                contextData(i,:)=[];
            end
        end
    end
end

function contextName=getContextName(contextID,connectionObj,projID)
    rdf=char(connectionObj.get(contextID));
    providerURI=oslc.parseValue(rdf,'oslc:serviceProvider rdf:resource=');
    if contains(providerURI,projID)
        contextName=oslc.getTitle(rdf,'dcterms');
    else
        contextName='';
    end
end

function navigateToPolarion(arg)
























    persistent serverUrlConfirmed projectIdConfirmed
    if isempty(serverUrlConfirmed)
        serverUrlConfirmed=false;
    end
    if isempty(projectIdConfirmed)
        projectIdConfirmed=false;
    end

    if islogical(arg)


        serverUrlConfirmed=arg;
        projectIdConfirmed=arg;
        return;
    end


    if~isa(arg,'slreq.Reference')
        error(message('Slvnv:rmipref:InvalidInput',class(arg),'refObj'));
    end


    refObj=arg;





    itemId=refObj.CustomId;
    if isempty(itemId)
        error(message('Slvnv:polarion:ItemIdNotSpecified'));
    end


    serverUrl=rmipref('PolarionServerAddress');
    if~serverUrlConfirmed||isempty(serverUrl)
        serverUrl=promptForServerUrl(serverUrl);
    end
    if isempty(serverUrl)
        serverUrlConfirmed=false;
        return;
    else
        serverUrlConfirmed=true;
    end



    projectId=getProjectIdFromImportNode(refObj);

    if isempty(projectId)
        projectId=rmipref('PolarionProjectId');
        isUserInput=false;
        if~projectIdConfirmed||isempty(projectId)
            projectId=promptForProjectId(projectId);
            isUserInput=true;
        end
        if isempty(projectId)
            projectIdConfirmed=false;
            return;
        else
            if isUserInput

                setProjectIdForImportNode(refObj,projectId);
            end
            projectIdConfirmed=true;
        end
    end


    url=[serverUrl,'/polarion/#/project/',projectId,'/workitem?id=',itemId];
    web(url,'-browser');
end

function projId=getProjectIdFromImportNode(refObj)
    while~isa(refObj.parent,'slreq.ReqSet')
        refObj=refObj.parent;
    end
    projId=refObj.getInternalAttribute('projectId');
end

function setProjectIdForImportNode(refObj,value)
    while~isa(refObj.parent,'slreq.ReqSet')
        refObj=refObj.parent;
    end
    refObj.setInternalAttribute('projectId',value);
end

function result=promptForServerUrl(stored)
    result='';
    while isempty(result)
        questionStr=[getString(message('Slvnv:polarion:IncludeProtocolPrefix'))...
        ,newline,getString(message('Slvnv:polarion:IncludePortNumber'))];
        questionTitle=getString(message('Slvnv:polarion:ServerUrlPromptTitle'));
        userInput=inputdlg(questionStr,questionTitle,1,{stored});
        if isempty(userInput)||isempty(strtrim(userInput{1}))

            return;
        else
            result=strtrim(userInput{1});
            if strncmp(result,'http://',length('http://'))||...
                strncmp(result,'https://',length('https://'))
                if result(end)=='/'
                    result(end)=[];
                end
                if~strcmp(result,stored)
                    rmipref('PolarionServerAddress',result);
                end
            end
        end
    end
end

function result=promptForProjectId(stored)
    result='';
    while isempty(result)
        questionStr=getString(message('Slvnv:polarion:SpecifyProjectID'));
        questionTitle=getString(message('Slvnv:polarion:ProjectIdPromptTitle'));
        userInput=inputdlg(questionStr,questionTitle,1,{stored});
        if isempty(userInput)||isempty(strtrim(userInput{1}))

            return;
        else
            result=strtrim(userInput{1});
            if~isempty(result)&&~any(result==' ')
                result=strrep(result,'/','');
                if~strcmp(result,stored)
                    rmipref('PolarionProjectId',result);
                end
            end
        end
    end
end




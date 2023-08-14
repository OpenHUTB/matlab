function navigateToDOORS(arg)
















    persistent moduleIdConfirmed
    if isempty(moduleIdConfirmed)
        moduleIdConfirmed=false;
    end

    if islogical(arg)


        moduleIdConfirmed=arg;
        return;
    end


    if~isa(arg,'slreq.Reference')
        error(message('Slvnv:rmipref:InvalidInput',class(arg),'refObj'));
    end


    refObj=arg;


    doorsObjId=refObj.CustomId;
    if isempty(doorsObjId)
        error(message('Slvnv:polarion:ItemIdNotSpecified'));
    end



    moduleId=getModuleIdFromImportNode(refObj);

    if isempty(moduleId)
        moduleId=rmipref('DoorsModuleID');
        isUserInput=false;
        if~moduleIdConfirmed||isempty(moduleId)
            moduleId=promptForModuleId(moduleId);
            isUserInput=true;
        end
        if isempty(moduleId)
            moduleIdConfirmed=false;
            return;
        else
            if isUserInput

                setModuleIdForImportNode(refObj,moduleId);
            end
            moduleIdConfirmed=true;
        end
    end


    rmi.navigate('linktype_rmi_doors',moduleId,doorsObjId);
end

function projId=getModuleIdFromImportNode(refObj)
    while~isa(refObj.parent,'slreq.ReqSet')
        refObj=refObj.parent;
    end
    projId=refObj.getInternalAttribute('moduleId');
end

function setModuleIdForImportNode(refObj,value)
    while~isa(refObj.parent,'slreq.ReqSet')
        refObj=refObj.parent;
    end
    refObj.setInternalAttribute('moduleId',value);
end

function result=promptForModuleId(stored)
    result='';
    if isempty(stored)

        currentModuleId=rmidoors.getCurrentObj();
        if~isempty(currentModuleId)
            stored=currentModuleId;
        end
    end
    while isempty(result)
        questionStr=getString(message('Slvnv:reqmgt:linktype_rmi_doors:SpecifyModuleID'));
        questionTitle=getString(message('Slvnv:reqmgt:linktype_rmi_doors:DOORSModuleID'));
        userInput=inputdlg(questionStr,questionTitle,1,{stored});
        if isempty(userInput)||isempty(strtrim(userInput{1}))

            return;
        else
            result=strtrim(userInput{1});
            if~isempty(result)&&~any(result==' ')
                result=strrep(result,'/','');
                if~strcmp(result,stored)
                    rmipref('DoorsModuleID',result);
                end
            end
        end
    end
end




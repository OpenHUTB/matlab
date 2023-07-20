function optObj=findOptionsObject(h,mdlName)






    optObj=find(h,...
    '-depth',1,...
    'Active',1,...
    'RuntimeMdlName',mdlName);

    if isempty(optObj)
        optObj=find(h,...
        '-depth',1,...
        'Active',1,...
        'RuntimeMdlName','DEFAULT');
    end

    if isempty(optObj)

        activeObjs=find(h.LoopList,...
        '-depth',1,...
        'Active',1);
        nObjs=length(activeObjs);
        for k=1:nObjs
            currObj=activeObjs(k);
            try


                refMdlNames=find_mdlrefs(currObj.RuntimeMdlName,'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices);
            catch
                continue
            end
            if ismember(mdlName,refMdlNames)
                optObj=currObj;
                break;
            end
        end
    else



        nObjs=length(optObj);
        for k=1:nObjs
            currObj=optObj(k);
            modelNames=currObj.getModelNames();
            nModels=length(modelNames);

            for i=1:nModels
                if strcmp(modelNames{i},mdlName)
                    optObj=currObj;
                    return;
                end
            end
        end
        optObj=[];
    end

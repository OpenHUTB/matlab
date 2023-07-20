






















function closeRequirementsManager(modelName)

    if builtin('_license_checkout','SIMULINK','quiet')||...
        builtin('_license_checkout','Simulink_Requirements','quiet')
        throwAsCaller(MException(message('Slvnv:slreq:SimulinkRequirementsNoLicense')));
    end

    if nargin==0||~isValidArg(modelName)
        error(message('Slvnv:slreq:ErrorEnterPerspectiveInvalidInputArgument'));
    end

    if isstring(modelName)
        modelName=convertStringsToChars(modelName);
    end



    if ischar(modelName)&&strcmpi(modelName,'all')

        closeAllReqManagers();
        return;
    end

    mgr=slreq.app.MainManager.getInstance();

    if isempty(mgr.perspectiveManager)
        mgr.initPerspective();
    end

    pMgr=mgr.perspectiveManager;

    try
        [studio,rootModelH]=pMgr.checkModelBeforeTogglingPerspective(modelName);
    catch ex
        throwAsCaller(ex);
    end

    if slreq.utils.isInPerspective(rootModelH,true)
        try
            mgr=slreq.app.MainManager.getInstance();
            pMgr=mgr.perspectiveManager;
            pMgr.togglePerspective(studio,true);

            studio.raise;
        catch ex
            throwAsCaller(ex);

        end
    else


        studio.raise;
    end
end

function isValid=isValidArg(modelName)
    isValid=true;
    if isnumeric(modelName)
        if ishandle(modelName)
        else
            isValid=false;
        end
    elseif ischar(modelName)||isstring(modelName)
        if isempty(convertStringsToChars(modelName))
            isValid=false;
        end
    else
        isValid=false;
    end
end

function closeAllReqManagers()
    allStudios=DAS.Studio.getAllStudiosSortedByMostRecentlyActive;
    mgr=[];

    failedModelHandle=[];

    for index=1:length(allStudios)
        cStudio=allStudios(index);
        rootModelHandle=cStudio.App.blockDiagramHandle;
        if slreq.utils.isInPerspective(rootModelHandle,true)
            try
                if isempty(mgr)


                    mgr=slreq.app.MainManager.getInstance();
                    pMgr=mgr.perspectiveManager;
                end
                pMgr.togglePerspective(cStudio,true);

            catch ex %#ok<NASGU>


                failedModelHandle(end+1)=rootModelHandle;%#ok<AGROW>
            end
        end
    end

    if~isempty(failedModelHandle)


        if length(failedModelHandle)==1
            allModelNames=getfullname(failedModelHandle);
        else
            allModelNames=strjoin(getfullname(failedModelHandle),', ');
        end
        rmiut.warnNoBacktrace('Slvnv:slreq:ErrorExistPerspectiveViaAPI',allModelNames);
    end
end
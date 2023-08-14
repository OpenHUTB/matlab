













function openRequirementsManager(modelName)

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


        studio.raise;
    else

        try
            pMgr.togglePerspective(studio,true);
            studio.raise;
        catch ex
            throwAsCaller(ex);
        end
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
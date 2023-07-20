


function codeInspectorCB(userinfo,cbinfo)

    if slcifeature('CodeReviewTool')
        slci.toolstrip.toggleCodeInspectorAppCB(userinfo,cbinfo);
    else
        mdlObj=cbinfo.uiObject;
        while~strcmpi(class(mdlObj.getParent),'Simulink.Root')
            mdlObj=mdlObj.getParent;
        end
        mdlName=mdlObj.getFullName;
        config=slci.Configuration.loadObjFromFile(mdlName);
        if isempty(config)
            config=slci.Configuration(mdlName);
        end
        config.show();
    end
end

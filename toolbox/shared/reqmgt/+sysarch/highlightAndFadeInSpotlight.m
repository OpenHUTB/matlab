function highlightAndFadeInSpotlight(modelName,id,studio)


    messageId=strcat(modelName,'SpotlightNonExistElement');
    editor=studio.App.getActiveEditor();
    editor.closeNotificationByMsgID(messageId);

    if~isempty(id)&&sysarch.isZCElement(id)

        semElem=sysarch.resolveZCElement(id,modelName);


        if~isa(semElem,'systemcomposer.architecture.model.design.Port')

            sysarch.navigate(id,modelName);
            return;
        end

    else

        try
            objH=Simulink.ID.getHandle([modelName,id]);
        catch ex %#ok<NASGU>
            errordlg(getString(message('Slvnv:slreq:InvalidSimulinkItem',modelName)),getString(message('Slvnv:rmi:navigate:NavigationError')));
            return;
        end


        semElem=systemcomposer.utils.getArchitecturePeer(objH);
    end


    if isa(semElem,'systemcomposer.architecture.model.design.ArchitecturePort')
        semElem=semElem.getParentComponentPort();
    end


    if~isempty(semElem)
        modelHandle=get_param(modelName,'Handle');
        appMgr=Simulink.SystemArchitecture.internal.ApplicationManager.getAppMgrFromBDHandle(modelHandle);
        if(existInSpotlight(appMgr,semElem,studio))
            appMgr.getStyler().requestStyleChange('highlightAndFade',{semElem.UUID},"spotlightHighlightAndFade");
        else

            msg=message('SystemArchitecture:Requirements:NoLinkedElementInSpotlight',modelName,id,studio.getStudioTag());
            editor.deliverInfoNotification(messageId,msg.getString);
        end

    end

end

function exist=existInSpotlight(appMgr,semElem,studio)
    exist=false;


    if isa(semElem,'systemcomposer.architecture.model.design.ComponentPort')
        semElem=semElem.getComponent();
    end


    spotlight=appMgr.getActiveSpotlight(studio.getStudioTag());
    if~isempty(spotlight)
        components=spotlight.getComponentsInSpotlight();
        components=[components,spotlight.getComponentsWithChildInSpotlight()];
        for i=1:length(components)
            comp=components(i);
            if strcmp(comp.getZCIdentifier(),semElem.getZCIdentifier())
                exist=true;
                break;
            end
        end
    end
end


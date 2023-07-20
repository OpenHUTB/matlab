function onHierarchyChange(method,h)





    try
        if isempty(h)
            return;
        elseif numel(h)>1

            h=h(1);
        end

        if isa(h,'diagram.Object')
            diagramObj=h;
            if~diagramObj.isDiagram


                return;
            end
        elseif isa(h,'double')||isa(h,'Simulink.Object')||isa(h,'Stateflow.Object')
            diagramObj=diagram.resolver.resolve(h);
        else

            return;
        end

        if strcmp(diagramObj.resolutionDomain,'simulink')
            modelH=bdroot(Simulink.resolver.asHandle(diagramObj));
        elseif strcmp(diagramObj.resolutionDomain,'stateflow')
            rt=sfroot;
            sfId=Stateflow.resolver.asId(diagramObj);
            sfObj=rt.find('Id',sfId);
            modelH=get_param(sfObj.Machine.Name,'Handle');
        else
            return;
        end

        if(get_param(modelH,'ReqPerspectiveActive')==0)
            return;
        end

        appmgr=slreq.app.MainManager.getInstance();
        switch lower(method)
        case 'prechange'
            if~isempty(appmgr.markupManager)

                appmgr.markupManager.removeClientContent(modelH);
                appmgr.markupManager.hideMarkupsAndConnectorsForModel(modelH);
            end
            if~isempty(appmgr.badgeManager)
                if appmgr.badgeManager.getStatus(modelH)

                    appmgr.badgeManager.disableBadges(modelH);
                end
            end

        case 'postchange'
            if~isempty(appmgr.markupManager)

                appmgr.markupManager.showMarkupsAndConnectorsForModel(modelH);
            end
            if~isempty(appmgr.badgeManager)
                if~appmgr.badgeManager.getStatus(modelH)

                    appmgr.badgeManager.enableBadges(modelH);
                end
            end
        end
    catch ex %#ok<NASGU>

    end
end

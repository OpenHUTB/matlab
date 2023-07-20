classdef SystemPortBadgeManager<handle




    methods(Static)
        function updateBadgeForPortAddedOrDeleted(portUUID,modelName)
            mm=slreq.app.MainManager.getInstance;
            if mm.isPerspectiveEnabled(modelName)
                zcMFModel=get_param(modelName,'SystemComposerMF0Model');
                portElem=zcMFModel.findElement(portUUID);
                req=rmidata.getReqs(portElem);
                if~isempty(req)
                    mm.badgeManager.enableBadges(modelName);
                    mm.badgeManager.showBadge(modelName,portElem);
                end
            end
        end
    end
end

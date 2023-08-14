function disengageAndReset(this)








    if~isempty(this.perspectiveManager)

        disableModelHs=this.perspectiveManager.getDisabledModelList();
    else
        disableModelHs=[];
    end


    if~isempty(this.spreadsheetManager)
        modelHs=this.spreadsheetManager.getAllModelHandles;
        for cModelH=modelHs
            if this.perspectiveManager.getStatus(cModelH)
                try
                    this.togglePerspective(cModelH);
                catch ex
                    if~strcmpi(ex.identifier,'Slvnv:slreq:ErrorEnterPerspectiveDueToUnopenedModel')
                        throwAsCaller(ex);
                    end
                end
            end
        end
        modelHsToClearBadgeAndMarkup=this.spreadSheetDataManager.getAllModelHandles;
        for cModelH=modelHsToClearBadgeAndMarkup
            if ishandle(cModelH)

                modelName=get_param(cModelH,'Name');
                this.badgeManager.disableBadges(modelName);
                this.spreadsheetManager.detachSpreadSheet(cModelH);
                this.markupManager.removeClientContent(cModelH);
                this.markupManager.hideMarkupsAndConnectorsForModel(cModelH);
            end
        end
    end






    this.reset;
    this.init;
    this.initPerspective;

    for n=1:length(disableModelHs)

        this.perspectiveManager.addInDisabledModelList(disableModelHs(n));
    end

end

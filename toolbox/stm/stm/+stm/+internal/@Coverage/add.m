



function coverageResults=add(cr,rs,resultID)
    import stm.internal.Coverage;

    topLevelModel=cr.topLevelModel;
    analyzedModel=cr.analyzedModel;
    covAggregator=cv.aggregation();
    covAggregator.setRequirementsMapping(rs.getReqMdlTestInfo);
    filters=getFilters(rs,resultID);


    oc1=[];%#ok<NASGU>
    oc2=[];%#ok<NASGU>
    oc3=[];%#ok<NASGU>

    for filename=string(cr.filenames)
        data=Coverage.loadCovObjects(filename,analyzedModel);
        analyzedModel=data.modelinfo.analyzedModel;
        models=Coverage.getOwnerModel(data.modelinfo);


        if(~isempty(models)&&~isempty(analyzedModel))
            ownerModel=models{1};

            if~bdIsLoaded(topLevelModel)
                load_system(topLevelModel);
                oc1=onCleanup(@()close_system(topLevelModel,0));
            end

            try
                harnessList=sltest.harness.find(ownerModel,'Name',analyzedModel);
                if~isempty(harnessList)



                    cr.ownerFullPath=analyzedModel;
                    if~harnessList(1).isOpen
                        constructedHarnessName=[analyzedModel,'%%%',harnessList(1).ownerFullPath];
                        [~,deactivateHarness,currHarness,oldHarness,~,wasHarnessOpen]=...
                        stm.internal.util.resolveHarness(ownerModel,constructedHarnessName);
                        oc2=onCleanup(@()helperResetHarness(oldHarness,currHarness,wasHarnessOpen,deactivateHarness));
                    end
                end
            catch

            end
        end

        try
            data.filter=unique([data.filter,filters.cellstr]);
        catch
            data.filter='';
        end
        covAggregator.addData(data);
    end

    if~bdIsLoaded(topLevelModel)
        load_system(topLevelModel);
        oc3=onCleanup(@()close_system(topLevelModel,0));
    end
    coverageResults=Coverage.getMetrics(covAggregator.getSum(),cr.ownerType,cr.ownerFullPath,'');
end

function helperResetHarness(oldHarness,currHarness,wasHarnessOpen,deactivateHarness)

    if~isempty(currHarness)&&bdIsLoaded(currHarness.model)
        close_system(currHarness.name,0);

        if(deactivateHarness)
            stm.internal.util.loadHarness(oldHarness.ownerFullPath,oldHarness.name,wasHarnessOpen);
        end
    end
end

function filters=getFilters(rs,resultID)

    if rs.getID==resultID
        filters=rs.FilterFiles;
    else
        filters=string.empty;
    end
end

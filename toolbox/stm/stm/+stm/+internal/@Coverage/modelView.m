



function modelView(filenames,analyzedModel,~,resultSetID)
    import stm.internal.Coverage;

    if nargin<4
        resultSetID=[];
    end

    for x=1:length(filenames)
        data=Coverage.loadCovObjects(filenames{x},analyzedModel);
        ownerModel=Coverage.getOwnerModel(data.modelinfo);
        ownerModel=ownerModel{1};
        status=Coverage.getStatus(ownerModel);
        if status==Coverage.MODEL
            if~Coverage.isNotUnique(ownerModel)&&~bdIsLoaded(ownerModel)
                open_system(ownerModel);
            end


            if~isempty(data.modelinfo.harnessModel)&&~data.canHarnessMapBackToOwner()
                harnessList=sltest.harness.find(ownerModel,'Name',data.modelinfo.harnessModel);
                if~isempty(harnessList)
                    constructedHarnessName=[data.modelinfo.harnessModel,'%%%',harnessList(1).ownerFullPath];
                    stm.internal.util.resolveHarness(ownerModel,constructedHarnessName,true);
                end
            else
                open_system(getSystemToOpen(analyzedModel));
            end



            covHTMLSettings=Coverage.getHTMLSettings(ownerModel);
            covHTMLSettings.setFilterCtxId(resultSetID,'cvmodelview');
            Coverage.safeSlvnv(@cvmodelview,analyzedModel,'ViewcvModelUsingIncompatibleCvdataError',{data,covHTMLSettings});
        elseif status==Coverage.NONEXISTENT
            open_system(ownerModel);
        end
    end
end

function systemToOpen=getSystemToOpen(analyzedModel)

    systemToOpen=analyzedModel;
    modelName=Simulink.SimulationData.BlockPath.getModelNameForPath(analyzedModel);
    if~bdIsLoaded(modelName)
        load_system(modelName);
    end
    if~isempty(Simulink.Mask.get(analyzedModel))&&~isvarname(analyzedModel)

        systemToOpen=get_param(analyzedModel,'Parent');
    end
end

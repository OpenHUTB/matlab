

function reportFiles=report(filenames,topLevelModel,launchReport,resultSetID)

    import stm.internal.Coverage;

    if nargin<4
        resultSetID=[];
    end
    load_system(topLevelModel);
    reportFiles=filenames;
    covHTMLSettings=Coverage.getHTMLSettings(topLevelModel);
    covHTMLSettings.setFilterCtxId(resultSetID);
    for i=1:length(filenames)
        cvdata=Coverage.loadCovObjects(filenames{i});
        models=Coverage.getOwnerModel(cvdata.modelinfo);

        for j=1:length(models)
            model=models{j};
            if~Coverage.isNotUnique(model)&&Coverage.isModel(model)
                if Coverage.isLibrary(model)
                    oc=Coverage.restoreLibraryLock(model);%#ok<NASGU>
                else
                    load_system(model);
                end
            end
        end

        [pathstr,name,~]=fileparts(filenames{i});
        filename=[pathstr,filesep,name,'.html'];


        if~Coverage.isNotUnique(model)&&Coverage.isModel(model)&&...
            ~isempty(cvdata.modelinfo.harnessModel)&&~cvdata.canHarnessMapBackToOwner()
            harnessList=sltest.harness.find(models{1},'Name',cvdata.modelinfo.harnessModel);
            if~isempty(harnessList)
                constructedHarnessName=[cvdata.modelinfo.harnessModel,'%%%',harnessList(1).ownerFullPath];
                stm.internal.util.resolveHarness(models{1},constructedHarnessName,true);
            end
        end


        Coverage.safeSlvnv(@cvhtml,topLevelModel,'GenerateReportFromIncompatibleCvdataError',{filename,cvdata,covHTMLSettings});
        reportFiles{i}=filename;
        if launchReport
            web(filename,'-new');
        end
    end
end

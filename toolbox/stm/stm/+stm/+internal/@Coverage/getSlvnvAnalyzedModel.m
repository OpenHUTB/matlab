


function[slvnvAnalyzedModel,isHarnessOpen]=getSlvnvAnalyzedModel(...
    cvdataObj,analyzedModel,ownerType,ownerFullPath)
    import stm.internal.Coverage;
    slvnvAnalyzedModel=cvdataObj.modelinfo.analyzedModel;
    isHarnessOpen=false;
    try
        if~isempty(cvdataObj.modelinfo.ownerModel)
            ownerModels=Coverage.getOwnerModel(cvdataObj.modelinfo);
            ownerModel=ownerModels{1};
            if~isvarname(ownerModel)

                return;
            end

            if bdIsLoaded(ownerModel)
                if isprop(cvdataObj,'isSharedUtility')&&cvdataObj.isSharedUtility

                else
                    harnessList=sltest.harness.find(analyzedModel,'OpenOnly','on');
                    assert(length(harnessList)<=1);
                    if~isempty(harnessList)
                        isHarnessOpen=true;
                    end
                end
            else

                load_system(ownerModel);
            end

            if strcmp(ownerType,'Simulink.SubSystem')
                if isHarnessOpen


                    subsystem=get_param(harnessList.ownerFullPath,'Name');
                    slvnvAnalyzedModel=[harnessList.name,'/',subsystem];
                elseif contains(slvnvAnalyzedModel,'/')


                    slvnvAnalyzedModel=ownerFullPath;
                end
            end
        end
    catch

    end
end
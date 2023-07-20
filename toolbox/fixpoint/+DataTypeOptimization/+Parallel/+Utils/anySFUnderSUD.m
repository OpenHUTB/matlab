function sfFound=anySFUnderSUD(sud)








    sfFound=false;


    sudObj=get_param(sud,'Object');


    allSF=SimulinkFixedPoint.AutoscalerUtils.getAllStateflowDataList(sudObj);
    if isempty(allSF)




        allMdlRefBlk=find_system(sudObj.getFullName,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'BlockType','ModelReference');


        if~isempty(allMdlRefBlk)

            for mIndex=1:numel(allMdlRefBlk)
                load_system(allMdlRefBlk{mIndex});
                mdlBlkObj=get_param(allMdlRefBlk{mIndex},'Object');
                anySFMdlRef=DataTypeOptimization.Parallel.Utils.anySFUnderSUD(mdlBlkObj.ModelName);
                if anySFMdlRef
                    sfFound=true;
                    break;
                end
            end
        end
    else
        sfFound=true;
    end
end

function resultsScope=getResultsScopeMap(results,sysToScaleName)











    allModelReferencesUnderSUD=SimulinkFixedPoint.AutoscalerUtils.getMdlRefs(sysToScaleName);




    isUnderModelReferenceSUD=false(1,numel(results));
    if length(allModelReferencesUnderSUD)>1



        allModelReferencesUnderSUD{end}=sysToScaleName;


        isUnderModelReferenceSUD=false(length(results),1);


        for resultIndex=1:length(results)
            modelReferenceSources=results{resultIndex}.getRunObject.Source;



            isUnderModelReferenceSUD(resultIndex)=any(ismember(modelReferenceSources,allModelReferencesUnderSUD));
        end
    end


    isUnderSubsystemSUD=false(length(results),1);
    for resultIndex=1:length(results)

        resultPath=SimulinkFixedPoint.AutoscalerUtils.getResultPath(results{resultIndex});



        isUnderSubsystemSUD(resultIndex)=any(contains(resultPath,[sysToScaleName,'/']));

    end



    isUnderSUD=isUnderSubsystemSUD|isUnderModelReferenceSUD;





    resultsScope=containers.Map();

    for index=1:length(isUnderSUD)
        resultsScope(results{index}.UniqueIdentifier.UniqueKey)=isUnderSUD(index);
    end

end
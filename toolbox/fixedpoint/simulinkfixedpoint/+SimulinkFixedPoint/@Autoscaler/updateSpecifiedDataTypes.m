function updateSpecifiedDataTypes(datasets,runName)







    for idx=1:length(datasets)
        curdataset=datasets{idx};


        runObj=curdataset.getRun(runName);
        results=runObj.getResults;


        for idy=1:length(results)
            result=results(idy);
            blkObj=result.UniqueIdentifier.getObject;
            pathItem=result.UniqueIdentifier.getElementName;

            if result.hasInterestingInformation



                [designMin,designMax]=result.getAutoscaler.gatherDesignMinMax(blkObj,pathItem);
                result.setDesignRange(designMin,designMax);


                DTConInfo=result.getAutoscaler.gatherSpecifiedDT(blkObj,pathItem);
                specifiedDT=DTConInfo.evaluatedDTString;
                result.setSpecifiedDataType(specifiedDT);
            end
        end
    end
end


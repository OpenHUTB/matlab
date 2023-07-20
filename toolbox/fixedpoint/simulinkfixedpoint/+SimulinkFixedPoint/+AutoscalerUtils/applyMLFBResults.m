function applyMLFBResults(resMap,modelName,runObj,sudID)




    keyCount=resMap.getCount;
    for idx=1:keyCount
        blkName=resMap.getKeyByIndex(idx);
        results=resMap.getDataByIndex(idx);
        resultsAsArray=[results{:}];

        isConverted=coder.internal.MLFcnBlock.F2FDriver.convertOneMLFBInBatchMode(resultsAsArray,blkName,modelName,runObj,sudID);



        if isConverted
            for index=1:length(results)




                if fxptds.isResultValid(results{index})


                    results{index}.setAccept(false);
                end
            end
        end
    end

end



function mergeResults(templateRunObject,mergedRunObject)






    templateResults=templateRunObject.getResults;

    for idx=1:length(templateResults)

        templateResult=templateResults(idx);



        if isa(templateResult,'fxptds.MATLABExpressionResult')
            continue;
        end


        resultID=templateResult.UniqueIdentifier;
        mergedResult=mergedRunObject.getResult(resultID.getObject,resultID.getElementName);



        outData=SimulinkFixedPoint.ApplicationData.createMergedData(templateResult,mergedResult);


        mergedRunObject.createAndUpdateResult(fxptds.SimulinkDataArrayHandler(outData));

    end
end

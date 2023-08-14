function compsToAdd=calculateMissingLayers(zcModel,archName,sortedCompNames)






    compsToAdd=[];
    for idx1=1:numel(sortedCompNames)
        compName=sortedCompNames(idx1);
        layerIdxs=regexp(compName,'(?<!/)/{1}(?!/)');
        for idx2=1:length(layerIdxs)
            layer=compName.extractBefore(layerIdxs(idx2));



            if(~any(strcmp(sortedCompNames,layer)))
                try
                    elemPath=zcModel.getImpl.findElementWithPath([archName,'/',convertStringsToChars(layer)]);
                catch
                    compsToAdd=[compsToAdd,layer];
                end
            end
        end

        compsToAdd=[compsToAdd,compName];
    end
end
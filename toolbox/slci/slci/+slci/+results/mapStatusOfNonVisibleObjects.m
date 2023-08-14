


function mapStatusOfNonVisibleObjects(dataObjects,reader,slciConfig)





    selected=cellfun(@(x)~getIsVisible(x),dataObjects);
    nonVisibleObjects=dataObjects(selected);
    numObjects=numel(nonVisibleObjects);
    targetMap=containers.Map;
    for k=1:numObjects
        dataObject=nonVisibleObjects{k};
        targets=dataObject.getVisibleTarget();
        assert(~isempty(targets));
        for idx=1:numel(targets)
            target=targets{idx};
            if isKey(targetMap,target)
                dataObjects=targetMap(target);
                dataObjects{end+1}=dataObject;%#ok
                targetMap(target)=dataObjects;
            else
                targetMap(target)={dataObject};
            end
        end
    end




    processed={};
    if~isempty(targetMap)
        targets=keys(targetMap);
        numTargets=numel(targets);
        for k=1:numTargets
            targetObj=reader.getObject(targets{k});
            [~,targetMap,processed]=...
            processTargetObj(targetObj,targetMap,reader,processed,slciConfig);
        end
    end

end

function[targetObj,targetMap,processed]=processTargetObj(...
    targetObj,targetMap,reader,processed,slciConfig)


    targetKey=targetObj.getKey();
    if~any(strcmp(processed,targetKey))

        processed{end+1}=targetKey;

        assert(isKey(targetMap,targetKey));
        nonVisibleObjs=targetMap(targetKey);
        for nv=1:numel(nonVisibleObjs)
            nvObject=nonVisibleObjs{nv};
            if isKey(targetMap,nvObject.getKey())
                [nvObject,targetMap,processed]=processTargetObj(...
                nvObject,...
                targetMap,...
                reader,...
                processed,slciConfig);
                nonVisibleObjs{nv}=nvObject;
            end
        end



        targetObj.inheritVerificationInfo(nonVisibleObjs,slciConfig);

        targetObj.inheritTraceability(nonVisibleObjs);

        reader.replaceObject(targetKey,targetObj);
    end
end

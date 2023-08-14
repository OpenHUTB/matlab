


function clearStudioData(obj,modelH)
    clearMap(obj.fManualReviews,modelH);
    clearMap(obj.fCodeViews,modelH);
end

function clearMap(dataMap,modelH)
    ks=keys(dataMap);
    removedKey={};
    for i=1:numel(ks)
        key=ks{i};
        mr=dataMap(key);
        modelHandle=mr.getModelHandle;
        if isequal(modelHandle,modelH)

            removedKey{end+1}=key;%#ok
        end
    end

    remove(dataMap,removedKey);
end
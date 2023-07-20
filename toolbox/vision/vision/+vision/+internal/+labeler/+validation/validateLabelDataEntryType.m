
function validateLabelDataEntryType(data,hasHierarchy,name,type)

    TF=cellfun(@(x)isstruct(x),data);
    allStructs=all(TF);

    errorCond1=hasHierarchy&&~allStructs;
    errorCond2=~hasHierarchy&&allStructs;

    if errorCond1
        error(message('vision:groundTruth:invalidEntryLabelDataStruct',name))
    elseif errorCond2
        if type==labelType.Rectangle
            error(message('vision:groundTruth:badRectData',name))
        elseif type==labelType.Line
            error(message('vision:groundTruth:badLineData',name))
        elseif type==labelType.Polygon
            error(message('vision:groundTruth:badPolygonData',name))
        elseif type==labelType.ProjectedCuboid
            error(message('vision:groundTruth:badProjCuboidData',name))
        end
    end
end

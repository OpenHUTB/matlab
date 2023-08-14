function records=gatherAssociatedParam(this,blkObj)





    records=[];


    [poIndices,poMaxValues,poMinValues]=this.getModelRequiredMinMaxOutputValues(blkObj);
    for index=1:length(poIndices)
        records=[records,SimulinkFixedPoint.EntityAutoscalerUtils.createRecordForAssociatedParam(...
        blkObj,int2str(poIndices(index)),[],poMinValues(index),poMaxValues(index),[])];%#ok<AGROW>
    end
end


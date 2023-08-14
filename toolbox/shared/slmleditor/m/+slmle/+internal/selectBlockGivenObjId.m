function selectBlockGivenObjId(objectId)




    if strcmp(slmle.internal.checkMLFBType(objectId),'EMChart')

        blkName=slmle.internal.object2Data(objectId,'blkName');
        set_param(blkName,'Selected',1);
    else


        chartId=slmle.internal.object2Data(objectId,'getChartId');
        sf('Select',chartId,objectId);
    end
end


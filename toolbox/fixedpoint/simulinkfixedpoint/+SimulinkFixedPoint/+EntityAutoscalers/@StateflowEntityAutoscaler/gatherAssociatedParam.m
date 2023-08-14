function associateRecords=gatherAssociatedParam(h,blkObj)%#ok<INUSL>






    associateRecords.blkObj=blkObj;
    associateRecords.pathItem='1';
    associateRecords.ModelRequiredMin=[];
    associateRecords.ModelRequiredMax=[];


    chartId=sf('DataChartParent',blkObj.Id);
    parentH=sfprivate('chart2block',chartId);

    useParsedInfo=true;
    if~isempty(parentH)


        if strcmp(blkObj.Scope,'Parameter')
            parentSubsystemObj=get_param(parentH,'Object');
            [isValid,minVal,maxVal,pObj]=SimulinkFixedPoint.slfxpprivate(...
            'evalNumericParameterRange',parentSubsystemObj,blkObj.Name);
            if isValid&&~isempty(pObj)
                associateRecords.ModelRequiredMin=minVal;
                associateRecords.ModelRequiredMax=maxVal;
                associateRecords.paramObj=pObj;
                useParsedInfo=false;
            end
        end
        if useParsedInfo
            dataInfo=sf('DataParsedInfo',blkObj.Id,parentH);
            if~isempty(dataInfo)&&isfield(dataInfo,'initialval')
                [associateRecords.ModelRequiredMin,associateRecords.ModelRequiredMax]=...
                SimulinkFixedPoint.extractMinMax(dataInfo.initialval);
            end
        end

    end





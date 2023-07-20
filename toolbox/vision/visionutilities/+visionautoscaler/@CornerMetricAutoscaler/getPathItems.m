function pathItems=getPathItems(h,blkObj)%#ok





    pathItems={'Coefficients',...
    'Accumulator',...
    'Product output',...
    'Memory',...
    'Metric output'};


    mdl=bdroot(blkObj.getFullName);
    appData=SimulinkFixedPoint.getApplicationData(mdl);
    numToRemove=[];




    for idx=1:numel(pathItems)
        hasSimMinMax=isSigHasSimMinMax(appData,blkObj,pathItems{idx});
        if~hasSimMinMax
            numToRemove=[numToRemove,idx];%#ok<AGROW>
        end
    end
    pathItems(numToRemove)=[];

    function hasMinMax=isSigHasSimMinMax(appData,blkObj,pathItem)

        hasMinMax=false;
        dataset=appData.dataset;

        curResult=dataset.getRun(appData.ScaleUsing).getResultsWithCriteriaFromArray({'Object',blkObj,'ElementName',pathItem});
        if~isempty(curResult)
            if~isempty(curResult.SimMin)||~isempty(curResult.SimMax)
                hasMinMax=true;
            end
        end


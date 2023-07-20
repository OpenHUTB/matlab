function associateRecords=gatherAssociatedParam(h,blkObj)%#ok<INUSL>





    associateRecords=[];
    if(strcmp(blkObj.TableIsInput,'off'))

        associateRecords=...
        struct('blkObj',[],'pathItem',[],...
        'ModelRequiredMax',[],'ModelRequiredMin',[],'paramObj',[]);
        associateRecords.blkObj=blkObj;
        associateRecords.pathItem='Table';

        str=blkObj.Table;
        [isValid,minVal,maxVal,pObj]=SimulinkFixedPoint.slfxpprivate('evalNumericParameterRange',blkObj,str);
        if isValid
            associateRecords.ModelRequiredMin=minVal;
            associateRecords.ModelRequiredMax=maxVal;
            associateRecords.paramObj=pObj;
        end
    end




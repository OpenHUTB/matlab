function associatedRecords=gatherAssociatedParam(h,blkObj)







    associatedRecords=[];


    if strcmpi(blkObj.CoeffSource,'Specify via dialog')
        coeffNames=h.getCoefficientPropertyNames(blkObj);
        for i=1:length(coeffNames)
            coeffMinMax=slResolve(blkObj.(coeffNames(i).ParamName),blkObj.Handle);
            [coeffMin,coeffMax]=SimulinkFixedPoint.extractMinMax(coeffMinMax);
            associatedRecords(i).blkObj=blkObj;%#ok<*AGROW>
            associatedRecords(i).pathItem=coeffNames(i).PathItem;
            associatedRecords(i).srcInfo=[];

            associatedRecords(i).ModelRequiredMin=coeffMin;
            associatedRecords(i).ModelRequiredMax=coeffMax;
            associatedRecords(i).paramObj=[];
        end
    end
end


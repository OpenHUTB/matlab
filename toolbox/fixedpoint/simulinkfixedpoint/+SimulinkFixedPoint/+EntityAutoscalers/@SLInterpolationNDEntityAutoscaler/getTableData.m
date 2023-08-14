function[isValid,minimumValue,maximumValue,parameterObject]=getTableData(h,blockObject)






    pathItems=getPathItems(h,blockObject);
    isValid=false;
    minimumValue=[];
    maximumValue=[];
    parameterObject=[];
    if ismember('Table',pathItems)
        [isValid,minimumValue,maximumValue,parameterObject]=SimulinkFixedPoint.slfxpprivate('evalNumericParameterRange',blockObject,blockObject.Table);
    else
        if strcmp(blockObject.TableSpecification,'Lookup table object')

            isValid=true;
            lUTObject=slResolve(blockObject.LookupTableObject,blockObject.Handle,'variable','startUnderMask');
            rangeVec=SimulinkFixedPoint.safeConcat(lUTObject.Table.Min,lUTObject.Table.Max,lUTObject.Table.Value);
            [minimumValue,maximumValue]=SimulinkFixedPoint.extractMinMax(rangeVec);
        end
    end
end
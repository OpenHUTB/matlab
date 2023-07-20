function dataToUseOut=castDataAndFormat(dataVals,dataType,varargin)




    dataVals=datacreation.internal.getMATLABValueFromConnectorData(dataVals);

    try
        dataToUse=datacreation.internal.castForCreation(cell2mat(dataVals),dataType,varargin{:});
    catch ME
        throwAsCaller(ME);
    end

    if isa(dataToUse,'embedded.fi')
        dataToUse=double(dataToUse);
    end

    dataToUseOut=cell(size(dataToUse));
    for k=1:numel(dataToUse)

        dataToUseOut{k}=datacreation.internal.sanitizeNumericForJS(dataToUse(k));

    end

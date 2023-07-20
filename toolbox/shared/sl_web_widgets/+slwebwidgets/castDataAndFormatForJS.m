function dataToUseOut=castDataAndFormatForJS(dataVals,dataType,varargin)




    dataVals=slwebwidgets.getMATLABValueFromConnectorData(dataVals);

    dataToUse=slwebwidgets.doSLCast(cell2mat(dataVals),dataType,varargin{:});

    if isfi(dataToUse)
        dataToUse=double(dataToUse);
    end

    dataToUseOut=cell(size(dataToUse));
    for k=1:numel(dataToUse)

        dataToUseOut{k}=slwebwidgets.sanitizeNumericForJS(dataToUse(k));

    end

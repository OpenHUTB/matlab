function outputData=convertToCell(inputData)





    if~iscell(inputData)
        outputData={inputData};
    else
        outputData=inputData;
    end

end










function validateDLquantizerObject(dlconfig)



    calibrationResultMatFile=dlconfig.CalibrationResultFile;


    if isempty(calibrationResultMatFile)
        error(message('dlcoder_spkg:cnncodegen:MissingCalibrationResultsFile'));
    end

    dlquantObj=getdlquantizerObject(calibrationResultMatFile);


    if~strcmpi(dlquantObj.ExecutionEnvironment,'GPU')&&isa(dlconfig,'coder.CuDNNConfig')
        error(message('dlcoder_spkg:cnncodegen:InvalidExecutionEnvironment'));
    end



    if isempty(dlquantObj.CalibrationStatistics)
        error(message('dlcoder_spkg:cnncodegen:CalibrationStatisticsIsEmptyInDlquantizerObject'));
    end
end


function dlquantizerObj=getdlquantizerObject(calibrationResultMatFile)



    dlquantizerObj=[];
    numOfdlquantObjects=0;

    calibrationResult=load(calibrationResultMatFile);
    fieldNames=fieldnames(calibrationResult);

    for i=1:numel(fieldNames)
        fieldName=calibrationResult.(fieldNames{i});
        if isa(fieldName,'dlquantizer')
            dlquantizerObj=fieldName;
            numOfdlquantObjects=numOfdlquantObjects+1;
        end
    end







    if(~isa(dlquantizerObj,'dlquantizer')||...
        isempty(dlquantizerObj)||...
        numOfdlquantObjects>1)

        error(message('dlcoder_spkg:cnncodegen:InvalidDLquantizerObject'));
    end

end

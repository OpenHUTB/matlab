function status=loadTestCases(obj,existingTestData)







    status=false;


    checkSanity(existingTestData);


    if isa(existingTestData,'struct')
        loadedData.sldvData=existingTestData;
    else

        currFileName=existingTestData;
        [~,~,ext]=fileparts(currFileName);
        if contains(ext,{'xlsx','xls'},'IgnoreCase',true)


            loadedData.sldvData=Sldv.DataUtils.spreadsheetToSldvData(currFileName,obj.mModelH);
        else


            loadedData=load(currFileName);
        end
    end


    allfields=fieldnames(loadedData);
    for fIdx=1:length(allfields)
        if isstruct(loadedData.(allfields{fIdx}))
            existingData=loadedData.(allfields{fIdx});
            status=loadTestCasesHelper(obj,existingData);
        end


        if status==false
            return;
        end
    end
end

function checkSanity(existingTestData)
    assert(isempty(existingTestData)==false);

    assert(isa(existingTestData,'char')||...
    isa(existingTestData,'string')||...
...
    isa(existingTestData,'cell')||...
    isa(existingTestData,'struct'));
end

function status=loadTestCasesHelper(obj,existingData)
    status=true;


    if isfield(existingData,'CounterExamples')
        simData=Sldv.DataUtils.getSimData(existingData);
        existingData=rmfield(existingData,'CounterExamples');
        existingData.TestCases=simData;
    end

    if isfield(existingData,'TestCases')


        paramSettings=obj.mTestComp.tunableParamsAndConstraints.Constraints.singleParamConstraints;
        if~isempty(paramSettings)
            paramsInCurrAnalysis=fieldnames(paramSettings);
            existingData=obj.updateParameterInfo(paramsInCurrAnalysis,existingData);
        end
















        existingData=Sldv.DataUtils.convertSLDataSetToCellArray(existingData);
        existingData=Sldv.DataUtils.compressDataForTestExtension(existingData);


        obj.checkTestcaseInterface(existingData);
        status=obj.mTestComp.loadTestCases(existingData);
    end
end

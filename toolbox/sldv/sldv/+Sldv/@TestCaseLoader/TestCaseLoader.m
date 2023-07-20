classdef TestCaseLoader<handle




    properties(Access=private)
        mTestComp=[];
        mModelH=[];
        mParamDefnMap=[];
    end

    methods(Access=public)

        function obj=TestCaseLoader(testComp,modelH)
            obj.mTestComp=testComp;
            obj.mModelH=modelH;
            obj.mParamDefnMap=containers.Map('KeyType','char',...
            'ValueType','any');
        end

        status=loadTestCases(obj,existingTestFiles);
        [status,sldvdata]=addMdlNameInSldvData(obj,sldvdata);
    end

    methods(Access=private)
        updatedData=updateParameterInfo(obj,paramsInCurrAnalysis,sldvData)
        checkTestcaseInterface(obj,testcomp,existingData);
    end

end

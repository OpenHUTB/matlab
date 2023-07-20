function checkTestcaseInterface(obj,existingData)




    testComp=obj.mTestComp;
    hastestcases=check_test_cases(existingData);

    if hastestcases
        check_number_of_inputs(testComp,existingData);
        if~slavteng('feature','ExternalEngine')
            check_testcase_length(testComp,existingData);
        end
    end
end

function hastc=check_test_cases(existingData)
    hastc=isfield(existingData,'TestCases')&&...
    ~isempty(existingData.TestCases);
end

function check_number_of_inputs(testcomp,existingData)
    numInportBlks=length(testcomp.mdlFlatIOInfo.Inport);
    numInputSignals=length(existingData.TestCases(1).dataValues);
    if numInportBlks~=numInputSignals
        error(message('Sldv:SldvRun:NumInputSignals'));
    end
end

function check_testcase_length(testcomp,existingData)
    testCaseStepLimit=1000;
    productNumInputSignalsTestCaseStepLimit=testCaseStepLimit*100;

    msg=getString(message('Sldv:mdl_check_external_testcase:NumberOfTime'));

    maxtestcasesteps=0;
    loggedSimData=Sldv.DataUtils.getSimData(existingData);
    for idx=1:length(loggedSimData)
        maxtestcasesteps=max(maxtestcasesteps,length(loggedSimData(idx).timeValues));
    end

    if maxtestcasesteps>testCaseStepLimit
        error('Sldv:SldvRun:TestCaseLength',msg);
    end

    totalSignals=0;
    inportCompInfo=testcomp.mdlFlatIOInfo.Inport;
    numInPorts=length(inportCompInfo);
    for idx=1:numInPorts
        totalSignals=totalSignals+length(inportCompInfo(idx).compiledInfo);
    end

    if totalSignals*maxtestcasesteps>productNumInputSignalsTestCaseStepLimit
        error('Sldv:SldvRun:TestCaseLength',msg);
    end
end

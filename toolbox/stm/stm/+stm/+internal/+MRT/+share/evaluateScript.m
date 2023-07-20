function evaluateScript(sltest_bdroot,sltest_sut,sltest_isharness,script,...
    sltest_testid,sltest_parameterSets,sltest_baselines,...
    sltest_externalInputs,sltest_configSets,...
    sltest_signalBuilderGroups,sltest_loggedSignalSets,sltest_testSequenceScenarios,...
    initIterationIdList,isIteration,sltest_iterationName,isMRT)%#ok<INUSL>




    if(~isempty(sltest_bdroot)&&nargin>=4)
        variableStore_0=stm.internal.util.RestoreVariable(...
        {'sltest_bdroot','sltest_sut','sltest_isharness'});%#ok<NASGU>
        assignin('base','sltest_bdroot',sltest_bdroot);
        assignin('base','sltest_sut',sltest_sut);
        assignin('base','sltest_isharness',sltest_isharness);
        if exist('sltest_signalBuilderGroups','var')
            sltest_signalEditorScenarios=sltest_signalBuilderGroups;%#ok<NASGU>
        end
    end

    if nargin<=4
        sltest_testid=0;
    end


    if(nargin>=5)
        variableStore_1=stm.internal.util.RestoreVariable({'sltest_testid'});%#ok<NASGU>
        assignin('base','sltest_testid',sltest_testid);
    end


    if nargin<15
        sltest_iterationName='';
    end
    if(nargin<16)
        isMRT=false;
    end

    variableStore_2=stm.internal.util.RestoreVariable({'sltest_iterationName'});%#ok<NASGU>
    assignin('base','sltest_iterationName',sltest_iterationName);

    sltest_tableIterations={};
    if(nargin>=12)
        for k=1:length(initIterationIdList)
            oneIteration=sltest.internal.TestIterationWrapper(initIterationIdList{k});
            sltest_tableIterations{k}=oneIteration;
        end
    end

    evaluateIterationScript=false;
    if(nargin>=13)
        evaluateIterationScript=isIteration;
    end


    if(~isMRT)
        idx=1;
        vars={'sltest_testCase','sltest_testSuite','sltest_testFile'};
        testVars=stm.internal.util.RestoreVariable(vars);%#ok<NASGU>

        sltest_testObj=sltest.testmanager.Test.getTestObjFromID(sltest_testid);
        if isa(sltest_testObj,'sltest.testmanager.TestCase')
            sltest_testCase=sltest_testObj;%#ok<NASGU>
            idx=1;
        elseif isa(sltest_testObj,'sltest.testmanager.TestSuite')
            sltest_testSuite=sltest_testObj;%#ok<NASGU>
            idx=2;
        elseif isa(sltest_testObj,'sltest.testmanager.TestFile')
            sltest_testFile=sltest_testObj;%#ok<NASGU>
            idx=3;
        end
        assignin('base',vars{idx},sltest_testObj);
    end

    if(evaluateIterationScript)


        oc=onCleanup(@()stm.internal.setTypeOfAddingIteration(0));
        stm.internal.setTypeOfAddingIteration(1);
        eval(script);
    else
        evalin('base',script);
    end
end

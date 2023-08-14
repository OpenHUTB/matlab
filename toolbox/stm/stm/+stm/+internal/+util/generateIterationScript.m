function scr=generateIterationScript(paramTypeList,testCaseType)



    TEST_CASE_TYPES.SIMULATION=0;
    TEST_CASE_TYPES.EQUIVALENCE=1;
    TEST_CASE_TYPES.BASELINE=2;

    nParamTypes=length(paramTypeList);
    indentL1='    ';
    indentL2=[indentL1,indentL1];

    unqiueParameterNames=cell(nParamTypes,1);
    simIndexList=zeros(nParamTypes,1);
    for k=1:nParamTypes
        str=getParameterName(paramTypeList(k).paramType);
        unqiueParameterNames{k}=str;
        simIndexList(k)=str2double(paramTypeList(k).simIndex);
    end
    unqiueParameterNames=unique(unqiueParameterNames);

    nUnqiueParamTypes=length(unqiueParameterNames);
    if(nUnqiueParamTypes==1)
        comment=getString(message('stm:ScriptsView:AutoGeneratedScriptsForOne',unqiueParameterNames{1}));
    elseif(nUnqiueParamTypes==2)
        comment=getString(message('stm:ScriptsView:AutoGeneratedScriptsForTwo',unqiueParameterNames{:}));
    elseif(nUnqiueParamTypes==3)
        comment=getString(message('stm:ScriptsView:AutoGeneratedScriptsForThree',unqiueParameterNames{:}));
    elseif(nUnqiueParamTypes==4)
        comment=getString(message('stm:ScriptsView:AutoGeneratedScriptsForFour',unqiueParameterNames{:}));
    else
        comment=getString(message('stm:ScriptsView:AutoGeneratedScriptsForFive',unqiueParameterNames{:}));
    end
    lines={['%% ',comment]};
    lines=[lines,{' '}];
    lines=[lines,{['% ',getString(message('stm:ScriptsView:GetTheNumberOfIterations'))]}];
    aline='numSteps = ';
    if(nParamTypes>1)
        aline=[aline,'min(['];
    end

    for k=1:nParamTypes
        varName=getVariableName(paramTypeList(k).paramType);
        varName1=varName;
        simIndex=simIndexList(k);
        if(testCaseType==TEST_CASE_TYPES.EQUIVALENCE)
            varName1=[varName1,'{',num2str(simIndex),'}'];
        end
        aline=[aline,'length(',varName1,')'];
        if(k<nParamTypes)
            aline=[aline,', '];
        end


        if(k>1&&mod(k,2)==0&&k<nParamTypes)
            aline=[aline,'...'];
            lines=[lines,{aline}];
            aline=indentL2;
        end
    end
    if(nParamTypes>1)
        aline=[aline,'])'];
    end
    aline=[aline,';'];
    lines=[lines,{aline}];
    lines=[lines,{' '}];

    lines=[lines,{['% ',getString(message('stm:ScriptsView:CreateIterations'))]}];
    lines=[lines,{'for k = 1 : numSteps'}];
    lines=[lines,{[indentL1,'% ',getString(message('stm:ScriptsView:CreateANewTestIterationObject'))]}];
    aline='    testItr = sltestiteration();';
    lines=[lines,{aline}];

    lines=[lines,{' '}];
    lines=[lines,{[indentL1,'% ',getString(message('stm:ScriptsView:SetTestIterationSettings'))]}];
    for k=1:nParamTypes
        paramName=paramTypeList(k).paramType;
        varName=getVariableName(paramTypeList(k).paramType);
        varName2=[varName,'{k}'];
        simIndex=simIndexList(k);
        if(testCaseType==TEST_CASE_TYPES.EQUIVALENCE)
            varName2=[varName,'{',num2str(simIndex),'}{','k}'];
        end

        line=['    setTestParam(testItr, ','''',paramName,'''',', ',varName2];
        if(testCaseType==TEST_CASE_TYPES.EQUIVALENCE)
            line=[line,', ','''','SimulationIndex','''',', ',num2str(simIndex)];
        end
        line=[line,');'];
        lines=[lines,{line}];
    end

    lines=[lines,{' '}];
    lines=[lines,{[indentL1,'% ',getString(message('stm:ScriptsView:CommitIteration'))]}];
    line='    addIteration(sltest_testCase, testItr);';
    line=[line,' % ',getString(message('stm:ScriptsView:IterationNameIsOptional'))];
    lines=[lines,{line}];
    lines=[lines,{'end'}];

    lines=[lines,{' '}];
    scr=char(join(lines,newline));
end

function varName=getVariableName(paramType)
    varName='';
    if(strcmp(paramType,'ParameterSet'))
        varName='sltest_parameterSets';
    elseif(strcmp(paramType,'Baseline'))
        varName='sltest_baselines';
    elseif(strcmp(paramType,'ExternalInput'))
        varName='sltest_externalInputs';
    elseif(strcmp(paramType,'ConfigSet'))
        varName='sltest_configSets';
    elseif(strcmp(paramType,'SignalBuilderGroup'))
        varName=getString(message('stm:ScriptsView:Variable_sltest_signalEditorScenarios'));
    elseif(strcmp(paramType,'LoggedSignalSet'))
        varName='sltest_loggedSignalSets';
    elseif(strcmp(paramType,'TestSequenceScenario'))
        varName='sltest_testSequenceScenarios';
    end
end

function varName=getParameterName(paramType)
    varName='';
    if(strcmp(paramType,'ParameterSet'))
        varName=getString(message('stm:Parameters:ParameterSets'));
    elseif(strcmp(paramType,'Baseline'))
        varName=getString(message('stm:ResultsTree:Baselines'));
    elseif(strcmp(paramType,'ExternalInput'))
        varName=getString(message('stm:InputsView:ExternalInputs'));
    elseif(strcmp(paramType,'ConfigSet'))
        varName=getString(message('stm:objects:ConfigSets'));
    elseif(strcmp(paramType,'SignalBuilderGroup'))
        varName=getString(message('stm:InputsView:SignalBuilderGroups'));
    elseif(strcmp(paramType,'LoggedSignalSet'))
        varName=getString(message('stm:OutputView:Label_LoggedSignalSet'));
    elseif(strcmp(paramType,'TestSequenceScenario'))
        varName=getString(message('stm:objects:TestSequenceScenario'));
    end
end

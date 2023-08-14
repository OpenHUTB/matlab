function[ResultDescription,ResultDetails]=checkSwitchedLinearCallback(sys)





    ResultDescription={};
    ResultDetails={};


    modelAdvisorObj=Simulink.ModelAdvisor.getModelAdvisor(sys);
    modelAdvisorObj.setCheckErrorSeverity(1);


    sscCodeGenWorkflowObjCheck=modelAdvisorObj.getCheckObj('com.mathworks.hdlssc.ssccodegenadvisor.workflowObjectCheck');
    sscCodeGenWorkflowObj=sscCodeGenWorkflowObjCheck.ResultData;

    try

        sscCodeGenWorkflowObj.checkSwitchedLinear();
        solverBlks=sscCodeGenWorkflowObj.SolverConfiguration;
        dynamicSystemObj=sscCodeGenWorkflowObj.DynamicSystemObj;
        numNetworks=numel(dynamicSystemObj);




        formatTemplate=ModelAdvisor.FormatTemplate('ListTemplate');
        setSubResultStatus(formatTemplate,'Pass');
        if sscCodeGenWorkflowObj.SolverTypes(1)
            setSubResultStatusText(formatTemplate,...
            ModelAdvisor.Text(strcat('Model ''',...
            sscCodeGenWorkflowObj.SimscapeModel,''' passed compatibility check')));

        else
            setSubResultStatusText(formatTemplate,...
            ModelAdvisor.Text(message('hdlcoder:hdlssc:ssccodegenworkflow_SwitchedLinearWorkflow:SwitchedLinearSSCModel',sscCodeGenWorkflowObj.SimscapeModel).getString));
        end
        setSubBar(formatTemplate,0);
        ResultDescription{end+1}=formatTemplate;
        ResultDetails{end+1}={};



        if~sscCodeGenWorkflowObj.GenerateAutomaticLayout&&~sscCodeGenWorkflowObj.SolverTypes(1)
            formatTemplate=ModelAdvisor.FormatTemplate('ListTemplate');
            setSubResultStatus(formatTemplate,'Warn');
            setSubResultStatusText(formatTemplate,...
            ModelAdvisor.Text(message('hdlcoder:hdlssc:ssccodegenworkflow_SwitchedLinearWorkflow:ManyToOneCase').getString));
            ResultDescription{end+1}=formatTemplate;
            ResultDetails{end+1}={};
        end



        netTxt=['Number of Simscape networks present in the model: ',num2str(numNetworks)];
        netObj=ModelAdvisor.Text(netTxt);
        ResultDescription{end+1}=netObj;
        ResultDetails{end+1}={};

        if sscCodeGenWorkflowObj.SolverTypes(1)
            link=strcat('<a href="matlab:simscape.modelstatistics.open(''',...
            sscCodeGenWorkflowObj.SimscapeModel,''', false, false)">',...
            'Model Statistics</a>');
            netObj=ModelAdvisor.Text(link);
            ResultDescription{end+1}=netObj;
            ResultDetails{end+1}={};
        else


            discreteVariableData=sscCodeGenWorkflowObj.DiscreteVariableData;

            for ii=1:numNetworks
                numOfDiffVar=0;
                numOfAlgeVar=0;








                varHashMap=countDuplicateVariable(discreteVariableData{ii});


                diffTableObj=ModelAdvisor.FormatTemplate('TableTemplate');
                setColTitles(diffTableObj,[{'Source'},{'Value'}]);


                algeTableObj=ModelAdvisor.FormatTemplate('TableTemplate');
                setColTitles(algeTableObj,[{'Source'},{'Value'}]);

                varPaths=varHashMap.keys;
                for i=1:numel(varPaths)
                    varPath=varPaths{i};


                    if varHashMap(varPath).count==1
                        [numOfDiffVar,numOfAlgeVar]=addRow2Table(diffTableObj,...
                        algeTableObj,...
                        varPath,...
                        varHashMap(varPath),...
                        numOfDiffVar,numOfAlgeVar);



                    else
                        for j=1:varHashMap(varPath).count
                            [numOfDiffVar,numOfAlgeVar]=addRow2Table(diffTableObj,...
                            algeTableObj,...
                            [varPath,'(',num2str(j),')'],...
                            varHashMap(varPath),...
                            numOfDiffVar,numOfAlgeVar);
                        end
                    end
                end



                sscCodeGenWorkflowObj.NumberOfDifferentialVariables(ii)=numOfDiffVar;

                netTxt=['Details related to the Simscape network ',getBlockHyperlink(strrep(solverBlks{ii},newline,' '),solverBlks{ii})];
                netObj=ModelAdvisor.Text(netTxt);
                setBold(netObj,'true');
                ResultDescription{end+1}=netObj;
                ResultDetails{end+1}={};


                ftObj=ModelAdvisor.FormatTemplate('TableTemplate');
                setSubTitle(ftObj,'Details');
                setInformation(ftObj,['Number of Discrete Variables: ',num2str(numOfDiffVar+numOfAlgeVar)]);
                setSubBar(ftObj,0);
                ResultDescription{end+1}=ftObj;%#ok<*AGROW>
                ResultDetails{end+1}={};

                setTableTitle(diffTableObj,{['Number of Differential Variables: ',num2str(numOfDiffVar)]});
                setTableTitle(algeTableObj,{['Number of Algebraic Variables: ',num2str(numOfAlgeVar)]});

                setSubBar(diffTableObj,0);
                ResultDescription{end+1}=diffTableObj;
                ResultDetails{end+1}={};






                if numOfDiffVar==0
                    txtObj=ModelAdvisor.Text(['Number of Differential Variables: ',num2str(numOfDiffVar)]);
                    ResultDescription{end+1}=txtObj;
                    ResultDetails{end+1}={};
                end

                setSubBar(algeTableObj,0);
                ResultDescription{end+1}=algeTableObj;
                ResultDetails{end+1}={};






                if numOfAlgeVar==0
                    txtObj=ModelAdvisor.Text(['Number of Algebraic Variables: ',num2str(numOfAlgeVar)]);
                    ResultDescription{end+1}=txtObj;
                    ResultDetails{end+1}={};
                end




                unnamedConverterList=checkConverterBlockName(sscCodeGenWorkflowObj.SpsPssConverterBlks{ii});
                if numel(unnamedConverterList)>0
                    txtObj=ModelAdvisor.Text('Recommended Naming Changes');
                    setBold(txtObj,'true');
                    ResultDescription{end+1}=txtObj;
                    ResultDetails{end+1}={};

                    msg=[message('hdlcoder:hdlssc:ssccodegenworkflow_SwitchedLinearWorkflow:UnnamedSPSBlocks1').getString,...
                    newline,...
                    message('hdlcoder:hdlssc:ssccodegenworkflow_SwitchedLinearWorkflow:UnnamedSPSBlocks2').getString,...
                    newline,...
                    newline,...
                    message('hdlcoder:hdlssc:ssccodegenworkflow_SwitchedLinearWorkflow:UnnamedSPSBlocks3').getString];
                    txtObj=ModelAdvisor.Text(msg);

                    setRetainSpaceReturn(txtObj,'true');
                    ResultDescription{end+1}=txtObj;
                    ResultDetails{end+1}={};
                    listObj=ModelAdvisor.List();
                    listObj.setType('bulleted');
                    for j=1:numel(unnamedConverterList)
                        listObj.addItem(ModelAdvisor.Text(unnamedConverterList{j}));
                    end
                    ResultDescription{end+1}=listObj;
                    ResultDetails{end+1}={};
                end
            end
        end
        modelAdvisorObj.setCheckResultStatus(true);

        dynamicSystems=dynamicSystemObj;
        linearModelWithPE=0;
        hasIntModes=false;
        hasDiscreteExplicit=false;
        for i=1:numel(dynamicSystems)
            dynamicSystem=dynamicSystems{i};
            solverSystem=NetworkEngine.SolverSystem(dynamicSystem);
            if((sscCodeGenWorkflowObj.SolverTypes(i))&&(solverSystem.IsCondSwitchedLinear))
                linearModelWithPE=linearModelWithPE+1;
            end
            if(numel(dynamicSystem.MajorModeData)>0)
                hasDiscreteExplicit=true;
            end
            if(numel(dynamicSystem.IntModes)>0)
                hasIntModes=true;
            end
        end

        if(linearModelWithPE==numel(dynamicSystems)&&~hasDiscreteExplicit&&~hasIntModes)
            formatTemplate=ModelAdvisor.FormatTemplate('ListTemplate');
            setSubResultStatus(formatTemplate,'Warn');
            setSubResultStatusText(formatTemplate,ModelAdvisor.Text(message('hdlcoder:hdlssc:ssccodegenworkflow_SwitchedLinearWorkflow:LinearSSCModelRecommendationToBE').getString));

            setSubBar(formatTemplate,0);
            ResultDescription{end+1}=formatTemplate;
            ResultDetails{end+1}={};


            modelAdvisorObj.setCheckErrorSeverity(0);
            modelAdvisorObj.setCheckResultStatus(false);
        end
        resetSubsequentTasks(modelAdvisorObj);
    catch me
        [formatTemplate1,formatTemplate2]=handleSwichedLinearError(me,sscCodeGenWorkflowObj);




        ResultDescription{end+1}=formatTemplate1;
        ResultDetails{end+1}={};
        if~isempty(formatTemplate2)
            ResultDescription{end+1}=formatTemplate2;
            ResultDetails{end+1}={};
        end

        modelAdvisorObj.setCheckResultStatus(false);
    end
    function[numOfDiffVar,numOfAlgeVar]=addRow2Table(diffTableObj,algeTableObj,variablePath,variableData,numOfDiffVar,numOfAlgeVar)


        if variableData.is_diff==1
            numOfDiffVar=numOfDiffVar+1;
            addRow(diffTableObj,...
            {getBlockHyperlink(variableData.object,variablePath),...
            variableData.description});

        else
            numOfAlgeVar=numOfAlgeVar+1;
            addRow(algeTableObj,...
            {getBlockHyperlink(variableData.object,variablePath),...
            variableData.description});
        end
    end

    function varHashMap=countDuplicateVariable(data)








        varHashMap=containers.Map;

        for k=1:numel(data)

            if~isempty(data(k).object)
                curPath=data(k).path;
                if varHashMap.isKey(curPath)
                    tempStruct=varHashMap(curPath);
                    tempStruct.count=tempStruct.count+1;
                    varHashMap(curPath)=tempStruct;
                else
                    curStruct=struct;
                    curStruct.object=data(k).object;
                    curStruct.description=data(k).description;
                    curStruct.is_diff=data(k).is_diff;
                    curStruct.count=1;
                    varHashMap(curPath)=curStruct;
                end
            end
        end
    end
end

function unnamedConverterList=checkConverterBlockName(converterBlks)














    converterPattern='^Simulink-PS Converter[\d]*$|^PS-Simulink Converter[\d]*$';
    tempConverterList=cell(numel(converterBlks),1);
    unnamedConverterCount=0;

    for i=1:numel(converterBlks)
        converterBlkPath=strrep(converterBlks{i},newline,' ');
        separatePath=strsplit(converterBlkPath,'/');
        converterBlk=separatePath{end};
        matchIndices=regexp(converterBlk,converterPattern);


        if numel(matchIndices)>0
            unnamedConverterCount=unnamedConverterCount+1;
            hyperlink=getBlockHyperlink(converterBlkPath,converterBlk);
            tempConverterList{unnamedConverterCount}=hyperlink;
        end
    end
    unnamedConverterList=tempConverterList(1:unnamedConverterCount,:);
end
function hyperlink=getBlockHyperlink(path,displayedText)

    hyperlink=['<a href="matlab:Simulink.internal.highlightResourceOwnerBlock(''',path,''')">',displayedText,'</a>'];
end


function[formatTemplate1,formatTemplate2]=handleSwichedLinearError(me,sscCodeGenWorkflowObj)

    simscapeModel=sscCodeGenWorkflowObj.SimscapeModel;

    altMessage='';

    listHeader='';

    listBody=[];

    recomendationKey='';

    useModelName=false;
    switch me.identifier
    case 'checkSwitchedLinear:NonlinearSSCModelBE'

        listHeader='Nonlinear blocks in the model:';
        listBody=sscCodeGenWorkflowObj.NonlinearBlocks;

        recomendationKey='NonlinearSSCModelRecommendationToPartitioning';
        useModelName=false;
    case 'checkSwitchedLinear:NonlinearSSCModel'

        listHeader='Nonlinear blocks in the model:';
        listBody=sscCodeGenWorkflowObj.NonlinearBlocks;
        recomendationKey='NonlinearSSCModelRecommendation';
        useModelName=true;



    case 'checkSwitchedLinear:TimeVaryingLinearBlocks'

        recomendationKey='TimeVaryingLinearBlocksRecommendation';
        useModelName=true;

    case 'checkSwitchedLinear:Mulitbody'

        listHeader='Mulitbody blocks in the model:';
        listBody=sscCodeGenWorkflowObj.MulitBodyBlocks;
        recomendationKey='MulitbodySSCModelRecommendation';
        useModelName=true;


    case 'checkSwitchedLinear:Source'

        listHeader='Time dependent source blocks in model:';
        listBody=sscCodeGenWorkflowObj.SourceBlocks;
        recomendationKey='SourceBlockRecommendation';
        useModelName=true;

    case 'checkSwitchedLinear:Sink'

        listHeader='Unsupported sink blocks in model:';
        listBody=sscCodeGenWorkflowObj.SinkBlocks;
        recomendationKey='SinkBlockRecommendation';
        useModelName=true;

    case 'checkSwitchedLinear:ForEachBlock'

        listHeader='ForEach block in the model subsystem containing solver block :';
        listBody=sscCodeGenWorkflowObj.ForEachBlocks;
        recomendationKey='ForEachBlockRecommendation';
        useModelName=true;

    case 'checkSwitchedLinear:LinkedSPSBlocks'

        listHeader='Linked subsystems containing PS-S or S-PS converters:';
        listBody=sscCodeGenWorkflowObj.InvalidSPSBlocks;
        recomendationKey='LinkedSPSBlocksRecommendation';
        useModelName=true;

    case 'checkSwitchedLinear:AtomicSPSBlocks'

        listHeader='Atomic subsystems containing PS-S or S-PS converters:';
        listBody=sscCodeGenWorkflowObj.InvalidSPSBlocks;
        recomendationKey='AtomicSPSBlocksRecommendation';

    case 'checkSwitchedLinear:RefSPSBlocks'

        listHeader='Referenced subsystems containing PS-S or S-PS converters:';
        listBody=sscCodeGenWorkflowObj.InvalidSPSBlocks;
        recomendationKey='RefSPSBlocksRecommendation';

    case 'checkSwitchedLinear:FilterSPSBlocks'

        listBody=sscCodeGenWorkflowObj.InvalidSPSBlocks;
        recomendationKey='FilterSPSBlocksRecommendation';

    case 'checkSwitchedLinear:FilterSPSBlocksBE'

        listBody=sscCodeGenWorkflowObj.InvalidSPSBlocks;
        recomendationKey='FilterSPSBlocksRecommendationBE';

    case 'checkSwitchedLinear:UnitPSSBlocks'

        listBody=sscCodeGenWorkflowObj.InvalidSPSBlocks;
        recomendationKey='UnitPSSBlocksRecommendation';

    case 'checkSwitchedLinear:EventBlks'

        listHeader='Event based blocks:';
        listBody=sscCodeGenWorkflowObj.EventBlocks;
        recomendationKey='EventBlockRecommendation';
        useModelName=true;

    case 'physmod:simscape:compiler:core:ds:CannotGenerateMATLABFunction'




        modeChartBlks=split(me.message,newline);
        modeChartBlks=modeChartBlks(2:end-1);
        modeChartBlks=strtrim(modeChartBlks);
        modeChartBlks=cellfun(@(x)x(2:end-1),modeChartBlks,'UniformOutput',false);
        listBody=unique(modeChartBlks);

        listHeader='Unsupported blocks:';
        recomendationKey='ModeFcnErrorRecommendation';
        useModelName=true;
        altMessage=message('hdlcoder:hdlssc:ssccodegenworkflow_SwitchedLinearWorkflow:ModeFcnError').getString;





    end
    [formatTemplate1,formatTemplate2]=utilCreateAdvisorError(me,altMessage,listHeader,...
    listBody,recomendationKey,simscapeModel,useModelName);

end



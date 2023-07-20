classdef TestSequence<Sldv.harnesssource.Source




    methods
        function obj=TestSequence(blockH)
            obj@Sldv.harnesssource.Source(blockH);
        end

        function sourceType=getSourceType(~)
            sourceType='Test Sequence';
        end

        function numTestCases=getNumberOfTestcases(obj)
            numTestCases=numel(sltest.testsequence.getAllScenarios(obj.blockH));
            return;
        end

        function actScenarioIdx=getActiveTestcase(obj)
            scenarios=sltest.testsequence.getAllScenarios(obj.blockH);
            activeScenario=sltest.testsequence.getActiveScenario(obj.blockH);
            actScenarioIdx=find(strcmp(scenarios,activeScenario));
        end

        function setActiveTestcase(obj,testCaseID)


            harnessName=get_param(obj.blockH,'Parent');
            sourceBlock=[harnessName,'/Inputs'];
            obj.closeTestSequenceEditor(harnessName,sourceBlock);

            scenarios=sltest.testsequence.getAllScenarios(obj.blockH);
            sltest.testsequence.activateScenario(obj.blockH,scenarios{testCaseID});
        end

        function numSignals=getNumberOfSignals(obj)
            numSignals=length(sltest.testsequence.findSymbol(obj.blockH,'Scope','Output'));
        end

        function signalNames=getNamesOfSignals(obj)
            signalNames=sltest.testsequence.findSymbol(obj.blockH,'Scope','Output');
        end

        function testCaseNames=getNamesOfTestcases(obj)
            testCaseNames=sltest.testsequence.getAllScenarios(obj.blockH);
        end

        function addTestcases(obj,sldvData,~,~)






            inputSignalNames=matlab.lang.makeValidName(sldvData.inputSignalNames);
            blkPath=getfullname(obj.blockH);


            for i=1:length(inputSignalNames)
                sltest.testsequence.addSymbol(blkPath,inputSignalNames{i},...
                'Data','Output');
                if strcmp(sldvData.inputSignalComplexity{i},'complex')
                    sltest.testsequence.editSymbol(blkPath,inputSignalNames{i},...
                    'isComplex','On');
                end
            end

            [~,numOfTestCases]=size(sldvData.dataValues);


            scenarioNamePrefix=Sldv.harnesssource.Source.getTestCasePrefix(sldvData.Mode);
            sltest.testsequence.useScenario(obj.blockH,scenarioNamePrefix+"_1");

            for id=1:numOfTestCases





                scenarioName=sprintf("%s_%d",scenarioNamePrefix,id);




                timeSteps=sldvData.timeStep{id};
                dataSetArray=sldvData.dataValues(:,id);
                dataSetArray=cellfun(@Sldv.harnesssource.TestSequence.extractValues,dataSetArray,'UniformOutput',false);
                dataSetArray=cellfun(@string,dataSetArray,'UniformOutput',false);
                dataSetArray=[dataSetArray{:}];
                dataSetArray=reshape(dataSetArray,length(timeSteps),[])';



                dataSetArray=dataSetArray(:,[1,3:2:end-1]);
                timeSteps=timeSteps([1,3:2:end-1]);
                if id~=1
                    sltest.testsequence.addScenario(obj.blockH,scenarioName);
                end





                sltest.testsequence.deleteStep(obj.blockH,scenarioName+".step_2");
                sltest.testsequence.deleteTransition(obj.blockH,scenarioName+".step_1",1);
                obj.addStepsInTestCase(dataSetArray,inputSignalNames,...
                scenarioName,timeSteps);
            end

        end

        function closeTestSequenceEditor(~,harnessName,sourceBlock)
            rt=sfroot;
            hM=rt.find('-isa','Stateflow.Machine','Name',harnessName);
            chart=hM.find('-isa','Stateflow.ReactiveTestingTableChart','Path',sourceBlock);
            sttman=Stateflow.STT.StateEventTableMan(chart.Id);
            sttman.viewManager.closeUI;
        end





        function getTimeAsCellArray(obj)

        end
        function getDataAsCellArray(obj)


        end
        function merge(obj,destObj)

        end
    end

    methods(Access=private)
        function addStepsInTestCase(obj,dataSetArray,inputSignalNames,...
            currentScenario,timeSteps)













            numOfSteps=length(timeSteps);





            testCasePrefix=inputSignalNames'+repmat("=",length(inputSignalNames),1);
            testCaseSuffix=repmat(";\n",length(inputSignalNames),1);

            for step=1:numOfSteps



                currentValues=testCasePrefix+dataSetArray(:,step)+...
                testCaseSuffix;
                currentStepName=sprintf("%s.step_%d",currentScenario,step);
                prevStepName=sprintf("%s.step_%d",currentScenario,step-1);
                transitionCondition=sprintf("t >= %f",timeSteps(step));

                if step==1
                    sltest.testsequence.editStep(obj.blockH,currentStepName,...
                    'Action',sprintf(sprintf("%s",currentValues)));
                else
                    sltest.testsequence.addStep(obj.blockH,currentStepName,...
                    'Action',sprintf(sprintf("%s",currentValues)));
                    sltest.testsequence.addTransition(obj.blockH,prevStepName,...
                    transitionCondition,currentStepName);
                end
            end

        end
    end

    methods(Static)
        function values=extractValues(cellValue)


            switch class(cellValue)
            case 'embedded.fi'

                values=cellValue.data;
            otherwise
                values=cellValue;
            end
        end
    end
end


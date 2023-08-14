classdef SignalEditor<Sldv.harnesssource.Source




    methods
        function obj=SignalEditor(blockH)
            obj@Sldv.harnesssource.Source(blockH);
        end

        function sourceType=getSourceType(~)
            sourceType='Signal Editor';
        end

        function numTestCases=getNumberOfTestcases(obj)
            numTestCases=str2double(get_param(obj.blockH,'NumberOfScenarios'));
        end

        function numSignals=getNumberOfSignals(obj)
            numSignals=str2double(get_param(obj.blockH,'NumberOfSignals'));
        end

        function[errstr,destStartScenarioCnt,srcScenarioCnt]=merge(obj,destObj)
            errstr='';
            srcH=obj.blockH;
            destH=destObj.blockH;
            srcFileName=get_param(srcH,'FileName');
            srcScenarioCnt=obj.getNumberOfTestcases;
            destStartScenarioCnt=destObj.getNumberOfTestcases;
            destFileName=get_param(destH,'FileName');

            if strcmp(srcFileName,destFileName)
                errstr=getString(message('Sldv:HarnessUtils:MakeSystemTestHarness:MergeWithSelf'));
                return;
            end



            if~isequal(obj.getNamesOfSignals,destObj.getNamesOfSignals)
                errstr=getString(message('Sldv:HarnessUtils:MakeSystemTestHarness:UnableMergeHarnessModels',...
                get_param(bdroot(srcH),'Name'),get_param(bdroot(destH),'Name'),...
                getfullname(srcH),getfullname(destH)));
                return;
            end

            srcScenariosStruct=load(srcFileName);
            srcScenarios=fieldnames(srcScenariosStruct);
            destScenariosStruct=load(destFileName);
            destScenarios=fieldnames(destScenariosStruct);




            previousNumOfDigits=numel(num2str(destStartScenarioCnt));
            currentNumOfDigits=numel(num2str(destStartScenarioCnt+srcScenarioCnt));

            if(previousNumOfDigits~=currentNumOfDigits)
                destScenariosStruct=Sldv.harnesssource.SignalEditor.updateTestCasesLabels(currentNumOfDigits,...
                destScenariosStruct,destScenarios,"TestCase");
            end

            for id=1:srcScenarioCnt
                scenarioNameSuffix=Sldv.harnesssource.SignalEditor.getTestCaseSuffix(currentNumOfDigits,id+destStartScenarioCnt);
                scenarioToAppend=sprintf('TestCase_%s',scenarioNameSuffix);
                destScenariosStruct.(scenarioToAppend)=srcScenariosStruct.(srcScenarios{id});
            end

            save(destFileName,'-struct','destScenariosStruct');


            set_param(destH,'FileName',destFileName);



            srcReqs=rmi.getReqs(srcH);
            if~isempty(srcReqs)
                rmi.catReqs(destH,srcReqs);
            end
        end

        function time=getTimeAsCellArray(obj)
            fileName=get_param(obj.blockH,'FileName');
            scenarioStruct=load(fileName);
            scenarios=fieldnames(scenarioStruct);
            time={};
            for id=1:length(scenarios)
                ds=scenarioStruct.(scenarios{id});
                timeForThisScenario={};
                for ele=1:ds.numElements
                    timeForThisScenario=obj.extractTimeHelper(ds{ele},timeForThisScenario);
                end
                time(1:length(timeForThisScenario),id)=timeForThisScenario';%#ok<AGROW>
            end
        end

        function data=getDataAsCellArray(obj)
            fileName=get_param(obj.blockH,'FileName');
            scenarioStruct=load(fileName);
            scenarios=fieldnames(scenarioStruct);
            data={};
            for id=1:length(scenarios)
                ds=scenarioStruct.(scenarios{id});
                dataForThisScenario={};
                for ele=1:ds.numElements
                    dataForThisScenario=obj.extractDataHelper(ds{ele},dataForThisScenario);
                end
                data(1:length(dataForThisScenario),id)=dataForThisScenario';%#ok<AGROW>
            end
        end


        function setActiveTestcase(obj,testCaseId)
            set_param(obj.blockH,'ActiveScenario',testCaseId);
        end

        function actSigbIdx=getActiveTestcase(obj)
            fileName=get_param(obj.blockH,'FileName');
            scenarioStruct=load(fileName);
            scenarios=fields(scenarioStruct);
            activeScenario=get_param(obj.blockH,'ActiveScenario');
            actSigbIdx=find(strcmp(scenarios,activeScenario));
        end

        function testcaseNames=getNamesOfTestcases(obj)
            fileName=get_param(obj.blockH,'FileName');
            scenarioStruct=load(fileName);
            testcaseNames=fields(scenarioStruct);
        end

        function signalNames=getNamesOfSignals(obj)
            fileName=get_param(obj.blockH,'FileName');
            activeScenario=get_param(obj.blockH,'ActiveScenario');
            scenarioStruct=load(fileName,activeScenario);
            scenario=scenarioStruct.(activeScenario);
            signalNames=scenario.getElementNames;
        end

        function addTestcases(obj,sldvData,appendMode,usedSignals)

            scenarioNamePrefix=Sldv.harnesssource.Source.getTestCasePrefix(sldvData.AnalysisInformation.Options.Mode);
            datasetArray=sldvsimdata(sldvData);


            if~isempty(usedSignals)
                for sig=length(usedSignals):-1:1
                    if~iscell(usedSignals{sig})&&usedSignals{sig}==0
                        for dsid=1:length(datasetArray)
                            datasetArray(dsid)=datasetArray(dsid).removeElement(sig);
                        end
                    end
                end
            end









            currActiveTestCase=obj.getActiveTestcase;

            matFile=get_param(obj.blockH,'FileName');
            numNewTestCases=length(datasetArray);
            numTestCasesDigits=numel(num2str(numNewTestCases));
            saveStruct=[];
            numExistingTestCases=0;

            if appendMode


                numExistingTestCases=obj.getNumberOfTestcases;
                numExistingTestCasesDigits=numel(num2str(numExistingTestCases));
                newNumOfDigits=numel(num2str(numExistingTestCases+numNewTestCases));
                currentScenarioStruct=load(matFile);

                if numExistingTestCasesDigits~=newNumOfDigits
                    currentScenarioStruct=Sldv.harnesssource.SignalEditor.updateTestCasesLabels(newNumOfDigits,currentScenarioStruct,...
                    fieldnames(currentScenarioStruct),scenarioNamePrefix);
                end

                numTestCasesDigits=newNumOfDigits;
            end

            for id=1:numNewTestCases
                scenarioNameSuffix=Sldv.harnesssource.SignalEditor.getTestCaseSuffix(numTestCasesDigits,id+numExistingTestCases);
                scenarioToAppend=sprintf('%s_%s',scenarioNamePrefix,scenarioNameSuffix);
                saveStruct.(scenarioToAppend)=datasetArray(id);
            end
            if appendMode
                save(matFile,'-struct','currentScenarioStruct');
                save(matFile,'-struct','saveStruct','-append');
                harnessFilePath=bdroot(obj.blockH);
                if~ischar(harnessFilePath)
                    harnessFilePath=getfullname(harnessFilePath);
                end
                if strcmp(sldvData.AnalysisInformation.Options.Mode,'TestGeneration')
                    Sldv.HarnessUtils.setupMultiSimDesignStudy(harnessFilePath,obj);
                end
                set_param(obj.blockH,'ActiveScenario',currActiveTestCase);
            else
                scenario_names=fields(saveStruct);
                save(matFile,'-struct','saveStruct');
                active_scenario=scenario_names{1};
                signal_names=saveStruct.(active_scenario).getElementNames;
                active_signal=signal_names{1};
                set_param(obj.blockH,'ActiveScenario',active_scenario);
                set_param(obj.blockH,'ActiveSignal',active_signal);
            end
        end
    end

    methods(Static)
        function updatedDestScenariosStruct=updateTestCasesLabels(currentNumOfDigits,...
            destScenariosStruct,destScenarios,scenarioNamePrefix)









            updatedDestScenariosStruct=[];
            for id=1:length(destScenarios)
                scenarioNameSuffix=Sldv.harnesssource.SignalEditor.getTestCaseSuffix(currentNumOfDigits,id);
                scenarioNewName=sprintf('%s_%s',scenarioNamePrefix,scenarioNameSuffix);
                updatedDestScenariosStruct.(scenarioNewName)=destScenariosStruct.(destScenarios{id});
            end
        end

        function TestCaseSuffix=getTestCaseSuffix(numTestCasesDigits,currentTestCaseIdx)








            TestCaseSuffix=sprintf("%0*d",numTestCasesDigits,currentTestCaseIdx);
        end
    end

    methods(Access='private')
        function time=extractTimeHelper(obj,dsElement,time)
            switch class(dsElement)
            case 'Simulink.SimulationData.Signal'


                time=obj.extractTimeHelper(dsElement.Values,time);
            case 'timeseries'
                time{end+1}=dsElement.Time;
            case 'struct'
                allfields=fieldnames(dsElement);
                for id=1:length(allfields)
                    thisField=dsElement.(allfields{id});
                    time=obj.extractTimeHelper(thisField,time);
                end
            end

        end

        function data=extractDataHelper(obj,dsElement,data)
            switch class(dsElement)
            case 'Simulink.SimulationData.Signal'


                data=obj.extractDataHelper(dsElement.Values,data);
            case 'timeseries'
                data{end+1}=dsElement.Data;
            case 'struct'
                allfields=fieldnames(dsElement);
                for id=1:length(allfields)
                    thisField=dsElement.(allfields{id});
                    data=obj.extractDataHelper(thisField,data);
                end
            end
        end
    end
end



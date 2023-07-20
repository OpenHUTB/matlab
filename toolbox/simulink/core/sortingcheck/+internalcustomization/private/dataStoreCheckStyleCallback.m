function[ResultDescription]=dataStoreCheckStyleCallback(system,CheckObj)




    type=getBlockOrderCheckType(CheckObj.ID);


    [passed,hasDataStores]=doSimpleAnalysis(system);

    if~passed

        [passed,results]=analyzeSortedOrderForDataStores(system,CheckObj,type);
    end


    if passed
        [ResultDescription]=generatePassReport(hasDataStores,type);
    else
        [ResultDescription]=generateReport(results,type);
    end



    if passed
        checkPassed(system,CheckObj);
    else
        checkFailed(system,CheckObj,results);
    end


    function[passed,hasDataStores]=doSimpleAnalysis(system)

        passed=true;
        hasDataStores=false;

        sysHandle=get_param(system,'handle');


        if~hasDataStores

            dsaList=getDataStoreAccessorBlocks(sysHandle);
            hasDataStores=~isempty(dsaList);
            passed=~hasDataStores;
        end

        if~hasDataStores

            dsmList=getDataStoreMemoryBlocks(sysHandle);
            hasDataStores=~isempty(dsmList);
            passed=~hasDataStores;
        end



        function[NoOrderChange,results]=analyzeSortedOrderForDataStores(system,CheckObj,type)

















            prevResult=CheckObj.ResultData;

            results=getDataStoreExecutionInfo(system,prevResult,type);

            NoOrderChange=isempty(results);

            function html=generatePassReport(hasDataStoreBlocks,type)
                if hasDataStoreBlocks
                    if(strcmp(type,'FEATUREONOFF'))
                        html='<p>The execution orders for Data Store Read or Data Store Write blocks do not change. </p>';
                    else
                        html='<p>The execution orders for Data Store Read or Data Store Write blocks do not change (Simulink functions and function-call subsystems are ignored in this check, as their orders are determined by the callers). </p>';
                    end
                else
                    html='<p>The system does not have any Data Store Read or Data Store Write blocks. </p>';
                end


                function list=getDataStoreMemoryBlocks(system)



                    list=find_system(system,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'BlockType','DataStoreMemory');


                    function list=getDataStoreAccessorBlocks(system)


                        dsr=find_system(system,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'BlockType','DataStoreRead');
                        dsw=find_system(system,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'BlockType','DataStoreWrite');
                        list=[dsr;dsw];





                        function checkPassed(system,CheckObj)

                            ElementResults=ModelAdvisor.ResultDetail;
                            ElementResults.IsInformer=true;
                            ElementResults.Description=DAStudio.message('Simulink:tools:MADataStoreExecutionOrderPassDesc');
                            ElementResults.Status=DAStudio.message('Simulink:tools:MADataStoreExecutionOrderPassMsg');

                            mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
                            mdladvObj.setCheckResultStatus(true);
                            CheckObj.setResultDetails(ElementResults);


                            CheckObj.ResultData=[];


                            function checkFailed(system,CheckObj,results)



                                ElementResults(1,numel(results))=ModelAdvisor.ResultDetail;
                                for i=1:numel(ElementResults)
                                    if ishandle(results{i}.DataStoreMemoryBlock)
                                        ModelAdvisor.ResultDetail.setData(ElementResults(i),'SID',results{i}.DataStoreMemoryBlock);
                                        ElementResults(i).Description=DAStudio.message('Simulink:tools:MADataStoreExecutionOrderFailDesc');
                                        ElementResults(i).Status=DAStudio.message('Simulink:tools:MADataStoreExecutionOrderFailMsg');
                                        ElementResults(i).RecAction=DAStudio.message('Simulink:tools:MADataStoreExecutionOrderFailAction');
                                    end
                                end

                                mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
                                mdladvObj.setCheckResultStatus(false);
                                mdladvObj.setActionEnable(true);
                                CheckObj.setResultDetails(ElementResults);
                                CheckObj.ResultData=results;

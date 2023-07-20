classdef MulticoreSpeedupDataSource<DAStudio.WebDDG





    properties
UIObj
MappingData
Data
    end

    methods
        function obj=MulticoreSpeedupDataSource(uiObj)
            obj.UIObj=uiObj;
        end

        function mappingData=get.MappingData(obj)
            mappingData=getMappingData(obj.UIObj);
        end

        function updateContents(obj)
            modelName=get(obj.UIObj.ModelH,'Name');
            regionNamesStrArray='';
            suggestedLatenciesStrArray='';
            numSuggestions=0;
            showSingleThreadDesc=false;
            isSingleThreadLogicalStrArray='';
            numSingleThread=0;
            showPerformanceLimitedDesc=false;
            numTallPoleBlock=0;
            tallPoleBlockIsSingleThreadLogicalStrArray='';
            tallPoleBlockPathsStrArray='';
            tallPoleBlockNamesStrArray='';
            tallPoleRatiosUIntStrArray='';
            tallPoleSubsysStrArray='';
            isInsufficientLogicalStrArray='';
            numInsufficient=0;
            for j=1:obj.MappingData.getNumMapping()


                regionNamesStrArray=[regionNamesStrArray,getRegionName(obj.MappingData,j)];


                latencySuggestion=obj.MappingData.getLatencySuggestion(j);
                if~isempty(latencySuggestion)
                    latency=num2str(latencySuggestion);
                    numSuggestions=numSuggestions+1;
                else
                    latency='-1';
                end
                suggestedLatenciesStrArray=[suggestedLatenciesStrArray,latency];


                numTasks=obj.MappingData.getNumTasksBySystem(j);


                isSingleThreadFallback=obj.MappingData.isRegionSingleThread(j);
                isSingleThreadPartitioned=(numTasks<2)&&(~isSingleThreadFallback);



                isInsufficient=obj.MappingData.isRegionInsufficientWork(j);
                isInsufficientDouble=double(isInsufficient);
                isInsufficientLogicalStrArray=[isInsufficientLogicalStrArray,num2str(isInsufficientDouble)];
                numInsufficient=numInsufficient+isInsufficientDouble;





                [tpBlock,tpRatio]=obj.MappingData.getTallPoleData(j);
                tallPoleIsSingleThread=false;
                if~isempty(tpBlock)
                    sep=strfind(tpBlock,'/');
                    delim=',';
                    if isempty(tallPoleBlockPathsStrArray)
                        delim='';
                    end

                    isMultiThread=(numTasks>1);
                    tallPoleIsSingleThread=isSingleThreadPartitioned&&(tpRatio>90)&&(~isInsufficient)&&(~isSingleThreadFallback);
                    showPerformanceLimitedDesc=showPerformanceLimitedDesc||isMultiThread;

                    if isMultiThread||tallPoleIsSingleThread
                        numTallPoleBlock=numTallPoleBlock+1;
                        tallPoleBlockPathsStrArray=[tallPoleBlockPathsStrArray,delim,tpBlock(sep(1)+1:end)];
                        tallPoleBlockNamesStrArray=[tallPoleBlockNamesStrArray,delim,tpBlock(sep(end)+1:end)];
                        tallPoleRatiosUIntStrArray=[tallPoleRatiosUIntStrArray,delim,num2str(tpRatio)];
                        tallPoleSubsysStrArray=[tallPoleSubsysStrArray,delim,getRegionName(obj.MappingData,j)];
                        tallPoleBlockIsSingleThreadLogicalStrArray=[tallPoleBlockIsSingleThreadLogicalStrArray,delim,num2str(tallPoleIsSingleThread)];
                    end
                end


                isSingleThreadDouble=double(isSingleThreadFallback);
                isSingleThreadLogicalStrArray=[isSingleThreadLogicalStrArray,num2str(isSingleThreadDouble)];
                numSingleThread=numSingleThread+isSingleThreadDouble;
                showSingleThreadDesc=showSingleThreadDesc||isSingleThreadFallback||isInsufficient||tallPoleIsSingleThread;


                if j~=obj.MappingData.getNumMapping()
                    regionNamesStrArray=[regionNamesStrArray,','];
                    suggestedLatenciesStrArray=[suggestedLatenciesStrArray,','];
                    isSingleThreadLogicalStrArray=[isSingleThreadLogicalStrArray,','];
                    isInsufficientLogicalStrArray=[isInsufficientLogicalStrArray,','];
                end
            end


            multithreadedCost=0;
            totalShare=0;
            maxNumTasks=0;
            regionCosts='';
            regionNamesStrArray='';
            regionTasks='';

            for j=1:obj.MappingData.getNumMapping()
                maxTaskCost=obj.MappingData.getMaxTaskCost(j);
                cost=obj.MappingData.getRegionCost(j);
                share=obj.MappingData.getRegionShare(j);

                numTasks=obj.MappingData.getNumTasksBySystem(j);
                if numTasks>maxNumTasks
                    maxNumTasks=numTasks;
                end

                regionTasks=[regionTasks,num2str(numTasks)];
                regionNamesStrArray=[regionNamesStrArray,getRegionName(obj.MappingData,j)];
                regionCosts=[regionCosts,num2str(double(cost)/1000)];
                if j~=obj.MappingData.getNumMapping()
                    regionTasks=[regionTasks,','];
                    regionNamesStrArray=[regionNamesStrArray,','];
                    regionCosts=[regionCosts,','];
                end
                if numTasks~=1
                    if share~=0&&cost~=0&&maxTaskCost~=0
                        multithreadedCost=multithreadedCost+share*(double(maxTaskCost)/double(cost));
                        totalShare=totalShare+share;
                    end
                end
            end
            speedup=1/(1-totalShare+multithreadedCost);

            if obj.MappingData.getCostMethod==slmulticore.CostMethod.Profiling
                method='profiling';
            elseif obj.MappingData.getCostMethod==slmulticore.CostMethod.Estimation
                method='estimation';
            else
                method='simulation';
            end

            threshold=num2str(obj.MappingData.getMultithreadingThreshold);
            numCores=num2str(obj.MappingData.getNumCores);
            status=getStatus(multicoredesigner.internal.getAppContext(obj.UIObj.ModelH));
            connector.ensureServiceOn;
            url=[connector.getUrl('toolbox/shared/sl_multicore/mcdwidgets/index.html'),...
            '&ui=analysisreport',...
            '&status=',char(status),...
            '&speedup=',num2str(speedup),...
            '&totalshare=',num2str(totalShare*100),...
            '&numtasks=',num2str(maxNumTasks),...
            '&method=',method,...
            '&threshold=',threshold,...
            '&numcores=',numCores,...
            '&regionnames=',regionNamesStrArray,...
            '&regioncosts=',regionCosts,...
            '&regiontasks=',regionTasks,...
            '&model=',modelName,...
            '&numsuggestions=',num2str(numSuggestions),...
            '&suggestedlatencies=',suggestedLatenciesStrArray,...
            '&showsinglethreaddesc=',num2str(showSingleThreadDesc),...
            '&numsinglethread=',num2str(numSingleThread),...
            '&issinglethread=',isSingleThreadLogicalStrArray,...
            '&showperformancepimiteddesc=',num2str(showPerformanceLimitedDesc),...
            '&numtallpoleblocks=',num2str(numTallPoleBlock),...
            '&tallpoleblockissinglethread=',tallPoleBlockIsSingleThreadLogicalStrArray,...
            '&tallpoleblocks=',tallPoleBlockPathsStrArray,...
            '&tallpoleblocknames=',tallPoleBlockNamesStrArray,...
            '&tallpoleratio=',tallPoleRatiosUIntStrArray,...
            '&tallpolesubsys=',tallPoleSubsysStrArray,...
            '&numinsufficient=',num2str(numInsufficient),...
            '&isinsufficient=',isInsufficientLogicalStrArray];
            obj.Url=regexprep(url,'snc=(.*?)&','snc=dev&');
        end
    end
end







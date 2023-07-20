




classdef ModelItemHighlighter<handle


    properties





        ENABLE_DEBUG=false;

        sldvDataToHighlight;





        justifiedObjectivesFromFilter;

        sid2HighlightSIDMap;

        modelObjectIndicesToBeHighlighted;

        modelItemSidsToBeHighlighted;




        handlesToBeHighlightedRed;
        handlesToBeHighlightedOrange;
        handlesToBeHighlightedGreen;
        handlesToBeHighlightedGrey;
        handlesToBeHighlightedSteelblue;





        multiLinkChartIds;









        previousHighlightedData;


        previousMultilinkChartInfo;

        stylerArchitectureHandler;
    end

    methods

        function obj=ModelItemHighlighter(sldvData)


            if Sldv.DataUtils.isXilSldvData(sldvData)&&...
                isfield(sldvData.ModelInformation,'HarnessOwnerModel')&&...
                ~isempty(sldvData.ModelInformation.HarnessOwnerModel)&&...
                sldv.code.xil.CodeAnalyzer.isATSHarnessModel(sldvData.ModelInformation.Name)
                sldvData.ModelInformation.Name=sldvData.ModelInformation.HarnessOwnerModel;
            end

            obj.sldvDataToHighlight=sldvData;
            obj.justifiedObjectivesFromFilter=[];

            modelName=sldvData.ModelInformation.Name;

            obj.sid2HighlightSIDMap=containers.Map('KeyType','char',...
            'ValueType','any');

            obj.handlesToBeHighlightedRed=[];
            obj.handlesToBeHighlightedOrange=[];
            obj.handlesToBeHighlightedGreen=[];
            obj.handlesToBeHighlightedGrey=[];
            obj.handlesToBeHighlightedSteelblue=[];

            obj.previousHighlightedData=[];
            obj.previousMultilinkChartInfo=[];
            obj.multiLinkChartIds=obj.find_multi_instance_links(modelName);


            obj.stylerArchitectureHandler=...
            Sldv.HighlightingWorkflows.ModelItemHighlighter_Styler;


            stylerName=['Item_Highlighter_',modelName];
            obj.stylerArchitectureHandler.initStyler(stylerName);
        end



        function updateSldvData(obj,modifiedData)
            obj.sldvDataToHighlight=modifiedData;
        end




        function highlight(obj,justifiedObjectives)


            if nargin<2
                obj.justifiedObjectivesFromFilter=[];
            else
                obj.justifiedObjectivesFromFilter=justifiedObjectives;
            end

            obj.createTableForLeafModelItems();

            newHighlightedData=obj.includeHierarchy();
            obj.clearDiffHighlightedData(newHighlightedData);
            obj.updateDiffHighlightedData(newHighlightedData);
            obj.highlightUsingStyler();

            if~isempty(obj.multiLinkChartIds)
                newMultiLinkChartInfo=obj.includeMultiLinkCharts();
                multiLinkChartInfo=obj.getDiffMultilinkChartInfo(...
                newMultiLinkChartInfo);
                obj.highlightMultiLinkCharts(multiLinkChartInfo);
            end
        end





        function clearHighlighting(obj)
            obj.clearHighlightingOnElements;
            obj.clearHighlightingData;
        end




        function clearHighlightingData(obj)
            if~isempty(obj.stylerArchitectureHandler)
                obj.stylerArchitectureHandler.clearStyler;
                obj.stylerArchitectureHandler=[];
            end
            obj.handlesToBeHighlightedRed=[];
            obj.handlesToBeHighlightedOrange=[];
            obj.handlesToBeHighlightedGreen=[];
            obj.handlesToBeHighlightedSteelblue=[];
            obj.handlesToBeHighlightedGrey=[];
            obj.previousHighlightedData=[];

            remove(obj.sid2HighlightSIDMap,keys(obj.sid2HighlightSIDMap));
            obj.sldvDataToHighlight=[];
            obj.justifiedObjectivesFromFilter=[];
        end






        function clearHighlightingOnElements(obj)
            if~isempty(obj.stylerArchitectureHandler)&&~isempty(obj.previousHighlightedData)



                sldvData=obj.sldvDataToHighlight;
                modelName=sldvData.ModelInformation.Name;
                obj.stylerArchitectureHandler.clearHighlightBackground(modelName);

                greenSelectorName=char(...
                Sldv.HighlightingWorkflows.SLDV_Selectors.ObjectHighlightGreen);
                obj.stylerArchitectureHandler.clearStylingData(...
                obj.previousHighlightedData.handlesToBeHighlightedGreen,greenSelectorName);
                orangeSelectorName=char(...
                Sldv.HighlightingWorkflows.SLDV_Selectors.ObjectHighlightOrange);
                obj.stylerArchitectureHandler.clearStylingData(...
                obj.previousHighlightedData.handlesToBeHighlightedOrange,orangeSelectorName);
                redSelectorName=char(...
                Sldv.HighlightingWorkflows.SLDV_Selectors.ObjectHighlightRed);
                obj.stylerArchitectureHandler.clearStylingData(...
                obj.previousHighlightedData.handlesToBeHighlightedRed,redSelectorName);
                steelblueSelectorName=char(...
                Sldv.HighlightingWorkflows.SLDV_Selectors.ObjectHighlightSteelblue);
                obj.stylerArchitectureHandler.clearStylingData(...
                obj.previousHighlightedData.handlesToBeHighlightedSteelblue,steelblueSelectorName);
                greySelectorName=char(...
                Sldv.HighlightingWorkflows.SLDV_Selectors.ObjectHighlightGrey);
                obj.stylerArchitectureHandler.clearStylingData(...
                obj.previousHighlightedData.handlesToBeHighlightedGrey,greySelectorName);
                if~isempty(obj.previousMultilinkChartInfo)
                    obj.clearMultiLinkChartHighlight(obj.previousMultilinkChartInfo);
                end

            end

            obj.previousHighlightedData=[];
        end


        function debug_setDebugFlag(obj)
            obj.ENABLE_DEBUG=true;
        end
        function debug_clearDebugFlag(obj)
            obj.ENABLE_DEBUG=false;
        end
        function debug_displayTableOfColors(obj,tableOfColors)
            if obj.ENABLE_DEBUG
                disp(['Green : ',tableOfColors.green]);
                disp(['Orange : ',tableOfColors.orange]);
                disp(['Red : ',tableOfColors.red]);
                disp(['Steelblue : ',tableOfColors.steelblue]);
            end
        end

        function debug_displayFinalTableOfColors(obj)
            if obj.ENABLE_DEBUG
                disp(['Green : ',num2str(obj.handlesToBeHighlightedGreen)]);
                disp(['Orange : ',num2str(obj.handlesToBeHighlightedOrange)]);
                disp(['Red : ',num2str(obj.handlesToBeHighlightedRed)]);
                disp(['Steelblue : ',num2str(obj.handlesToBeHighlightedSteelblue)]);
            end
        end

        function tableOfColors=debug_getTableData(obj)
            if obj.ENABLE_DEBUG
                tableOfColors.red=obj.handlesToBeHighlightedRed;
                tableOfColors.orange=obj.handlesToBeHighlightedOrange;
                tableOfColors.green=obj.handlesToBeHighlightedGreen;
                tableOfColors.steelblue=obj.handlesToBeHighlightedSteelblue;
            end
        end

        function highlightedIds=debug_getHighlightedData(obj)
            if obj.ENABLE_DEBUG
                highlightedIds=[obj.handlesToBeHighlightedRed...
                ,obj.handlesToBeHighlightedOrange...
                ,obj.handlesToBeHighlightedGreen...
                ,obj.handlesToBeHighlightedSteelblue...
                ,obj.handlesToBeHighlightedGrey];
            end
        end
    end

    methods(Access=private)





















        function createTableForLeafModelItems(obj)






























            obj.constructTableForModelObjects();

            obj.includeInformationOnModelReferences();

            obj.includeInformationOnObservers();



            obj.modelItemSidsToBeHighlighted.grey=obj.colorReducedBlocks();


            obj.modelItemSidsToBeHighlighted.red=unique(obj.modelItemSidsToBeHighlighted.red);
            obj.modelItemSidsToBeHighlighted.orange=unique(obj.modelItemSidsToBeHighlighted.orange);
            obj.modelItemSidsToBeHighlighted.green=unique(obj.modelItemSidsToBeHighlighted.green);
            obj.modelItemSidsToBeHighlighted.steelblue=unique(obj.modelItemSidsToBeHighlighted.steelblue);



            obj.modelItemSidsToBeHighlighted.orange=...
            setdiff(obj.modelItemSidsToBeHighlighted.orange,...
            obj.modelItemSidsToBeHighlighted.red);
            obj.modelItemSidsToBeHighlighted.green=...
            setdiff(obj.modelItemSidsToBeHighlighted.green,...
            union(obj.modelItemSidsToBeHighlighted.orange,obj.modelItemSidsToBeHighlighted.red));
            obj.modelItemSidsToBeHighlighted.steelblue=...
            setdiff(obj.modelItemSidsToBeHighlighted.steelblue,...
            union(union(obj.modelItemSidsToBeHighlighted.orange,obj.modelItemSidsToBeHighlighted.red),...
            obj.modelItemSidsToBeHighlighted.green));
        end



        function constructTableForModelObjects(obj)

            sldvData=obj.sldvDataToHighlight;
































            obj.modelObjectIndicesToBeHighlighted.green=[];
            obj.modelObjectIndicesToBeHighlighted.red=[];
            obj.modelObjectIndicesToBeHighlighted.orange=[];
            obj.modelObjectIndicesToBeHighlighted.steelblue=[];

            obj.modelItemSidsToBeHighlighted.green={};
            obj.modelItemSidsToBeHighlighted.red={};
            obj.modelItemSidsToBeHighlighted.orange={};
            obj.modelItemSidsToBeHighlighted.steelblue={};

            isDesignError=strcmp(sldvData.AnalysisInformation.AppliedAnalysisStrategy,...
            'DetectErrors');


            for modelObjIndex=1:length(sldvData.ModelObjects)
                modelObject=sldvData.ModelObjects(modelObjIndex);



                if~isempty(modelObject.designSid)



                    ignoreGreen=isDesignError&&strcmp(modelObject.typeDesc,'S-Function');









                    for objectiveIndex=1:length(modelObject.objectives)
                        modelObjective=sldvData.Objectives(...
                        modelObject.objectives(objectiveIndex));
                        if~strcmp(modelObjective.type,'Range')



                            if~isempty(obj.justifiedObjectivesFromFilter)&&...
                                ~isempty(sldvshareprivate('util_get_obj_idx_in_list',...
                                modelObjective,...
                                obj.justifiedObjectivesFromFilter))
                                obj.modelObjectIndicesToBeHighlighted.steelblue(end+1)...
                                =modelObjIndex;
                                obj.modelItemSidsToBeHighlighted.steelblue{end+1}=...
                                obj.GetHighlightSid(modelObject.designSid);

                            elseif~ignoreGreen&&isGreen(modelObjective)
                                obj.modelObjectIndicesToBeHighlighted.green(end+1)...
                                =modelObjIndex;
                                obj.modelItemSidsToBeHighlighted.green{end+1}=...
                                obj.GetHighlightSid(modelObject.designSid);

                            elseif isOrange(modelObjective,sldvData.AnalysisInformation.Options.Mode)
                                obj.modelObjectIndicesToBeHighlighted.orange(end+1)...
                                =modelObjIndex;
                                obj.modelItemSidsToBeHighlighted.orange{end+1}=...
                                obj.GetHighlightSid(modelObject.designSid);

                            elseif isRed(modelObjective,sldvData.AnalysisInformation.Options.Mode)
                                obj.modelObjectIndicesToBeHighlighted.red(end+1)...
                                =modelObjIndex;
                                obj.modelItemSidsToBeHighlighted.red{end+1}=...
                                obj.GetHighlightSid(modelObject.designSid);

                            elseif isSteelBlue(modelObjective)
                                obj.modelObjectIndicesToBeHighlighted.steelblue(end+1)...
                                =modelObjIndex;
                                obj.modelItemSidsToBeHighlighted.steelblue{end+1}=...
                                obj.GetHighlightSid(modelObject.designSid);
                            end
                        end
                    end
                end
            end



            function out=isGreen(modelObjective)
                out=strcmp('green',Sldv.InspectorWorkflow.InspectorUtils.computeColor(modelObjective.status,''));
            end

            function out=isOrange(modelObjective,mode)
                out=strcmp('orange',Sldv.InspectorWorkflow.InspectorUtils.computeColor(modelObjective.status,mode));
            end

            function out=isRed(modelObjective,mode)
                out=strcmp('red',Sldv.InspectorWorkflow.InspectorUtils.computeColor(modelObjective.status,mode));
            end

            function out=isSteelBlue(modelObjective)
                out=strcmp('steelblue',Sldv.InspectorWorkflow.InspectorUtils.computeColor(modelObjective.status,''));
            end
        end


        function includeInformationOnObservers(obj)


            sldvData=obj.sldvDataToHighlight;

            if~sldvprivate('isObserverSupportON',sldvData.AnalysisInformation.Options)
                return;
            end

            topModelH=get_param(sldvData.ModelInformation.Name,'handle');



            obsRefBlks=Simulink.observer.internal.getObserverRefBlocksInBD(topModelH);

            if isempty(obsRefBlks)
                return;
            end

            observerModels=cell(numel(obsRefBlks),1);













            obsMdlNameToObsRefBlkSID=containers.Map('KeyType','char','ValueType','char');
            for idx=1:numel(obsRefBlks)
                currObsName=get_param(obsRefBlks(idx),'ObserverModelName');
                observerModels{idx}=currObsName;

                obsMdlNameToObsRefBlkSID(currObsName)=Simulink.ID.getSID(obsRefBlks(idx));
            end




            obsMdlToMdlObjMap=containers.Map('KeyType','char','ValueType','any');



            for idx=1:numel(observerModels)
                obsMdlToMdlObjMap(observerModels{idx})=[];
            end



            for mdlObjIdx=1:length(sldvData.ModelObjects)

                if~strcmp(sldvData.ModelObjects(mdlObjIdx).sid,sldvData.ModelObjects(mdlObjIdx).designSid)




                    continue;
                end



                mdlName=Simulink.ID.getModel(sldvData.ModelObjects(mdlObjIdx).sid);



                if isKey(obsMdlToMdlObjMap,mdlName)
                    obsMdlToMdlObjMap(mdlName)=[obsMdlToMdlObjMap(mdlName),mdlObjIdx];
                end
            end




            for k=keys(obsMdlToMdlObjMap)

                mdlName=k{1};


                obsBlkSIDInTopModel=obsMdlNameToObsRefBlkSID(mdlName);



                if isempty(obsMdlToMdlObjMap(mdlName))
                    color='';
                else
                    color=obj.computeColor(obsMdlToMdlObjMap(mdlName),{obsBlkSIDInTopModel});
                end

                if~isempty(color)

                    obj.modelItemSidsToBeHighlighted.(color)=obj.insert(...
                    obj.modelItemSidsToBeHighlighted.(color),obsBlkSIDInTopModel);
                end
            end
        end







        function includeInformationOnModelReferences(obj)

            sldvData=obj.sldvDataToHighlight;






            find_mdlrefs(sldvData.ModelInformation.Name,'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices,'KeepModelsLoaded',true);

            for replacementIndex=length(sldvData.AnalysisInformation.ReplacementInfo):-1:1
                repInfo=sldvData.AnalysisInformation.ReplacementInfo(replacementIndex);
                modelBlockReferenceSids={};


                for j=1:length(sldvData.AnalysisInformation.ReplacementInfo)
                    if strcmp(repInfo.sid,...
                        sldvData.AnalysisInformation.ReplacementInfo(j).replacementSid)
                        modelBlockReferenceSids=obj.insert(modelBlockReferenceSids,repInfo.sid);
                    end
                end


                color=obj.computeColor(repInfo.modelObjects,modelBlockReferenceSids);
                if~isempty(color)

                    obj.modelItemSidsToBeHighlighted.(color)=obj.insert(...
                    obj.modelItemSidsToBeHighlighted.(color),repInfo.sid);
                end
            end
        end













        function color=computeColor(obj,modelObjects,modelBlockReferenceSids)
            color='';

            if obj.checkColor(modelObjects,modelBlockReferenceSids,'red')
                color='red';

            elseif obj.checkColor(modelObjects,modelBlockReferenceSids,'orange')
                color='orange';

            elseif obj.checkColor(modelObjects,modelBlockReferenceSids,'green')
                color='green';

            elseif obj.checkColor(modelObjects,modelBlockReferenceSids,'steelblue')
                color='steelblue';
            end
        end



        function check=checkColor(obj,modelObjects,modelBlockReferenceSids,color)
            check=false;
            for index=1:length(modelObjects)
                if any(...
                    obj.modelObjectIndicesToBeHighlighted.(color)==...
                    modelObjects(index))
                    check=true;
                    return;
                end
            end


            for replIndex=1:length(modelBlockReferenceSids)
                for colorIndex=1:length(obj.modelItemSidsToBeHighlighted.(color))
                    if strcmp(modelBlockReferenceSids{replIndex},...
                        obj.modelItemSidsToBeHighlighted.(color){colorIndex})
                        check=true;
                        return;
                    end
                end
            end
        end



        function cell=insert(~,cell,elem)
            if~isempty(elem)
                if isempty(cell)
                    cell={elem};
                else
                    for i=1:length(cell)
                        if strcmp(cell{i},elem)
                            return;
                        end
                    end
                    cell{end+1}=elem;
                end
            end
        end

        function handlesToBeColoredGrey=colorReducedBlocks(obj)
            handlesToBeColoredGrey=[];
            sldvData=obj.sldvDataToHighlight;

            if isfield(sldvData.AnalysisInformation,'ReducedBlocks')
                reduced=sldvData.AnalysisInformation.ReducedBlocks;
                if~isempty(reduced)
                    reducedSids={};
                    for i=1:length(reduced)
                        if isempty(reduced(i).replacementSid)&&...
                            ~isempty(reduced(i).designSid)
                            reducedSids{end+1}=reduced(i).designSid;%#ok<AGROW> 
                        end
                    end
                    reducedBlockHandles=cell2mat(Simulink.ID.getHandle(reducedSids));

                    handlesToBeColoredGrey=reducedBlockHandles;
                end
            end
        end




        function newHighlightedSldvData=includeHierarchy(obj)


            newHighlightedSldvData.handlesToBeHighlightedGrey=...
            obj.modelItemSidsToBeHighlighted.grey;
            newHighlightedSldvData.handlesToBeHighlightedRed=...
            getHierarachyPerColor([],obj.modelItemSidsToBeHighlighted.red);
            newHighlightedSldvData.handlesToBeHighlightedOrange=...
            getHierarachyPerColor(...
            newHighlightedSldvData.handlesToBeHighlightedRed,obj.modelItemSidsToBeHighlighted.orange);
            newHighlightedSldvData.handlesToBeHighlightedGreen=...
            getHierarachyPerColor(...
            [newHighlightedSldvData.handlesToBeHighlightedRed...
            ,newHighlightedSldvData.handlesToBeHighlightedOrange],...
            obj.modelItemSidsToBeHighlighted.green);
            newHighlightedSldvData.handlesToBeHighlightedSteelblue=...
            getHierarachyPerColor(...
            [newHighlightedSldvData.handlesToBeHighlightedRed...
            ,newHighlightedSldvData.handlesToBeHighlightedOrange...
            ,newHighlightedSldvData.handlesToBeHighlightedGreen],...
            obj.modelItemSidsToBeHighlighted.steelblue);

            newHighlightedSldvData.handlesToBeHighlightedOrange=...
            setdiff(newHighlightedSldvData.handlesToBeHighlightedOrange,...
            newHighlightedSldvData.handlesToBeHighlightedRed);
            newHighlightedSldvData.handlesToBeHighlightedGreen=...
            setdiff(newHighlightedSldvData.handlesToBeHighlightedGreen,...
            union(newHighlightedSldvData.handlesToBeHighlightedOrange,...
            newHighlightedSldvData.handlesToBeHighlightedRed));

            newHighlightedSldvData.handlesToBeHighlightedSteelblue=...
            setdiff(newHighlightedSldvData.handlesToBeHighlightedSteelblue,...
            union(union(newHighlightedSldvData.handlesToBeHighlightedOrange,...
            newHighlightedSldvData.handlesToBeHighlightedRed),...
            newHighlightedSldvData.handlesToBeHighlightedGreen));

            function idsToBeHighlighted=getHierarachyPerColor(...
                highlightedSIDs,listOfSIDs)


                [blockHandles,sfIds,chartIds]=cellfun(...
                @resolveStateflowID,listOfSIDs);

                stateflowIdsToBeHighlighted=[];
                simulinkIdsToBeHighlighted=[];%#ok<NASGU>


                sfElementsIndices=find(sfIds>0);
                if~isempty(sfElementsIndices)
                    stateflowIdsToProcess=sfIds(sfElementsIndices);

                    chartIdsToProcess=chartIds(sfElementsIndices);
                    uniquechartIdsToProcess=unique(chartIdsToProcess,'stable');
                    multilinkChartsInModel=intersect(uniquechartIdsToProcess,obj.multiLinkChartIds);
                    for chartId=multilinkChartsInModel

                        stateflowIdsToProcess(chartId==chartIdsToProcess)=[];
                        chartIdsToProcess(chartIdsToProcess==chartId)=[];
                    end
                    stateflowIdsToBeHighlighted=...
                    obj.getStateflowIDsWithHierarchy(highlightedSIDs,...
                    stateflowIdsToProcess);
                end






                blockHandles=unique(blockHandles,'stable');




                blockHandles(blockHandles<0)=[];
                simulinkIdsToBeHighlighted=obj.getSimulinkIDsWithHierarchy(...
                highlightedSIDs,blockHandles);

                idsToBeHighlighted=[stateflowIdsToBeHighlighted...
                ,simulinkIdsToBeHighlighted];
            end

            function[blockH,sfID,chartID]=resolveStateflowID(sid)
                [blockH,sfID,~,~,chartID]=sldvprivate('util_sid',sid,true);
            end
        end









        function multilinkChartInfo=includeMultiLinkCharts(obj)

            multilinkChartInfo=[];
            multilinkChartInfo.red=getMultilinkChartInfoForSingleColor(...
            obj.modelItemSidsToBeHighlighted.red);
            multilinkChartInfo.orange=getMultilinkChartInfoForSingleColor(...
            obj.modelItemSidsToBeHighlighted.orange);
            multilinkChartInfo.green=getMultilinkChartInfoForSingleColor(...
            obj.modelItemSidsToBeHighlighted.green);
            multilinkChartInfo.steelblue=getMultilinkChartInfoForSingleColor(...
            obj.modelItemSidsToBeHighlighted.steelblue);





            function data=getMultilinkChartInfoForSingleColor(listOfSids)
                data.sfIds=[];
                data.blockHandles=[];
                if~isempty(listOfSids)



                    [blockHandles,sfIds,chartIds]=cellfun(...
                    @resolveStateflowID,listOfSids);



                    if~isempty(intersect(chartIds,obj.multiLinkChartIds))
                        data.sfIds=[];
                        data.blockHandles=[];
                        for chartIndex=chartIds
                            if ismember(chartIndex,obj.multiLinkChartIds)
                                data.sfIds=...
                                sfIds(chartIndex==chartIds);
                                data.blockHandles=...
                                blockHandles(chartIndex==chartIds);

                            end
                        end
                    end
                end
            end

            function[blockH,sfID,chartID]=resolveStateflowID(sid)
                [blockH,sfID,~,~,chartID]=sldvprivate('util_sid',sid,true);
            end
        end














        function[blocks,charts]=machine_linked_charts(obj,machineId)%#ok<INUSL>
            blocks=sf('get',machineId,'.sfLinks');
            charts=zeros(size(blocks));

            for idx=1:length(blocks)
                charts(idx)=sf('Private','block2chart',blocks(idx));
            end
        end

























        function chartIds=find_multi_instance_links(obj,modelName)

            chartIds=[];
            machineId=sf('find','all','machine.name',modelName);
            if~isempty(machineId)
                [~,linkCharts]=obj.machine_linked_charts(machineId);

                srtChart=sort(linkCharts);

                isSame=(diff(srtChart)==0);
                blkIdx=find(isSame);

                if~isempty(blkIdx)
                    chartIds=srtChart(blkIdx);
                    chartIds=unique(chartIds);
                end
            end
        end




        function clearDiffHighlightedData(obj,newSldvHighlightData)
            if isempty(obj.previousHighlightedData)
                return;
            end

            if slavteng('feature','IncrementalHighlighting')&&...
                ~isempty(obj.stylerArchitectureHandler)

                handlesToRemoveSteelblueHighlighting=setdiff(...
                obj.previousHighlightedData.handlesToBeHighlightedSteelblue,...
                newSldvHighlightData.handlesToBeHighlightedSteelblue);
                steelblueSelectorName=char(...
                Sldv.HighlightingWorkflows.SLDV_Selectors.ObjectHighlightSteelblue);
                obj.stylerArchitectureHandler.clearStylingData(...
                handlesToRemoveSteelblueHighlighting,steelblueSelectorName);

                handlesToRemoveGreenHighlighting=setdiff(...
                obj.previousHighlightedData.handlesToBeHighlightedGreen,...
                newSldvHighlightData.handlesToBeHighlightedGreen);
                greenSelectorName=char(...
                Sldv.HighlightingWorkflows.SLDV_Selectors.ObjectHighlightGreen);
                obj.stylerArchitectureHandler.clearStylingData(...
                handlesToRemoveGreenHighlighting,greenSelectorName);

                handlesToRemoveOrangeHighlighting=setdiff(...
                obj.previousHighlightedData.handlesToBeHighlightedOrange,...
                newSldvHighlightData.handlesToBeHighlightedOrange);
                orangeSelectorName=char(...
                Sldv.HighlightingWorkflows.SLDV_Selectors.ObjectHighlightOrange);
                obj.stylerArchitectureHandler.clearStylingData(...
                handlesToRemoveOrangeHighlighting,orangeSelectorName);

                handlesToRemoveRedHighlighting=setdiff(...
                obj.previousHighlightedData.handlesToBeHighlightedRed,...
                newSldvHighlightData.handlesToBeHighlightedRed);
                redSelectorName=char(...
                Sldv.HighlightingWorkflows.SLDV_Selectors.ObjectHighlightRed);
                obj.stylerArchitectureHandler.clearStylingData(...
                handlesToRemoveRedHighlighting,redSelectorName);
            end
        end

        function updateDiffHighlightedData(obj,newSldvHighlightData)


            if isempty(obj.previousHighlightedData)

                obj.handlesToBeHighlightedGrey=...
                newSldvHighlightData.handlesToBeHighlightedGrey;
                obj.handlesToBeHighlightedSteelblue=...
                newSldvHighlightData.handlesToBeHighlightedSteelblue;
                obj.handlesToBeHighlightedGreen=...
                newSldvHighlightData.handlesToBeHighlightedGreen;
                obj.handlesToBeHighlightedOrange=...
                newSldvHighlightData.handlesToBeHighlightedOrange;
                obj.handlesToBeHighlightedRed=...
                newSldvHighlightData.handlesToBeHighlightedRed;

                obj.previousHighlightedData=newSldvHighlightData;

                return;
            end

            if slavteng('feature','IncrementalHighlighting')






                obj.handlesToBeHighlightedGrey=setdiff(...
                newSldvHighlightData.handlesToBeHighlightedGrey,...
                obj.previousHighlightedData.handlesToBeHighlightedGrey);

                obj.handlesToBeHighlightedSteelblue=setdiff(...
                newSldvHighlightData.handlesToBeHighlightedSteelblue,...
                obj.previousHighlightedData.handlesToBeHighlightedSteelblue);

                obj.handlesToBeHighlightedGreen=setdiff(...
                newSldvHighlightData.handlesToBeHighlightedGreen,...
                obj.previousHighlightedData.handlesToBeHighlightedGreen);

                obj.handlesToBeHighlightedOrange=setdiff(...
                newSldvHighlightData.handlesToBeHighlightedOrange,...
                obj.previousHighlightedData.handlesToBeHighlightedOrange);

                obj.handlesToBeHighlightedRed=setdiff(...
                newSldvHighlightData.handlesToBeHighlightedRed,...
                obj.previousHighlightedData.handlesToBeHighlightedRed);

                obj.previousHighlightedData=newSldvHighlightData;
            end
        end


        function multilinkChartInfo=getDiffMultilinkChartInfo(obj,newMultilinkChartInfo)


            if isempty(obj.previousMultilinkChartInfo)

                multilinkChartInfo=newMultilinkChartInfo;

                obj.previousMultilinkChartInfo=newMultilinkChartInfo;

                return;
            end


            if slavteng('feature','IncrementalHighlighting')









                indices=~ismember(...
                [newMultilinkChartInfo.steelblue.sfIds],...
                [obj.previousMultilinkChartInfo.steelblue.sfIds]);
                if any(indices)
                    multilinkChartInfo.steelblue.sfIds=...
                    newMultilinkChartInfo.steelblue.sfIds(indices);
                    multilinkChartInfo.steelblue.blockHandles=...
                    newMultilinkChartInfo.steelblue.blockHandles(indices);
                else
                    multilinkChartInfo.steelblue.sfIds=[];
                    multilinkChartInfo.steelblue.blockHandles=[];
                end

                indices=~ismember(...
                [newMultilinkChartInfo.green.sfIds],...
                [obj.previousMultilinkChartInfo.green.sfIds]);
                if any(indices)
                    multilinkChartInfo.green.sfIds=...
                    newMultilinkChartInfo.green.sfIds(indices);
                    multilinkChartInfo.green.blockHandles=...
                    newMultilinkChartInfo.green.blockHandles(indices);
                else
                    multilinkChartInfo.green.sfIds=[];
                    multilinkChartInfo.green.blockHandles=[];
                end

                indices=~ismember(...
                [newMultilinkChartInfo.orange.sfIds],...
                [obj.previousMultilinkChartInfo.orange.sfIds]);
                if any(indices)
                    multilinkChartInfo.orange.sfIds=...
                    newMultilinkChartInfo.orange.sfIds(indices);
                    multilinkChartInfo.orange.blockHandles=...
                    newMultilinkChartInfo.orange.blockHandles(indices);
                else
                    multilinkChartInfo.orange.sfIds=[];
                    multilinkChartInfo.orange.blockHandles=[];
                end

                indices=~ismember(...
                [newMultilinkChartInfo.red.sfIds],...
                [obj.previousMultilinkChartInfo.red.sfIds]);
                if any(indices)
                    multilinkChartInfo.red.sfIds=...
                    newMultilinkChartInfo.red.sfIds(indices);
                    multilinkChartInfo.red.blockHandles=...
                    newMultilinkChartInfo.red.blockHandles(indices);
                else
                    multilinkChartInfo.red.sfIds=[];
                    multilinkChartInfo.red.blockHandles=[];
                end

                obj.previousMultilinkChartInfo=newMultilinkChartInfo;
            end
        end

        function highlightUsingStyler(obj)

            sldvData=obj.sldvDataToHighlight;
            modelName=sldvData.ModelInformation.Name;
            obj.stylerArchitectureHandler.highlightBackground(modelName);

            greySelectorName=char(...
            Sldv.HighlightingWorkflows.SLDV_Selectors.ObjectHighlightGrey);
            obj.stylerArchitectureHandler.highlightIDs(...
            obj.handlesToBeHighlightedGrey,greySelectorName);


            steelblueSelectorName=char(...
            Sldv.HighlightingWorkflows.SLDV_Selectors.ObjectHighlightSteelblue);
            obj.stylerArchitectureHandler.highlightIDs(...
            obj.handlesToBeHighlightedSteelblue,steelblueSelectorName);

            greenSelectorName=char(...
            Sldv.HighlightingWorkflows.SLDV_Selectors.ObjectHighlightGreen);
            obj.stylerArchitectureHandler.highlightIDs(...
            obj.handlesToBeHighlightedGreen,greenSelectorName);

            orangeSelectorName=char(...
            Sldv.HighlightingWorkflows.SLDV_Selectors.ObjectHighlightOrange);
            obj.stylerArchitectureHandler.highlightIDs(...
            obj.handlesToBeHighlightedOrange,orangeSelectorName);

            redSelectorName=char(...
            Sldv.HighlightingWorkflows.SLDV_Selectors.ObjectHighlightRed);
            obj.stylerArchitectureHandler.highlightIDs(...
            obj.handlesToBeHighlightedRed,redSelectorName);

        end

        function highlightMultiLinkCharts(obj,multilinkChartInfo)
            if~isempty(multilinkChartInfo.steelblue.sfIds)
                steelblueSelectorName=char(...
                Sldv.HighlightingWorkflows.SLDV_Selectors.ObjectHighlightSteelblue);
                obj.stylerArchitectureHandler.highlightMultilinkCharts(...
                multilinkChartInfo.steelblue.blockHandles,...
                multilinkChartInfo.steelblue.sfIds,steelblueSelectorName);
            end

            if~isempty(multilinkChartInfo.green.sfIds)
                greenSelectorName=char(...
                Sldv.HighlightingWorkflows.SLDV_Selectors.ObjectHighlightGreen);
                obj.stylerArchitectureHandler.highlightMultilinkCharts(...
                multilinkChartInfo.green.blockHandles,...
                multilinkChartInfo.green.sfIds,greenSelectorName);
            end

            if~isempty(multilinkChartInfo.orange.sfIds)
                orangeSelectorName=char(...
                Sldv.HighlightingWorkflows.SLDV_Selectors.ObjectHighlightOrange);
                obj.stylerArchitectureHandler.highlightMultilinkCharts(...
                multilinkChartInfo.orange.blockHandles,...
                multilinkChartInfo.orange.sfIds,orangeSelectorName);
            end

            if~isempty(multilinkChartInfo.red.sfIds)
                redSelectorName=char(...
                Sldv.HighlightingWorkflows.SLDV_Selectors.ObjectHighlightRed);
                obj.stylerArchitectureHandler.highlightMultilinkCharts(...
                multilinkChartInfo.red.blockHandles,...
                multilinkChartInfo.red.sfIds,redSelectorName);
            end
        end

        function clearMultiLinkChartHighlight(obj,multilinkChartInfo)
            if~isempty(multilinkChartInfo.steelblue.sfIds)
                steelblueSelectorName=char(...
                Sldv.HighlightingWorkflows.SLDV_Selectors.ObjectHighlightSteelblue);
                obj.stylerArchitectureHandler.clearMultilinkChartHighlighting(...
                multilinkChartInfo.steelblue.blockHandles,...
                multilinkChartInfo.steelblue.sfIds,steelblueSelectorName);
            end

            if~isempty(multilinkChartInfo.green.sfIds)
                greenSelectorName=char(...
                Sldv.HighlightingWorkflows.SLDV_Selectors.ObjectHighlightGreen);
                obj.stylerArchitectureHandler.clearMultilinkChartHighlighting(...
                multilinkChartInfo.green.blockHandles,...
                multilinkChartInfo.green.sfIds,greenSelectorName);
            end

            if~isempty(multilinkChartInfo.orange.sfIds)
                orangeSelectorName=char(...
                Sldv.HighlightingWorkflows.SLDV_Selectors.ObjectHighlightOrange);
                obj.stylerArchitectureHandler.clearMultilinkChartHighlighting(...
                multilinkChartInfo.orange.blockHandles,...
                multilinkChartInfo.orange.sfIds,orangeSelectorName);
            end

            if~isempty(multilinkChartInfo.red.sfIds)
                redSelectorName=char(...
                Sldv.HighlightingWorkflows.SLDV_Selectors.ObjectHighlightRed);
                obj.stylerArchitectureHandler.clearMultilinkChartHighlighting(...
                multilinkChartInfo.red.blockHandles,...
                multilinkChartInfo.red.sfIds,redSelectorName);
            end
        end
    end

    methods(Access=private)
        highlightSid=GetHighlightSid(obj,sid);
        stateflowIds=getStateflowIDsWithHierarchy(obj,listOfIdsToBeHighlighted,sfIDs);
        simulinkIds=getSimulinkIDsWithHierarchy(obj,listOfIdsToBeHighlighted,blockHandles)
    end
end


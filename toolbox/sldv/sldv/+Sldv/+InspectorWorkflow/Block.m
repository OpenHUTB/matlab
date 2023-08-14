classdef Block<handle








    properties(Access=private)
        name;
        mSummary;

        mObjectives;
        mRanges;
mDeadLogic
        blockSID;
        blockPath;
        modelName;
        mIsQuickDeadLogicAndPostAnalysisAndHasDeadLogic;

        mOptions;

mSldvData
    end

    methods
        function obj=Block()




            obj.mSummary=[];
            obj.mObjectives=[];
            obj.mRanges=[];
            obj.mIsQuickDeadLogicAndPostAnalysisAndHasDeadLogic=false;
        end
        function blockToDataMap=updateDataForBlock(...
            obj,blockName,blockSID,blockPath,...
            mode,modelName,...
            blockObjectives,blockRanges,isQuickDeadLogicAndPostAnalysisAndHasDeadLogic,...
            blockDeadLogic,sldvData,blockDescr,justifiedObjectives)

            obj.name=blockName;
            obj.blockSID=blockSID;
            obj.blockPath=blockPath;
            obj.modelName=modelName;
            obj.mOptions=sldvData.AnalysisInformation.Options;
            obj.mSldvData=sldvData;
            obj.mIsQuickDeadLogicAndPostAnalysisAndHasDeadLogic=isQuickDeadLogicAndPostAnalysisAndHasDeadLogic;
            obj.updateObjectives(blockObjectives,mode,modelName,blockDeadLogic,sldvData,justifiedObjectives)

            blockToDataMap=obj.updateRanges(blockRanges,blockDescr);
        end

        function updateSummary(obj,objectives)
            obj.mSummary.objectives=[];
            obj.mSummary.pathObjectives=[];
            if nargin==1
                objectives=obj.mObjectives;
            end
            if~isempty(objectives)
                obj.mSummary.objectives=...
                Sldv.InspectorWorkflow.InspectorUtils.getBlockSummary(objectives);
            end

        end
        function str=getName(obj)
            str=obj.name;
        end

        function str=getPath(obj)
            str=obj.blockPath;
        end

        function str=getSID(obj)
            str=obj.blockSID;
        end

        function str=getModelName(obj)
            str=obj.modelName;
        end

        function setSID(obj,sid)
            obj.blockSID=sid;
        end

        function setName(obj,name)
            obj.name=name;
        end

        function str=printToHTML(obj)
            objectiveDataStr=obj.getObjectivesPrintString;
            rangeString=obj.getRangeString;
            str=[objectiveDataStr,rangeString];
        end
    end

    methods(Access=private)
        function updateObjectives(obj,blockObjectives,mode,modelName,blockDeadLogic,sldvData,justifiedObjectives)
            utils=Sldv.InspectorWorkflow.InspectorUtils;
            isXIL=Sldv.DataUtils.isXilSldvData(sldvData);
            if obj.mIsQuickDeadLogicAndPostAnalysisAndHasDeadLogic
                obj.mDeadLogic=blockDeadLogic;

                if~isXIL&&~isempty(obj.mDeadLogic)
                    obj.mDeadLogic=Sldv.utils.updateDeadLogicDescriptionBasedOnFilter(blockDeadLogic,...
                    sldvData,...
                    justifiedObjectives,...
                    true,...
                    modelName);
                end
            end

            if~obj.mIsQuickDeadLogicAndPostAnalysisAndHasDeadLogic||(slfeature('SLDVCombinedDLRTE')&&Sldv.utils.isRunTimeErrors(obj.mOptions))
                if~isempty(blockObjectives)
                    is_path_based=Sldv.utils.isPathBasedTestGeneration(obj.mOptions);
                    for objective=blockObjectives
                        if strcmp(objective.type,'Non masking')
                            continue;
                        else
                            pathObjectives=[];
                            if is_path_based&&...
                                isfield(objective,'pathObjectives')&&...
                                ~isempty(objective.pathObjectives)
                                pathObjectiveIndices=objective.pathObjectives;
                                pathObjectives=sldvData.PathObjectives(pathObjectiveIndices);
                            end

                            isJustified=~(isempty(justifiedObjectives)||...
                            isempty(sldvshareprivate('util_get_obj_idx_in_list',...
                            objective,justifiedObjectives)));
                            newObjective=utils.createObjectiveOnType(...
                            objective,mode,modelName,pathObjectives,...
                            isJustified,isXIL,obj.getSID);
                            obj.mObjectives=[obj.mObjectives,newObjective];
                        end
                    end





                    if~is_path_based
                        obj.mObjectives(strcmp('Extension',{obj.mObjectives.type}))=[];
                    end
                end
            end
        end

        function blockToDataMap=updateRanges(obj,blockRanges,blockDescr)

            blockToDataMap=containers.Map...
            ('KeyType','char','ValueType','any');

            blockToDataMap(obj.blockSID)=obj;

            if~isempty(blockRanges)
                for rangeObjective=blockRanges
                    if~isempty(rangeObjective.range)
                        newObjective=Sldv.InspectorWorkflow.RangeObjective;
                        newBlockToDataMap=...
                        newObjective.populateObjective(rangeObjective,...
                        obj.blockSID,blockDescr);
                        utils=Sldv.InspectorWorkflow.InspectorUtils;
                        blockToDataMap=utils.concatenateBlockDataMap(...
                        blockToDataMap,newBlockToDataMap);
                        obj.mRanges=[obj.mRanges,newObjective];
                    end
                end
            end
        end

        function htmlString=getSummaryPrintString(obj)
            utils=Sldv.InspectorWorkflow.InspectorUtils;
            htmlString='';
            if~isempty(obj.mSummary)

                tableBegin='<table>';
                tableEnd='</table>';
                if~isempty(obj.mSummary.objectives)
                    objSummary=[tableBegin...
                    ,utils.getHTMLBlockSummary(obj.mSummary.objectives)...
                    ,tableEnd];
                else
                    objSummary='';
                end

                htmlString=utils.addData(objSummary);
            end
        end

        function deadLogicStr=getDeadLogicStr(obj)

            if strcmp(obj.mOptions.Mode,'DesignErrorDetection')||...
                slavteng('feature','ChangeUnsatisfiableToDeadLogic')
                deadLogicStr='Dead Logic';
            else
                deadLogicStr='Unsatisfiable';
            end
        end

        function hasDl=hasDeadLogic(obj)



            hasDl=false;
            if Sldv.utils.isQuickDeadLogic(obj.mOptions)
                hasDl=~isempty(obj.mDeadLogic);
            else
                for i=1:numel(obj.mObjectives)
                    currStatus=obj.mObjectives(i).status;
                    deadLogicStr=getDeadLogicStr(obj);
                    if strcmp(currStatus,deadLogicStr)
                        hasDl=true;
                        break;
                    end
                end
            end
        end

        function objectives=filterOutNonConditionObjectives(obj)
            if Sldv.utils.isQuickDeadLogic(obj.mOptions)

                modelObjs=obj.mSldvData.ModelObjects;
                thisModelObj=modelObjs(strcmp({modelObjs.designSid},obj.blockSID));
                objectives=obj.mSldvData.Objectives(thisModelObj.objectives);
            else
                objectives=obj.mObjectives;
            end

            conditionStr='Condition';
            conditionIdxs=strcmp({objectives.type},conditionStr);
            objectives=objectives(conditionIdxs);
        end

        function numDead=numDeadConditionObjectives(obj)

            conditionObjectives=filterOutNonConditionObjectives(obj);
            if isempty(conditionObjectives)
                numDead=0;
                return;
            end

            numDead=sum(strcmp({conditionObjectives.status},getDeadLogicStr(obj)));
        end

        function allDead=isLogicBlockUnreachable(obj,aNumInports)


            allDead=false;
            if~slfeature('SldvMcdcInDeadLogic')&&Sldv.utils.isQuickDeadLogic(obj.mOptions)
                unreachableStr=getString(message('Sldv:goal_label:Unreachable'));
                if numel(obj.mDeadLogic)==aNumInports&&all(strcmp({obj.mDeadLogic.label},unreachableStr))
                    allDead=true;
                end
            else
                if numDeadConditionObjectives(obj)==(2*aNumInports)
                    allDead=true;
                end
            end
        end

        function numObjs=numCondObjectives(obj)
            if~slfeature('SldvMcdcInDeadLogic')&&Sldv.utils.isQuickDeadLogic(obj.mOptions)


                modelObjs=obj.mSldvData.ModelObjects;
                blockModelObj=modelObjs(strcmp({obj.mSldvData.ModelObjects.designSid},obj.blockSID));
                numObjs=numel(blockModelObj.objectives)-1;
            else
                numObjs=numel(filterOutNonConditionObjectives(obj));
            end
        end

        function result=hasVectorInputs(obj,aBlockName)
            if strcmp(get_param(aBlockName,'Operator'),'NOT')
                numInputs=1;
            else




                numInputs=str2double(get_param(aBlockName,'Inputs'));
            end

            result=false;

            numObjectives=numCondObjectives(obj);
            if numObjectives>2*numInputs
                result=true;
            end
        end

        function shouldShowShortCircuiting=shouldShowShortCircuitingSuggestion(obj,aBlockName)






            if~strcmp('Logic',get_param(aBlockName,'BlockType'))

                shouldShowShortCircuiting=false;
                return;
            end

            operator=get_param(aBlockName,'Operator');
            shouldShowShortCircuiting=~any(strcmp(operator,{'NOT','XOR','NXOR'}));

            if hasVectorInputs(obj,aBlockName)
                return;
            end

            numInports=str2double(get_param(aBlockName,'Inputs'));
            allDead=isLogicBlockUnreachable(obj,numInports);
            shouldShowShortCircuiting=shouldShowShortCircuiting&&~allDead;
        end

        function shortCircuitingString=chooseShortCircuitingString(obj,aBlockName)


            areConfident=false;
            startPort=-1;
            numInports=str2double(get_param(aBlockName,'Inputs'));



            if hasVectorInputs(obj,aBlockName)



            elseif Sldv.utils.isQuickDeadLogic(obj.mOptions)






                unreachableStr=getString(message('Sldv:goal_label:Unreachable'));
                for i=1:numel(obj.mDeadLogic)
                    if strcmp(obj.mDeadLogic(i).label,unreachableStr)
                        startPort=obj.mDeadLogic(i).coverageIdx;
                        areConfident=true;
                        break;
                    end
                end
            else









                objectives=filterOutNonConditionObjectives(obj);
                deadLogicStr=getDeadLogicStr(obj);


                for i=1:(numInports-1)
                    offset=2*(i-1)+1;
                    if(strcmp(deadLogicStr,objectives(offset).status)||strcmp(deadLogicStr,objectives(offset+1).status))&&...
                        all(strcmp(deadLogicStr,{objectives((offset+2):end).status}))
                        startPort=i+1;
                        areConfident=true;
                        break;
                    end
                end
            end

            if areConfident
                if startPort==numInports
                    shortCircuitingString=getString(message('Sldv:DeadLogicExplanations:DeadLogicInsideShortCircuitingBlockConfidentOnePort',startPort));
                else
                    shortCircuitingString=getString(message('Sldv:DeadLogicExplanations:DeadLogicInsideShortCircuitingBlockConfidentMultiplePorts',startPort,numInports));
                end
            else
                shortCircuitingString=getString(message('Sldv:DeadLogicExplanations:DeadLogicInsideShortCircuitingBlock'));
            end
        end

        function isCondExec=isConditionallyExecuted(obj,aBlockName)
            isCondExec=false;

            if~isfield(obj.mSldvData.AnalysisInformation,'conditionallyExecutedBlocks')||...
                isempty(obj.mSldvData.AnalysisInformation.conditionallyExecutedBlocks)


                return;
            end

            if any(strcmp(Simulink.ID.getSID(aBlockName),{obj.mSldvData.AnalysisInformation.conditionallyExecutedBlocks.designSid}))
                isCondExec=true;
            end
        end

        function deadLogicExplanationStr=addDeadLogicExplanations(obj)
            deadLogicExplanationStr='';

            utils=Sldv.InspectorWorkflow.InspectorUtils;

            try
                blockName=getfullname(obj.blockSID);
            catch
                try

                    sfObjHandle=Simulink.ID.getHandle(obj.blockSID);
                    blockName=sfObjHandle.Chart.Path;
                catch

                    return;
                end
            end

            if strcmp('block_diagram',get_param(blockName,'Type'))





                return;
            end



            if shouldShowShortCircuitingSuggestion(obj,blockName)
                shortCircuitString=chooseShortCircuitingString(obj,blockName);
                shortCircuitString=[shortCircuitString,utils.deadLogicSuggestionLink('deadLogicSuggestionShortCircuit')];
                shortCircuitString=utils.addData(shortCircuitString);
                deadLogicExplanationStr=shortCircuitString;
            end




            if isConditionallyExecuted(obj,blockName)
                condExecString=getString(message('Sldv:DeadLogicExplanations:DeadLogicInsideConditionalInputBranchExecution'));
                condExecString=[condExecString,utils.deadLogicSuggestionLink('deadLogicSuggestionConditionallyExecuteInputs')];
                condExecString=utils.addData(condExecString);
                deadLogicExplanationStr=[deadLogicExplanationStr,condExecString];
            end

            if~isempty(deadLogicExplanationStr)
                suggestionsHeader=getString(message('Sldv:DeadLogicExplanations:SuggestionsSection'));
                suggestionsHeader=utils.bold(suggestionsHeader);
                deadLogicExplanationStr=[utils.addData(suggestionsHeader),deadLogicExplanationStr];
            end
        end

        function htmlString=getObjectivesPrintString(obj)
            htmlString='';

            if obj.mIsQuickDeadLogicAndPostAnalysisAndHasDeadLogic
                quickDeadLogicString=obj.getQuickDeadLogicHTMLString;
                rteString='';



                if~isempty(obj.mObjectives)
                    [~,rteString,~]=getObjectivesPrintStringHelper(obj);
                end

                if isempty(obj.mDeadLogic)


                    htmlString=[quickDeadLogicString,rteString];
                else


                    htmlString=[rteString,quickDeadLogicString];
                    htmlString=[addDeadLogicExplanations(obj),htmlString];
                end
            elseif~isempty(obj.mObjectives)&&Sldv.utils.isQuickDeadLogic(obj.mOptions)



                [structuralCoverageString,rteString,~]=getObjectivesPrintStringHelper(obj);
                if isempty(structuralCoverageString)
                    utils=Sldv.InspectorWorkflow.InspectorUtils;
                    objString=getString(message('Sldv:Informer:NoDeadLogicFound'));
                    htmlString=utils.addData(objString);


                    htmlString=[htmlString,rteString];
                else


                    htmlString=[rteString,structuralCoverageString];
                end
            elseif~isempty(obj.mObjectives)
                [structuralCoverageString,otherTypesString,useNoDeadLogicStrForActiveLogic]=getObjectivesPrintStringHelper(obj);
                if strcmp(obj.mOptions.Mode,'DesignErrorDetection')&&~useNoDeadLogicStrForActiveLogic



                    htmlString=[otherTypesString,structuralCoverageString];
                else
                    htmlString=[structuralCoverageString,otherTypesString];
                end

                if hasDeadLogic(obj)&&~Sldv.utils.isSldvAnalysisRunning(obj.modelName)
                    htmlString=[addDeadLogicExplanations(obj),htmlString];
                end
            end
        end



        function[structuralCoverageString,otherTypesString,useNoDeadLogicStrForActiveLogic]=getObjectivesPrintStringHelper(obj)
            structuralCoverageString='';
            otherTypesString='';
            useNoDeadLogicStrForActiveLogic=false;



            objectives=obj.mObjectives(strcmp('Structural',{obj.mObjectives.displayTab}));
            if~isempty(objectives)
                allTypes={objectives.type};
                uniqueTypes=unique(allTypes);




                structCovTypes=intersect(Sldv.utils.getStructuralCoverageObjectiveTypes(),uniqueTypes,'stable');
                otherTypes=setdiff(uniqueTypes,structCovTypes);

                if~slavteng('feature','ShowActiveLogicInInformer')&&Sldv.utils.isActiveLogic(obj.mOptions)&&...
                    obj.allStructuralCoverageObjectivesAreActiveLogic(structCovTypes)
                    structuralCoverageString=getString(message('Sldv:Informer:NoDeadLogic'));
                    useNoDeadLogicStrForActiveLogic=true;
                else
                    for index=1:length(structCovTypes)
                        structuralCoverageString=[structuralCoverageString,obj.getObjectiveHTMLStringWithType(structCovTypes{index})];%#ok<AGROW>
                    end
                end

                for index=1:length(otherTypes)
                    otherTypesString=[otherTypesString,obj.getObjectiveHTMLStringWithType(otherTypes{index})];%#ok<AGROW>
                end
            end
        end

        function htmlString=getExtObjectivesPrintString(obj)
            htmlString=obj.getObjectiveHTMLStringWithTabType(...
            'Extension');
        end
        function htmlString=getCustomObjectivesPrintString(obj)
            htmlString=obj.getObjectiveHTMLStringWithTabType(...
            'Custom');
        end

        function htmlString=getRangeString(obj)
            htmlString='';
            if~isempty(obj.mRanges)
                headerLabel=getString(message('Sldv:Informer:DerivedRanges'));
                utils=Sldv.InspectorWorkflow.InspectorUtils;
                headerData=['<b>',headerLabel,'</b>'];
                htmlObjString=obj.getPrintString(obj.mRanges);
                htmlString=[utils.addData(headerData),utils.addData(htmlObjString)];
            end
        end


        function htmlString=getObjectiveHTMLStringWithTabType(obj,tabString)
            htmlString='';
            objectives=obj.mObjectives(...
            strcmp(tabString,{obj.mObjectives.displayTab}));
            if~isempty(objectives)
                utils=Sldv.InspectorWorkflow.InspectorUtils;
                htmlObjString=obj.getPrintString(objectives);
                htmlString=utils.addTableWithData(htmlObjString);
            end
        end

        function structCovObjectives=getStructuralCoverageObjectives(obj,structCovTypes)
            structCovIndices=false(length(obj.mObjectives),1);
            for i=1:length(obj.mObjectives)
                if any(strcmp(obj.mObjectives(i).type,structCovTypes))
                    structCovIndices(i)=true;
                end
            end
            structCovObjectives=obj.mObjectives(structCovIndices);
        end

        function result=allStructuralCoverageObjectivesAreActiveLogic(obj,structCovTypes)
            structCovObjectives=obj.getStructuralCoverageObjectives(structCovTypes);
            numStructCovObjectives=length(structCovObjectives);
            nonActiveLogicStructCovObjectives=structCovObjectives(~strcmp('Active Logic',{structCovObjectives.status}));
            result=isempty(nonActiveLogicStructCovObjectives)&&numStructCovObjectives>0;
        end

        function htmlString=getObjectiveHTMLStringWithType(obj,aType)
            htmlString='';
            allObjectives=obj.mObjectives(...
            strcmp(aType,{obj.mObjectives.type}));
            objectives=obj.modifyObjectives(allObjectives);
            if~isempty(objectives)
                utils=Sldv.InspectorWorkflow.InspectorUtils;
                headerLabel=[...
                sldvprivate('util_translate_ObjectiveType',aType)...
                ,' ',getString(message('Sldv:Informer:Objectives'))];
                headerData=['<b>',headerLabel,'</b>'];
                header=utils.addData(headerData);
                htmlObjString=obj.getPrintString(objectives);
                htmlString=[header,utils.addTableWithData(htmlObjString)];
            end
        end

        function htmlString=getQuickDeadLogicHTMLString(obj)
            deadLogic=obj.mDeadLogic;
            utils=Sldv.InspectorWorkflow.InspectorUtils;

            if~isempty(deadLogic)
                headerData=['<b>',getString(message('Sldv:KeyWords:DEADLOGIC')),':</b>'];
                header=utils.addData(headerData);

                tblStr='';
                for idx=1:numel(deadLogic)
                    dlItem=deadLogic(idx);
                    if contains(dlItem.label,{getString(message('Sldv:KeyWords:Excluded')),...
                        getString(message('Sldv:KeyWords:Justified'))})
                        color='steelblue';
                    else
                        color='red';
                    end

                    data=[utils.addCellWithData(utils.safeHTML(dlItem.descr))...
                    ,utils.addCellWithData(['<b><font color="',color,'">',utils.safeHTML(dlItem.label),'</font></b>'])];

                    if isfield(dlItem,'action')
                        for i=1:numel(dlItem.action)
                            data=[data,utils.addCellWithData(dlItem.action{i})];
                        end
                    end
                    thisRow=utils.addRowWithData(data);
                    tblStr=[tblStr,thisRow];%#ok<AGROW>
                end

                htmlString=[header,utils.addTableWithData(tblStr)];
            else
                objString=getString(message('Sldv:Informer:NoDeadLogicFound'));
                htmlString=utils.addData(objString);
            end
        end

        function htmlString=getPrintString(~,objectivesSet)
            htmlString='';
            for objIndex=1:length(objectivesSet)
                objective=objectivesSet(objIndex);

                htmlString=[htmlString,objective.printDataToHTML];%#ok<AGROW>
            end
        end




        function updatedObjectives=modifyObjectives(obj,allObjectives)
            updatedObjectives=[];
            utils=Sldv.InspectorWorkflow.InspectorUtils;
            for objective=allObjectives
                if strcmp(objective.status,'n/a')&&...
                    utils.istestgenobj(objective.type)&&...
                    Sldv.utils.isQuickDeadLogic(obj.mOptions)
                    continue;
                elseif~slavteng('feature','ShowActiveLogicInInformer')&&...
                    strcmp(objective.status,'Active Logic')&&...
                    Sldv.utils.isActiveLogic(obj.mOptions)

                    continue;
                else
                    if isempty(updatedObjectives)
                        updatedObjectives=objective;
                    else
                        updatedObjectives(end+1)=objective;%#ok<AGROW>
                    end
                end
            end
        end
    end

    methods
        function objectives=getObjectives(obj)
            objectives=obj.mObjectives;
        end
        function setObjectives(obj,objectives)
            obj.mObjectives=objectives;
        end
        function rangeObjectives=getRanges(obj)
            rangeObjectives=obj.mRanges;
        end
        function setRanges(obj,rangeObjectives)
            obj.mRanges=rangeObjectives;
        end
        function updateRangeObjectives(obj,rangeObjectives)
            obj.mRanges=[obj.mRanges,rangeObjectives];
        end
    end
end




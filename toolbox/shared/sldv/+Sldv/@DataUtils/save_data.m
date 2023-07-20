















function[sldvData,objectiveToGoalMap,...
    goalIdToObjectiveIdMap,...
    tcIdxToSimoutMap,mGoalToLinkinfoMap,goalIdToDvIdMap]=save_data(model,testcomp,...
    mGoalToLinkinfoMap)




    if ischar(model)
        try
            modelH=get_param(model,'Handle');
        catch myException %#ok<NASGU>
            modelH=[];
        end
    else
        modelH=model;
    end

    if isempty(testcomp)
        error(message('Sldv:DataUtils:NoTestComp'));
    end

    if nargin<3||isempty(mGoalToLinkinfoMap)
        mGoalToLinkinfoMap=containers.Map('KeyType','double','ValueType','any');
    end

    goalIdToObjectiveIdMap=containers.Map('KeyType','double','ValueType','double');



    ModelInformation=Sldv.DataUtils.getModelInformation(modelH,'datagen',testcomp);

    AnalysisInformation=Sldv.DataUtils.getAnalysisInformation(testcomp,modelH);

    linkStorage=containers.Map('KeyType','double','ValueType','any');
    rangeData=testcomp.getRanges();
    totalGoalCount=testcomp.getTotalGoalCount();

    if totalGoalCount>0
        if slavteng('feature','UDD2MCOS')

            allGoals=[];
        else
            allGoals(totalGoalCount)=SlAvt.Goal;
        end
    else
        allGoals=[];
    end

    allBlks=sldvprivate('sldv_datamodel_get_modelobjects',testcomp);



    tcActiveSettings=testcomp.activeSettings;


    isPathBased=Sldv.utils.isPathBasedTestGeneration(tcActiveSettings);

    hasDeadLogic=strcmp(tcActiveSettings.Mode,'DesignErrorDetection')&&...
    strcmp(tcActiveSettings.DetectDeadLogic,'on');
    hasQuickDeadLogic=hasDeadLogic&&strcmp(tcActiveSettings.DetectActiveLogic,'off');


    observerModels={};
    if(slfeature('ObserverSLDV')==1)
        observerRefBlocks=Simulink.observer.internal.getObserverRefBlocksInBD(modelH);
        observerModels=arrayfun(@(refBlk)get_param(refBlk,'ObserverModelName'),...
        observerRefBlocks,'UniformOutput',false);
    end






    if slavteng('feature','UDD2MCOS')
        for blk=allBlks(:)'
            BlkGoals=processInternalGoals(blk);
            allGoals=[allGoals,BlkGoals];%#ok<AGROW>
        end
    else
        startCount=1;
        for blk=allBlks(:)'
            BlkGoals=processInternalGoals(blk);
            blkGoalCount=size(BlkGoals,2);
            if blkGoalCount>0
                endCount=(startCount+blkGoalCount)-1;
                allGoals(startCount:endCount)=BlkGoals;
                startCount=endCount+1;
            end
        end

        if totalGoalCount>=startCount
            allGoals(startCount:totalGoalCount)=[];
        end
    end

    obsInfo=[];

    if isPathBased
        obsInfo.extObjToGoalMap=containers.Map('KeyType','double','ValueType','any');
        obsInfo.goalIdToExtObjIdMap=containers.Map('KeyType','double','ValueType','double');
        obsInfo.goalIdToPathObjIdMap=containers.Map('KeyType','double','ValueType','any');

        obsInfo.PathObjectives=[];
        obsInfo.extObjectives=[];
    end

    objectiveToGoalMap=containers.Map('KeyType','double','ValueType','any');
    ObjFact=Sldv.ReportObjectiveFactory(tcActiveSettings);
    Objectives=[];
    ObjectiveIndex=1;
    GoalCnt=numel(allGoals);

    if GoalCnt>0

        emptyObjective=ObjFact.createEmptyObjective();


        Objectives=emptyObjective;
        Objectives(1:GoalCnt)=emptyObjective;

        for currentGoal=allGoals(:)'



            if~mGoalToLinkinfoMap.isKey(currentGoal.getGoalMapId)

                [info,storeInData]=storeLink(currentGoal);%#ok<ASGLU>
                mGoalToLinkinfoMap(currentGoal.getGoalMapId)=storeInData;
            else
                storeInData=mGoalToLinkinfoMap(currentGoal.getGoalMapId);
            end


            if strcmp(currentGoal.type,'AVT_GOAL_PATH_OBJECTIVE')

                obsInfo.PathObjectives=addPathObjective(currentGoal,obsInfo,...
                goalIdToObjectiveIdMap,storeInData,...
                rangeData,ObjFact);
            elseif strcmp(currentGoal.type,'AVT_GOAL_CUSBLKCOV')
                obsInfo.extObjectives=addExtObjective(currentGoal,obsInfo.extObjectives,...
                obsInfo.goalIdToExtObjIdMap,storeInData,...
                rangeData,ObjFact,...
                obsInfo.extObjToGoalMap,modelH);
            else
                addObjective(storeInData);
            end
        end

        if ObjectiveIndex<=numel(Objectives)
            Objectives(ObjectiveIndex:end)=[];
        end
    end




    function addObjective(linkInfo)
        if~goalIdToObjectiveIdMap.isKey(currentGoal.getGoalMapId)
            newObjective=ObjFact.createObjective(currentGoal,linkInfo,rangeData,modelH);
            Objectives(ObjectiveIndex)=newObjective;
            goalIdToObjectiveIdMap(currentGoal.getGoalMapId)=ObjectiveIndex;
            objectiveToGoalMap(ObjectiveIndex)=currentGoal;
            ObjectiveIndex=ObjectiveIndex+1;
        end
    end

    testcomp.analysisInfo.linkStorage=linkStorage;


    Constraints=[];
    ModelObjectsMap=containers.Map('KeyType','char','ValueType','double');
    ModelObjectIndex=0;


    emptyModelObj=createEmptyModelObj(isPathBased,observerModels);


    ModelObjects=emptyModelObj;
    numBlks=length(allBlks);
    ModelObjects(1:numBlks)=emptyModelObj;

    analysisInfo=testcomp.analysisInfo;
    if isfield(analysisInfo,'analysisTime')
        analysisTimeMap=analysisInfo.analysisTime;
    else
        analysisTimeMap=containers.Map('KeyType','uint64',...
        'ValueType','any');
    end

    for blk=allBlks(:)'
        addModelObject(blk,analysisTimeMap);
    end


    ModelObjects(ModelObjectIndex+1:numBlks)=[];


    if isPathBased
        [obsInfo.PathObjectives,...
        ModelObjects]=updatePathObjectivesData(testcomp,...
        obsInfo.PathObjectives,ModelObjects);
    end


    [ModelObjects,...
    AnalysisInformation.ReplacementInfo]=Sldv.DataUtils.getReplacementInfo(...
    testcomp,ModelObjects);



    if~isempty(observerModels)
        designModel=get_param(testcomp.analysisInfo.designModelH,'Name');
        ModelObjects=updateModelScope(ModelObjects,designModel,observerModels);
    end



    ts=sldvprivate('mdl_fundamental_ts',modelH,testcomp);
    TestCases={};
    tcIdxToSimoutMap=containers.Map('KeyType','double','ValueType','any');
    testCases=sldvprivate('sldv_datamodel_get_testcases',testcomp);

    testCasesTranspose=testCases';
    for tcIdx=1:length(testCasesTranspose)
        tc=testCasesTranspose(tcIdx);
        if sldvprivate('sldv_datamodel_isempty',tc.down)


            [TestCases,Objectives,obsInfo]=Sldv.DataUtils.addTestCase(tc,ts,...
            TestCases,Objectives,obsInfo,...
            goalIdToObjectiveIdMap,modelH,...
            testcomp,...
            tcIdxToSimoutMap,...
            true);
        end
    end

    [Objectives,TestCases,obsInfo]=updateObservabilityInformation(Objectives,...
    obsInfo,TestCases,...
    goalIdToObjectiveIdMap,...
    testcomp);
    Objectives=updateNoTestCaseStatus(Objectives,AnalysisInformation.Status);
    if isPathBased
        obsInfo.PathObjectives=updateNoTestCaseStatus(obsInfo.PathObjectives,AnalysisInformation.Status);
    end
    if(isempty(AnalysisInformation.InputPortInfo)&&hasDeadLogic&&...
        isempty(AnalysisInformation.AbstractedBlocks))


        for objIndex=1:length(Objectives)
            if strcmp(Objectives(objIndex).status,'Undecided due to stubbing')
                Objectives(objIndex).status='Active Logic';
            end
        end
    end


    removeApproximationFlags=true;
    for objIndex=1:length(Objectives)
        if strcmp(Objectives(objIndex).status,'Valid under approximation')||...
            strcmp(Objectives(objIndex).status,'Unsatisfiable under approximation')||...
            strcmp(Objectives(objIndex).status,'Falsified - needs simulation')||...
            strcmp(Objectives(objIndex).status,'Satisfied - needs simulation')||...
            strcmp(Objectives(objIndex).status,'Active Logic - needs simulation')||...
            strcmp(Objectives(objIndex).status,'Dead Logic under approximation')||...
            strcmp(Objectives(objIndex).status,'Undecided with testcase')||...
            strcmp(Objectives(objIndex).status,'Undecided with counterexample')||...
            strcmp(Objectives(objIndex).status,'Undecided due to runtime error')
            removeApproximationFlags=false;
            break;
        end
    end

    if removeApproximationFlags&&slavteng('feature','Reportapproximation')
        AnalysisInformation.Approximations.flags.hasDouble2RatConvert=false;
        AnalysisInformation.Approximations.flags.hasWhileLoopApprox=false;
        AnalysisInformation.Approximations.flags.lookup2DisReported=false;
        AnalysisInformation.Approximations.flags.lookupFxpisReported=false;
        AnalysisInformation.Approximations.flags.lookupApproxisReported=false;
    end


    sldvData.ModelInformation=ModelInformation;
    sldvData.AnalysisInformation=AnalysisInformation;
    sldvData.ModelObjects=ModelObjects;

    sldvData=storeDvIdsToGoalIdsMap(testcomp,sldvData);
    goalIdToDvIdMap=getGoalIdsToDvIdsMap(testcomp,sldvData);
    if(slavteng('feature','DebugLevel')==11)
        sldvData.GoalIdsToDvIds=goalIdToDvIdMap;
    end

    if~isempty(Constraints)
        sldvData.Constraints=Constraints;
    else

        sldvData.Constraints=[];
    end
    sldvData.Objectives=Objectives;

    if~isempty(TestCases)
        sldvData=Sldv.DataUtils.setSimData(sldvData,[],TestCases);
    end

    sldvData=Sldv.DataUtils.compressSldvData(sldvData);
    sldvData=Sldv.DataUtils.setVersionToCurrent(sldvData);

    if sldvshareprivate('util_is_analyzing_for_fixpt_tool')
        sldvData.EmlIdInfo=mapReplacementEmlIdsToOrig(testcomp.getEmlIdInfo,ModelObjects);
    end



    if testcomp.isSIL()||testcomp.isModelRefSIL()
        sldvData=sldv.code.xil.ReportDataUtils.addCodeMappingInfo(sldvData,allGoals);
    elseif~sldv.code.slcc.isEnabled()&&isfield(sldvData,'Objectives')&&...
        ~isempty(sldvData.Objectives)&&...
        isfield(sldvData.Objectives,'codeLnk')&&...
        isfield(sldvData.Objectives,'moduleName')


        sldvData.Objectives=rmfield(sldvData.Objectives,{'codeLnk','moduleName'});
    end

    if isPathBased
        pathInfoDisplayFlag=sldvprivate('generatePathInformation');
        if pathInfoDisplayFlag
            debugSldvData=sldvData;
            debugSldvData.ExtensionObjectives=obsInfo.extObjectives;
            debugSldvData.PathObjectives=obsInfo.PathObjectives;
            folderPath=sldvprivate(...
            'mdl_get_output_dir',testcomp);
            fileName=fullfile(folderPath,'DebugSldvData.mat');
            Sldv.DataUtils.saveDataToFile(debugSldvData,fileName);

        end
        if isfield(sldvData,'TestCases')&&isfield(sldvData.TestCases,'extObjectives')
            sldvData.TestCases=rmfield(sldvData.TestCases,'extObjectives');
        end
        if isfield(sldvData,'TestCases')&&isfield(sldvData.TestCases,'pathobjectives')
            sldvData.TestCases=rmfield(sldvData.TestCases,'pathobjectives');
        end
        if isfield(sldvData.ModelObjects,'pathobjectives')
            sldvData.ModelObjects=rmfield(sldvData.ModelObjects,'pathobjectives');
        end
        if isfield(sldvData.ModelObjects,'extObjectives')
            sldvData.ModelObjects=rmfield(sldvData.ModelObjects,'extObjectives');
        end
        if isfield(sldvData.Objectives,'pathObjectives')
            sldvData.Objectives=rmfield(sldvData.Objectives,'pathObjectives');
            sldvData.Objectives=rmfield(sldvData.Objectives,'satPathObjective');

        end
    end

    if hasQuickDeadLogic
        sldvData=Sldv.DataUtils.identifyDeadLogic(sldvData,objectiveToGoalMap);
    end






    function addModelObject(blkH,analysisTimeMap)

        if blkH.isEMLAuthorGen
            return;
        end

        [blkGoals,~,filteredBlkGoals]=blk_allgoals(blkH,true,true,true);
        blkGoals=[blkGoals,filteredBlkGoals];
        blkConstrs=blk_allconstraints(blkH);
        if isempty(blkGoals)&&isempty(blkConstrs)
            return;
        end

        [designSid,replacementSid,sid,type,num,isSfun,statePortIdx]=Sldv.DataUtils.getModelObjectInfoInDesignModel(testcomp,blkH);

        modelObjIdx=[];







        if~isempty(sid)
            modelObjKey=num2str(sid);
        else





            modelObjKey=[num2str(num),blkH.path];
        end

        isKeyflag=isKey(ModelObjectsMap,modelObjKey);
        if ModelObjectIndex>0&&~isempty(ModelObjectsMap)&&isKeyflag
            modelObjIdx=ModelObjectsMap(modelObjKey);
        end


        if isempty(modelObjIdx)
            modelObjIdx=ModelObjectIndex+1;
            modelObj=struct(...
            'descr',blkH.label,...
            'typeDesc',blkH.typeDesc,...
            'slPath',blkH.path,...
            'sfObjType',type,...
            'sfObjNum',num,...
            'sid',sid,...
            'designSid',designSid,...
            'replacementSid',replacementSid,...
            'statePortIdx',statePortIdx,...
            'objectives',[]...
            );

            if isPathBased
                modelObj.extObjectives=[];
                modelObj.pathobjectives=[];
            end

            if~isempty(observerModels)
                modelObj.modelScope='';
            end

            ModelObjectIndex=ModelObjectIndex+1;
            ModelObjects(ModelObjectIndex)=modelObj;
        end

        if~isKeyflag
            ModelObjectsMap(modelObjKey)=modelObjIdx;
        end

        if~isempty(obsInfo)
            goalIdToExtObjIdMap=obsInfo.goalIdToExtObjIdMap;
        end


        if(~isempty(blkGoals))
            for goal=blkGoals(:)'
                if strcmp(goal.type,'AVT_GOAL_PATH_OBJECTIVE')
                    continue;
                elseif strcmp(goal.type,'AVT_GOAL_CUSBLKCOV')&&...
                    goalIdToExtObjIdMap.isKey(goal.getGoalMapId)
                    idx=goalIdToExtObjIdMap(goal.getGoalMapId);
                    if isempty(ModelObjects(modelObjIdx).extObjectives)
                        ModelObjects(modelObjIdx).extObjectives=idx;
                    else
                        ModelObjects(modelObjIdx).extObjectives(end+1)=idx;
                    end
                    obsInfo.extObjectives(idx).modelObjectIdx=modelObjIdx;
                    if~isempty(analysisTimeMap)...
                        &&analysisTimeMap.isKey(goal.getGoalMapId)
                        obsInfo.extObjectives(idx).analysisTime=analysisTimeMap(goal.getGoalMapId);
                    else
                        obsInfo.extObjectives(idx).analysisTime=-1;
                    end
                    if isSfun
                        obsInfo.extObjectives(idx).outcomeValue=obsInfo.extObjectives(idx).outcomeValue-1;
                    end
                elseif goalIdToObjectiveIdMap.isKey(goal.getGoalMapId)
                    idx=goalIdToObjectiveIdMap(goal.getGoalMapId);
                    if isempty(ModelObjects(modelObjIdx).objectives)
                        ModelObjects(modelObjIdx).objectives=idx;
                    else
                        ModelObjects(modelObjIdx).objectives(end+1)=idx;
                    end
                    Objectives(idx).modelObjectIdx=modelObjIdx;
                    if~isempty(analysisTimeMap)...
                        &&analysisTimeMap.isKey(goal.getGoalMapId)
                        Objectives(idx).analysisTime=analysisTimeMap(goal.getGoalMapId);
                    else
                        Objectives(idx).analysisTime=-1;
                    end
                    if isSfun
                        Objectives(idx).outcomeValue=Objectives(idx).outcomeValue-1;
                    end

                end
            end
        end

        if~isempty(blkConstrs)
            minMaxConstrs=[];
            for idx=1:length(blkConstrs)
                objH=getObjectHandle(blkH);
                if strcmp(blkH.type,'SLDV_MODELOBJ_STATEFLOW')
                    [~,name]=sldvshareprivate('util_sf_link',objH);
                else
                    name=blkH.label;
                end
                if strcmp(blkConstrs(idx).type,'AVT_CNSTR_DESIGNRANGE')
                    Constr.name=name;
                    Constr.value=blkConstrs(idx).getIntervals();
                    Constr.modelObjIdx=modelObjIdx;
                    Constr.outcomeValue=blkConstrs(idx).outIndex;
                    Constr.busElementIdx=blkConstrs(idx).busSelElIdx;
                    Constr.descr=blkConstrs(idx).description;


                    isDuplicate=false;
                    for minMaxConstr=minMaxConstrs
                        if isequal(minMaxConstr,Constr)
                            isDuplicate=true;
                            break;
                        end
                    end
                    if~isDuplicate
                        minMaxConstrs=[minMaxConstrs,Constr];
                    end
                else
                    Constr.name=name;
                    Constr.value=blkConstrs(idx).getIntervals();
                    Constr.modelObjIdx=modelObjIdx;
                    if~isfield(Constraints,'Analysis')
                        Constraints.Analysis=Constr;
                    else
                        Constraints.Analysis(end+1)=Constr;
                    end
                end
            end

            if~isempty(minMaxConstrs)
                if~isfield(Constraints,'DesignMinMax')
                    Constraints.DesignMinMax=minMaxConstrs;
                else
                    Constraints.DesignMinMax=[Constraints.DesignMinMax,minMaxConstrs];
                end
            end
        end
    end

end

function emptyModelObject=createEmptyModelObj(isPathBased,observerModels)
    emptyModelObject=struct(...
    'descr','',...
    'typeDesc','',...
    'slPath','',...
    'sfObjType','',...
    'sfObjNum',-1,...
    'sid','',...
    'designSid','',...
    'replacementSid','',...
    'statePortIdx',-1,...
    'objectives',[]...
    );
    if isPathBased
        emptyModelObject.extObjectives=[];
        emptyModelObject.pathobjectives=[];
    end
    if~isempty(observerModels)
        emptyModelObject.modelScope='';
    end
end

function origEmlIdInfo=mapReplacementEmlIdsToOrig(replacementEmlIdInfo,modelObjects)
    if(isempty(replacementEmlIdInfo))

        origEmlIdInfo=[];
        return;
    end

    repToOrigSidMap=containers.Map;
    for i=1:numel(modelObjects)
        repToOrigSidMap(modelObjects(i).sid)=modelObjects(i).designSid;
    end

    origEmlIdInfo=containers.Map();
    keys=replacementEmlIdInfo.keys;
    for i=1:numel(keys)
        key=keys{i};


        if(repToOrigSidMap.isKey(replacementEmlIdInfo(key).MATLABFunctionIdentifier.SID))
            orig=repToOrigSidMap(replacementEmlIdInfo(key).MATLABFunctionIdentifier.SID);
            designSid=Simulink.ID.getSID(orig);
            origEmlIdInfo(key)=replacementEmlIdInfo(key).getIdWithNewSID(designSid);
        end
    end
end

function keepGoals=processInternalGoals(blk)







    [blkGoals,~,filteredBlkGoals]=blk_allgoals(blk,true,true,true);
    blkGoals=[blkGoals,filteredBlkGoals];
    keepGoals=[];

    if isempty(blkGoals)
        return;
    end

    rangeGoals=[];
    for i=1:length(blkGoals)
        goal=blkGoals(i);
        if strcmp(goal.type,'AVT_GOAL_RANGE')
            if~isInternalStateflow(goal)
                rangeGoals=[rangeGoals,goal];%#ok<AGROW>
            end
        else
            keepGoals=[keepGoals,goal];%#ok<AGROW>
        end
    end
    keepGoals=[keepGoals,rangeGoals];
end

function throwAway=isInternalStateflow(goal)
    throwAway=false;
    slBlkH=goal.up.slBlkH;


    if(strcmp(get_param(slBlkH,'Type'),'block')...
        &&strcmp(get_param(slBlkH,'BlockType'),'S-Function'))
        parent=get_param(get_param(slBlkH,'Parent'),'Handle');
        if strcmp(get_param(parent,'Type'),'block')&&...
            slprivate('is_stateflow_based_block',parent)
            if Sldv.utils.isAtomicSubchartSubsystem(slBlkH)
                throwAway=true;
            else
                portH=get_param(parent,'PortHandles');
                if goal.outIndex-1>length(portH.Outport)
                    throwAway=true;
                end
            end
        end
    else
        return;
    end
end

function handle=getObjectHandle(block)
    maskH=block.maskObj;
    if maskH==0
        handle=block.sfObjID;
        if handle==0
            handle=block.slBlkH;
        end
    else
        handle=maskH;
    end
end

function[lss,storeInData]=storeLink(goalH)
    blkCondGoalTypes=Sldv.utils.getSupportedBlockConditions;

    switch(goalH.type)
    case[{'AVT_GOAL_CUSTEST','AVT_GOAL_CUSPROOF','AVT_GOAL_OVERFLOW',...
        'AVT_GOAL_FLOAT_INF','AVT_GOAL_FLOAT_NAN','AVT_GOAL_FLOAT_SUBNORMAL',...
        'AVT_GOAL_DIV0','AVT_GOAL_ASSERT','AVT_GOAL_RANGE','AVT_GOAL_DESRANGE',...
        'AVT_GOAL_TRANS_CNFCT','AVT_GOAL_STATE_CONS','AVT_GOAL_SFARRAY_BNDS',...
        'AVT_GOAL_EMLARRAY_BNDS','AVT_GOAL_SELECT_BNDS','AVT_GOAL_MPSWITCH_BNDS',...
        'AVT_GOAL_INVALID_CAST','AVT_GOAL_MERGE_CNFCT','AVT_GOAL_UNINIT_DSR',...
        'AVT_GOAL_ARRBOUNDS','AVT_GOAL_RBW_HAZARD','AVT_GOAL_WAR_HAZARD',...
        'AVT_GOAL_WAW_HAZARD',...
        'AVT_GOAL_BLOCK_INPUT_RANGE_VIOLATION','AVT_GOAL_OBJECTIVE_COMPOSITION',...
        'AVT_GOAL_SFCN_COND','AVT_GOAL_SFCN_DEC','AVT_GOAL_SFCN_MCDC',...
        'AVT_GOAL_SFCN_ENTRY','AVT_GOAL_SFCN_EXIT','AVT_GOAL_SFCN_RELATIONAL_BOUNDARIES',...
        'AVT_GOAL_CODE_COND','AVT_GOAL_CODE_DEC','AVT_GOAL_CODE_MCDC',...
        'AVT_GOAL_CODE_ENTRY','AVT_GOAL_CODE_EXIT','AVT_GOAL_CODE_RELATIONAL_BOUNDARIES',...
        'AVT_GOAL_SFCN_RTE','AVT_GOAL_PATH_OBJECTIVE','AVT_GOAL_CUSBLKCOV',...
        'AVT_GOAL_CODE_RTE','AVT_GOAL_SUT_EXEC','AVT_GOAL_REQTABLE'...
        },blkCondGoalTypes]

        modelObj=goalH.up;
        cvId=0;
    otherwise

        modelObj=goalH.up.up;
        cvId=sldvprivate('getCvId',goalH.up);
    end

    storeInData=[];

    if isempty(modelObj)
        return;
    end

    lss=[];
    if modelObj.isSlBlock
        lss.blockH=modelObj.slBlkH;
    elseif modelObj.sfObjID>0
        sfId=modelObj.sfObjID;
        if(sf('get',sfId,'.isa')==sf('get','default','state.isa'))&&sf('get',sfId,'.eml.isEML')

            chartName=sf('get',sf('get',sfId,'.chart'),'.name');
            if any(chartName=='/')
                chartName=fliplr(strtok(fliplr(chartName),'/'));
            end

            if cvId>0
                lineInfo=sldvprivate('get_eml_line_info',sfId,cvId);
            else
                lineInfo=sldvprivate('get_eml_line_info',sfId,0,goalH.emlLineNumber);
            end
            linkText=[chartName,' #',num2str(lineInfo.lineNum)];
            lss=struct('objId',sfId,'objName',linkText,'startIdx',lineInfo.startIdx,'endIdx',lineInfo.endIdx);

            storeInData.isEml=true;
            storeInData.startIdx=lineInfo.startIdx;
            storeInData.endIdx=lineInfo.endIdx;
        elseif sf('get',sfId,'.isa')==sf('get','default','script.isa')
            chartName='';
            if(~strcmp(goalH.type,'AVT_GOAL_TESTGEN'))
                lineInfo=sldvprivate('get_eml_line_info',sfId,0,goalH.emlLineNumber);
            else
                lineInfo=sldvprivate('get_eml_line_info',sfId,cvId);
            end
            linkText=[chartName,' #',num2str(lineInfo.lineNum)];
            lss=struct('objId',sfId,'objName',linkText,'startIdx',lineInfo.startIdx,'endIdx',lineInfo.endIdx);
            storeInData.isEml=true;
            storeInData.startIdx=lineInfo.startIdx;
            storeInData.endIdx=lineInfo.endIdx;

        elseif modelObj.isTruthTableGen&&...
            (sf('get',sfId,'.isa')~=sf('get','default','data.isa'))


            lss.sfId=sfId;
            mappingInfo=sf('get',sfId,'.autogen.mapping');
            if isfield(mappingInfo,'index')

                lss.decIdx=mappingInfo.index;
                storeInData.isEml=false;
                storeInData.index=mappingInfo.index;
            else

                chart=sf('get',sfId,'.chart');
                name=sf('get',chart,'.name');
                if sf('get',chart,'.type')==0
                    name=[name,'.',sf('get',sfId,'.name')];
                end

                if any(name=='/')
                    name=fliplr(strtok(fliplr(name),'/'));
                end
                if(cvId==0)
                    ttItem=sldvprivate('get_script_to_truth_table_map',mappingInfo,goalH.emlLineNumber);
                else
                    lineInfo=sldvprivate('get_eml_line_info',sfId,cvId);
                    ttItem=sldvprivate('get_script_to_truth_table_map',mappingInfo,lineInfo.lineNum);
                end

                index=0;
                type=0;

                if~isempty(ttItem)
                    index=ttItem.index;
                    type=ttItem.type;
                end
                lss=struct('objId',sfId,'objName',name,'startIdx',type,'endIdx',index);

                storeInData.isEml=true;
                storeInData.startIdx=type;
                storeInData.endIdx=index;
            end
        else
            lss.sfId=sfId;
        end
    else

        if strcmp(goalH.type,'AVT_GOAL_TESTGEN')
            lineInfo=sldvprivate('get_eml_line_info',0,cvId);
        else
            lineInfo=sldvprivate('get_eml_line_info',0,0,goalH.emlLineNumber);
        end

        linkText=[' #',num2str(lineInfo.lineNum)];
        lss=struct('objId',0,'objName',linkText,'startIdx',lineInfo.startIdx,'endIdx',lineInfo.endIdx);
        storeInData.isEml=true;
        storeInData.startIdx=lineInfo.startIdx;
        storeInData.endIdx=lineInfo.endIdx;
    end
end

function cs=blk_allconstraints(blkH)
    cs=[];
    for i=1:length(blkH.constraints)
        if blkH.constraints(i).isEnabled
            cs=[cs,blkH.constraints(i)];%#ok<AGROW>
        end
    end
end

function Objectives=updateNoTestCaseStatus(Objectives,analysisStatus)









    if strcmpi(analysisStatus,'In progress')


        return;
    end

    for i=1:length(Objectives)
        if strcmpi(Objectives(i).status,'satisfied')||...
            strcmpi(Objectives(i).status,'satisfied - needs simulation')
            if isfield(Objectives(i),'testCaseIdx')
                if isempty(Objectives(i).testCaseIdx)
                    Objectives(i).status='Satisfied - No Test Case';
                end
            else
                Objectives(i).status='Satisfied - No Test Case';
            end
        end
        if strcmpi(Objectives(i).status,'falsified')||...
            strcmpi(Objectives(i).status,'falsified - needs simulation')
            if isfield(Objectives(i),'testCaseIdx')
                if isempty(Objectives(i).testCaseIdx)
                    Objectives(i).status='Falsified - No Counterexample';
                end
            else
                Objectives(i).status='Falsified - No Counterexample';
            end
        end
    end

end

function modelObjIndex=getModelObjIndex(Sid,modelObjects)






    modelObjIndex=-1;
    for i=1:length(modelObjects)
        msid=modelObjects(i).sid;
        if strcmp(msid,Sid)==1
            modelObjIndex=i;
            return;
        end
    end
end


function stmt=getPathStmt(id,pspec)


    stmts=pspec.stmt;
    for i=1:length(stmts)
        if stmts(i).specId==id
            stmt=stmts(i);
            return;
        end
    end
end

function modelObjects=addPathObjectiveToSourceModelObj(modelObjects,moindex,pathobjindex)

    mo=modelObjects(moindex);
    if~isempty(mo.pathobjectives)
        mo.pathobjectives(end+1)=pathobjindex;
    else
        mo.pathobjectives(1)=pathobjindex;
    end
    modelObjects(moindex)=mo;
end

function[isTestObj,toblkh]=checkIfTestObjective(sfcnBlkH)
    toblkh=[];
    isTestObj=false;
    if strcmp(get_param(sfcnBlkH,'BlockType'),'S-Function')&&...
        strcmp(get_param(sfcnBlkH,'Name'),'customAVTBlockSFcn')
        isTestObj=true;
        topath=get_param(get_param(sfcnBlkH,'Parent'),'Parent');
        toblkh=get_param(topath,'Handle');
    end
end

function[pathobj,modelObjects]=updatePathInfo(pathobj,index,stmt,modelObjects,testComp)
    detectionSites=struct([]);
    dlist=stmt.detectionSites;
    srcsid=stmt.set.elem.sid;
    moId=getModelObjIndex(srcsid,modelObjects);
    if moId<0
        [testObj,toblkh]=checkIfTestObjective(Simulink.ID.getHandle(srcsid));
        if testObj
            moId=getModelObjIndex(Simulink.ID.getSID(toblkh),modelObjects);
        end
    end

    for i=1:length(dlist)
        desBlkH=mapBlockHToOriginal(Simulink.ID.getHandle(dlist(i).detectionPoint),testComp);
        mosid=Simulink.ID.getSID(desBlkH);
        port=dlist(i).Port;
        Loggable=[];
        if isfield(dlist(i),'Loggable')
            Loggable=dlist(i).Loggable;
        end
        if isempty(detectionSites)
            detectionSites(1).modelObj=mosid;
            detectionSites(1).port=port;
            if~isempty(Loggable)
                detectionSites(1).Loggable=Loggable;
            end
        else
            detectionSites(end+1).modelObj=mosid;%#ok<AGROW>
            detectionSites(end).port=port;
            if~isempty(Loggable)
                detectionSites(end).Loggable=Loggable;
            end
        end
    end
    pathobj.detectionSites=detectionSites;
    pathobj.label='';
    if moId>0
        modelObjects=addPathObjectiveToSourceModelObj(modelObjects,moId,index);
        pathobj.label=modelObjects(moId).descr;
    end
end

function[PathObjectives,modelObjects]=updatePathObjectivesData(testcomp,PathObjectives,modelObjects)
    pspec=testcomp.pathCompositionSpec;
    for i=1:length(PathObjectives)
        id=PathObjectives(i).id;
        stmt=getPathStmt(id,pspec);
        [PathObjectives(i),modelObjects]=updatePathInfo(PathObjectives(i),i,stmt,modelObjects,testcomp);
    end
end

function PathObjectives=addPathObjective(goalH,obsInfo,...
    goalIdToObjIdMap,...
    linkInfo,rangeData,...
    objectiveFactory)%#ok<INUSL>

    PathObjectives=obsInfo.PathObjectives;
    goalIdToExtObjIdMap=obsInfo.goalIdToExtObjIdMap;
    goalIdToPathObjIdMap=obsInfo.goalIdToPathObjIdMap;

    if~goalIdToPathObjIdMap.isKey(goalH.getGoalMapId)

        newObjective=objectiveFactory.createPathObjective(goalH,linkInfo);

        if isempty(PathObjectives)
            PathObjectives=newObjective;
        else
            PathObjectives(end+1)=newObjective;
        end


        composedGoals=goalH.composedGoals;
        if~isempty(composedGoals)


            currentGoal=composedGoals(1);
            currGoalIdx=currentGoal.getGoalMapId();
            if goalIdToExtObjIdMap.isKey(currGoalIdx)
                composedObjIndex=goalIdToExtObjIdMap(...
                currGoalIdx);
                PathObjectives(end).extensionObjectives=composedObjIndex;




            elseif strcmp(currentGoal.type,'AVT_GOAL_CUSTEST')&&...
                goalIdToObjIdMap.isKey(currGoalIdx)
                composedObjIndex=goalIdToObjIdMap(currGoalIdx);
                PathObjectives(end).objectives=composedObjIndex;
            end
        end
        goalIdToPathObjIdMap(goalH.getGoalMapId)=length(PathObjectives);%#ok<NASGU>
    end
end

function[objectives,testCases,obsInfo]=updateObservabilityInformation(objectives,...
    obsInfo,testCases,...
    goalIdToObjIdMap,testComp)
    if isempty(obsInfo)
        return;
    end

    pathObjectives=obsInfo.PathObjectives;







    [objectives,extObjectives]=mapPathObjsToObjs(objectives,obsInfo,...
    testComp,goalIdToObjIdMap);





    extObjectives=updateObservabilityStatus(extObjectives,pathObjectives);
    obsInfo.extObjectives=extObjectives;

    objectives=updateObservabilityStatus(objectives,pathObjectives);
    obsInfo.extObjectives=extObjectives;
end

function[objectives,extObjectives]=mapPathObjsToObjs(objectives,...
    obsInfo,testComp,...
    goalIdToObjIdMap)









    pathObjectives=obsInfo.PathObjectives;
    extObjectives=obsInfo.extObjectives;
    for pathObjIterator=1:length(pathObjectives)
        pathObjective=pathObjectives(pathObjIterator);
        relatedObjIndex=pathObjective.extensionObjectives;
        if isempty(relatedObjIndex)
            relatedObjIndex=pathObjective.objectives;
        end


        objectiveIdx=relatedObjIndex;





        pathGoal=testComp.getGoal(pathObjective.goal);
        srcGoal=pathGoal.composedGoals(1);
        if strcmp(srcGoal.type,'AVT_GOAL_CUSBLKCOV')
            if isempty(extObjectives(objectiveIdx).pathObjectives)
                extObjectives(objectiveIdx).pathObjectives=pathObjIterator;
            else
                extObjectives(objectiveIdx).pathObjectives(end+1)=pathObjIterator;
            end
            extnGoal=srcGoal;
            covGoalIds=testComp.getCovGoalIdsFromExtnGoalId(extnGoal.getGoalMapId());
            for covGoalIdx=covGoalIds
                if goalIdToObjIdMap.isKey(covGoalIdx)
                    covObjIdx=goalIdToObjIdMap(covGoalIdx);
                    if isempty(objectives(covObjIdx).pathObjectives)
                        objectives(covObjIdx).pathObjectives=pathObjIterator;
                    else
                        objectives(covObjIdx).pathObjectives(end+1)=pathObjIterator;
                    end
                end
            end

        elseif strcmp(srcGoal.type,'AVT_GOAL_CUSTEST')
            if isempty(objectives(objectiveIdx).pathObjectives)
                objectives(objectiveIdx).pathObjectives=pathObjIterator;
            else
                objectives(objectiveIdx).pathObjectives(end+1)=pathObjIterator;
            end
        end
    end
end


function objectives=updateObservabilityStatus(objectives,pathObjectives)
    for i=1:length(objectives)
        objective=objectives(i);


        if isfield(objective,'pathObjectives')&&...
            ~isempty(objective.pathObjectives)
            pathObjectiveIndices=objective.pathObjectives;
            relevantPathObjectives=pathObjectives(pathObjectiveIndices);
            pathObjStatuses={relevantPathObjectives.status};

            updatedDetectability=false;

            if((strcmp(objective.status,'Satisfied'))||(strcmp(objective.status,'Satisfied - needs simulation')))&&...
                isfield(relevantPathObjectives,'testCaseIdx')&&isfield(objective,'testCaseIdx')
                pathObjTestCases=[relevantPathObjectives.testCaseIdx];
                objTCIdx=objective.testCaseIdx;
                [status,location]=ismember(objTCIdx,pathObjTestCases);
                if status
                    objective.detectability='Detectable';
                    objective.satPathObjective=pathObjectiveIndices(location);
                    objective.detectionSites=relevantPathObjectives(location).detectionSites;
                    updatedDetectability=true;
                end
            end
            if~updatedDetectability
                if strcmp(objective.status,'Justified')||strcmp(objective.status,'Excluded')
                    objective.detectability='';
                elseif(all(strcmp('Unsatisfiable',pathObjStatuses)))
                    objective.detectability='Not Detectable';
                else
                    objective.detectability='Undecided';
                end
            end
            objectives(i)=objective;
        end
    end
end

function modelObjects=updateModelScope(modelObjects,designModel,observerModels)





    modelRefs=find_mdlrefs(designModel,'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices,'ReturnTopModelAsLastElement',false);
    for i=1:length(modelObjects)
        sid=modelObjects(i).designSid;
        if contains(sid,observerModels)
            modelObjects(i).modelScope='ObserverReference';
        elseif contains(sid,modelRefs)
            modelObjects(i).modelScope='ModelReference';
        else
            modelObjects(i).modelScope='TopModel';
        end
    end
end

function blockH=mapBlockHToOriginal(blockH,testcomp)
    blockReplacementApplied=testcomp.analysisInfo.replacementInfo.replacementsApplied;
    atomicSubsystemAnalysis=sldvprivate('mdl_iscreated_for_subsystem_analysis',testcomp);
    if blockReplacementApplied||atomicSubsystemAnalysis
        origModelH=testcomp.analysisInfo.designModelH;
        if atomicSubsystemAnalysis
            parent=get_param(testcomp.analysisInfo.analyzedSubsystemH,'parent');
            parentH=get_param(parent,'Handle');
        else
            parentH=origModelH;
        end
        blockH=sldvshareprivate('util_resolve_obj',...
        blockH,parentH,atomicSubsystemAnalysis,...
        blockReplacementApplied,testcomp);
    end
end


function Objectives=addExtObjective(goalH,Objectives,goalIdToExtObjIdMap,linkInfo,rangeData,objectiveFactory,objectiveToGoalMap,modelH)
    if~goalIdToExtObjIdMap.isKey(goalH.getGoalMapId)
        newObjective=objectiveFactory.createObjective(goalH,linkInfo,rangeData,modelH);

        Objectives=[Objectives,newObjective];

        goalIdToExtObjIdMap(goalH.getGoalMapId)=length(Objectives);%#ok<NASGU>
        objectiveToGoalMap(length(Objectives))=goalH;%#ok<NASGU>
    end
end

function sldvData=storeDvIdsToGoalIdsMap(testcomp,sldvData)

    if(slavteng('feature','DebugLevel')~=11)
        return
    end
    dvIdsToGoalIdsMap=containers.Map('KeyType','int32','ValueType','int32');

    PropDvIdsArray=testcomp.getPropDvIdsArray;

    [m,n]=size(PropDvIdsArray);

    for rowIndex=1:m
        for columnIndex=2:n
            if(PropDvIdsArray(rowIndex,columnIndex)~=-1)
                if~dvIdsToGoalIdsMap.isKey(PropDvIdsArray(rowIndex,columnIndex))
                    dvIdsToGoalIdsMap(PropDvIdsArray(rowIndex,columnIndex))=PropDvIdsArray(rowIndex,1);
                end
            end
        end
    end

    sldvData.dvIdsToGoalIds=dvIdsToGoalIdsMap;

end


function goalIdToDvIdMap=getGoalIdsToDvIdsMap(testcomp,sldvData)

    goalIdToDvIdMap=containers.Map('KeyType','int32','ValueType','int32');

    PropDvIdsArray=testcomp.getPropDvIdsArray;

    [m,n]=size(PropDvIdsArray);

    for rowIndex=1:m
        for columnIndex=2:n
            if(PropDvIdsArray(rowIndex,columnIndex)~=-1)
                if~goalIdToDvIdMap.isKey(PropDvIdsArray(rowIndex,1))
                    goalIdToDvIdMap(PropDvIdsArray(rowIndex,1))=PropDvIdsArray(rowIndex,columnIndex);
                end
            end
        end
    end

end




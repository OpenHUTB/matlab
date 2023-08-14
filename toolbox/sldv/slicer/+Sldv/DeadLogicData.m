classdef DeadLogicData<matlab.mixin.Copyable

    properties(Access=private)
        sldvDataMap;
    end

    properties(Constant,Hidden=true)

        dLStr='Dead Logic';
        decStr='Decision';
        condStr='Condition';
    end

    methods
        function obj=DeadLogicData(sldvData)
            obj.sldvDataMap=containers.Map('KeyType','char',...
            'ValueType','any');
            if nargin==1&&~isempty(sldvData)
                obj.add(sldvData)
            end
        end

        function add(obj,sldvData)
            assert(isfield(sldvData,'AnalysisInformation')&&...
            contains(sldvData.AnalysisInformation.AppliedAnalysisStrategy,...
            'DeadLogic'));
            sys=Sldv.DeadLogicData.getAnalyzedSys(sldvData);
            obj.sldvDataMap(sys)=sldvData;
        end

        function remove(obj,sys)
            sys=Simulink.ID.getSID(sys);
            if isKey(obj.sldvDataMap,sys)
                obj.sldvDataMap.remove(sys);
            end
        end

        function removeByIdx(obj,idx)
            allSys=obj.getAllRefinedSys();
            if idx<=length(allSys)
                obj.remove(allSys{idx});
            end
        end

        function sys=getAllRefinedSys(obj)
            sys=obj.sldvDataMap.keys;
            sys=sys(cellfun(@(s)isvalid(s),sys));

            function yesno=isvalid(s)
                yesno=true;
                try
                    get_param(s,'handle');
                catch
                    yesno=false;
                end
            end
        end

        function[yesno,sldvData,idx]=hasAnalysisData(obj,bh)
            elemSid=getSID(bh);

            allData=obj.sldvDataMap.values;
            yesno=false;
            idx=[];
            sldvData=[];
            for i=1:length(allData)
                sldvData=allData{i};
                idx=find(strcmp({sldvData.ModelObjects.designSid},elemSid),1);
                if~isempty(idx)
                    yesno=true;
                    return;
                end
            end
        end

        function sldvData=getSldvData(obj,sys)
            sldvData=[];
            sys=Simulink.ID.getSID(sys);
            if isKey(obj.sldvDataMap,sys)
                sldvData=obj.sldvDataMap(sys);
            end
        end

        function[d,detail]=getDecisionInfo(obj,bh)
            d=[0,0];
            detail=[];
            objectiveStruct=getObjectives(obj,bh,Sldv.DeadLogicData.decStr);
            if~isempty(objectiveStruct)
                detail=locGetDecisionDetailStruct();
                for idx=1:length(objectiveStruct)

                    covPointIdx=objectiveStruct(idx).coveragePointIdx;
                    outIdx=objectiveStruct(idx).outcomeValue+1;
                    outcome=locGetOutcomeStruct();
                    outcome.text=objectiveStruct(idx).label;

                    outcome.executionCount=~strcmpi(objectiveStruct(idx).status,...
                    Sldv.DeadLogicData.dLStr);
                    d(2)=d(2)+1;
                    d(1)=d(1)+outcome.executionCount;
                    detail.decision(covPointIdx).outcome(outIdx)=outcome;
                end
            end
        end

        function[d,detail]=getConditionInfo(obj,bh)
            d=[0,0];
            detail=[];
            objectiveStruct=getObjectives(obj,bh,Sldv.DeadLogicData.condStr);
            if~isempty(objectiveStruct)
                detail=locGetConditionDetailStruct();
                for idx=1:length(objectiveStruct)

                    covPointIdx=objectiveStruct(idx).coveragePointIdx;
                    outIdx=objectiveStruct(idx).outcomeValue;
                    count=~strcmpi(objectiveStruct(idx).status,...
                    Sldv.DeadLogicData.dLStr);
                    if outIdx
                        detail(covPointIdx).trueCnts=count;
                    else
                        detail(covPointIdx).falseCnts=count;
                    end
                    d(2)=d(2)+1;
                    d(1)=d(1)+count;
                end
            end
        end

        function[activeStates,hasMetric]=getActiveStates(obj,sfObj,metric,substates)
            activeStates=[];
            hasMetric=false;
            objectiveStruct=getObjectives(obj,sfObj,Sldv.DeadLogicData.decStr);
            if isempty(objectiveStruct)
                activeStates=[];
                return;
            end
            requiredIds=contains({objectiveStruct.descr},metric);
            objectiveStruct=objectiveStruct(requiredIds);
            hasMetric=~isempty(objectiveStruct);
            for idx=1:length(objectiveStruct)
                if~strcmpi(objectiveStruct(idx).status,...
                    Sldv.DeadLogicData.dLStr)
                    state=findSubstate(objectiveStruct(idx).descr);
                    if isempty(activeStates)
                        activeStates=state;
                    else
                        activeStates(end+1)=state;%#ok<AGROW>
                    end
                end
            end
            if~hasMetric
                activeStates=[];
                return;
            end
            function state=findSubstate(descr)
                for i=1:length(substates)

                    name=['"',substates(i).Name,'"'];
                    if contains(descr,name)
                        state=substates(i);
                        return;
                    end
                end
            end
        end

        function saveToFile(obj,packageName)
            tmpFile=[tempname,'.mat'];
            sldvdata=obj.sldvDataMap.values;%#ok<NASGU>
            save(tmpFile,'sldvdata');
            if isempty(packageName)||~exist(packageName,'file')

                saveDir=fileparts(packageName);
                if~isempty(saveDir)&&~exist(saveDir,'dir')
                    mkdir(saveDir);
                end
                slcrxPackager.mexHelper('setSlicerData',packageName,'','');
            end
            slcrxPackager.mexHelper('updateDeadLogicData',packageName,tmpFile);
        end

        function delete(obj)
            delete(obj.sldvDataMap);
        end
    end

    methods(Access=private)
        function objectiveStruct=getObjectives(obj,bh,type)

            objectiveStruct=[];

            [yesno,sldvData,idx]=obj.hasAnalysisData(bh);
            if yesno
                ids=sldvData.ModelObjects(idx).objectives;
                objectiveStruct=sldvData.Objectives(ids);
                requiredIds=strcmpi({objectiveStruct.type},type);
                objectiveStruct=objectiveStruct(requiredIds);
            end
        end
    end

    methods(Static)
        function[sldvData,status,IncompatibilityMessages]=generateDeadLogicResults(sysH,analysisTime,uimode)
            invalid=builtin('_license_checkout','Simulink_Design_Verifier','quiet');
            if invalid
                error(message('Sldv:RunTestCase:SimulinkDesignVerifierNotLicensed'));
            end
            isBd=strcmp(get_param(sysH,'type'),'block_diagram');
            if~isBd&&Simulink.SubsystemType.isModelBlock(sysH)
                sysH=get_param(get_param(sysH,'modelName'),'handle');
            end

            mdlH=bdroot(sysH);
            isMdlCompiled=any(strcmp(get_param(mdlH,'SimulationStatus'),{'paused','initializing','compiled'}));
            assert(~isMdlCompiled);

            options=deepCopy(sldvoptions(mdlH));
            options.Mode='DesignErrorDetection';
            options.DetectIntegerOverflow='off';
            options.DetectDivisionByZero='off';
            options.DesignMinMaxCheck='off';
            options.DetectOutOfBounds='off';
            options.DetectDeadLogic='on';
            options.DetectActiveLogic='off';
            options.DisplayReport='off';
            options.OutputDir=fullfile(tempdir,'sldv_output','$ModelName$');
            options.MaxProcessTime=analysisTime;
            options.RebuildModelRepresentation='Always';

            if uimode
                progIndicator=Sldv.Utils.ScopedProgressIndicator('Sldv:ModelSlicer:gui:DeadLogicProgress');
                cleanupObj=onCleanup(@()delete(progIndicator));
            end

            [~,status,fileNames,~,IncompatibilityMessages]=evalc('sldvrun(sysH, options, false)');
            if status
                data=load(fileNames.DataFile);
                sldvData=data.sldvData;
            else
                sldvData=[];
            end
        end

        function dlData=loadFromFile(packageName)
            if isempty(packageName)||~exist(packageName,'file')
                Mex=MException('ModelSlicer:BadSlcrxPackage',...
                getString(message('Sldv:ModelSlicer:Coverage:BadSlcrxPackage')));
                throw(Mex);
            end
            tmpFile=[tempname,'.mat'];
            try
                slcrxPackager.mexHelper('getDeadLogicData',packageName,tmpFile);
                res=load(tmpFile);
                dlData=Sldv.DeadLogicData;
                for i=1:length(res.sldvdata)
                    dlData.add(res.sldvdata{i});
                end
            catch Mex
                mex=MException('ModelSlicer:InvalidDeadLogicFile',...
                getString(message('Sldv:ModelSlicer:ModelSlicer:InvalidDeadLogicFile')));
                throw(mex);
            end
        end

        function dlData=importFromSldvData(sldvFileName,packageName)
            try
                res=load(sldvFileName);
                fn=fieldnames(res);
                dlData=Sldv.DeadLogicData;


                dlData.add(res.(fn{1}));
            catch
                mex=MException('ModelSlicer:BadSldvData','%s',...
                getString(message('Sldv:LoadResults:FailInvalidDataFile',sldvFileName)));
                throw(mex);
            end
            dlData.saveToFile(packageName);
        end

        function sys=getAnalyzedSys(sldvData)
            if isfield(sldvData.ModelInformation,'SubsystemPath')
                sys=Simulink.ID.getSID(sldvData.ModelInformation.SubsystemPath);
            else
                sys=Simulink.ID.getSID(sldvData.ModelInformation.Name);
            end
        end
    end
end

function detail=locGetDecisionDetailStruct()
    detail=struct('decision',...
    struct('outcome',...
    locGetOutcomeStruct()));
end

function outcomeStruct=locGetOutcomeStruct()
    outcomeStruct=struct('text',[],'executionCount',0);
end


function detail=locGetConditionDetailStruct()
    detail=struct('trueCnts',0,...
    'falseCnts',0);
end


function sid=getSID(bh)
    if~iscell(bh)
        sid=Simulink.ID.getSID(bh);
    else


        sid=Simulink.ID.getSID(bh{2});
    end
end

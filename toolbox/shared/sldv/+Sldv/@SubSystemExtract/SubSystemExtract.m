



classdef SubSystemExtract<Sldv.Extract



    properties(Access=public)



        UseSFBasedFcnCallGen=false;


        NewSubsystemH=[];
    end

    properties(Access=protected)

        SubSystemH=[];


        CachedAutoSaveState=[];



        SettingsCache=[];



        PortInfo=[];


        Ss2mdlExc=[];



        IsAtomicSubchart=false;



        ReferencedSimulinkSignalVars=[];



        AtomicSubChartWithParam=false;
    end

    methods
        function obj=SubSystemExtract(utilityName)
            if nargin<1
                utilityName='sldvextract';
            end
            obj=obj@Sldv.Extract(utilityName);
        end

        function obj=set.UseSFBasedFcnCallGen(obj,val)
            if~islogical(val)
                error(message('Sldv:SubSysExtract:InvalidUseSFBasedFcnCallGen'));
            end
            if val&&~license('test','Stateflow')
                error(message('Sldv:SubSysExtract:InvalidUseSFBasedFcnCallGenNoSF'));
            end
            obj.UseSFBasedFcnCallGen=val;
        end

        function obj=set.NewSubsystemH(obj,val)
            if strcmp(get_param(val,'TreatAsAtomicUnit'),'on')&&...
                ~strcmp(get_param(val,'RTWSystemCode'),'Auto')

                set_param(val,'LinkStatus','none');
                set_param(val,'RTWSystemCode','Auto');
            end
            obj.NewSubsystemH=val;
        end
    end

    methods(Access=protected)

        function configureAutoSaveState(obj)
            if isempty(obj.CachedAutoSaveState)
                old_autosave_state=get_param(0,'AutoSaveOptions');
                obj.CachedAutoSaveState=old_autosave_state;
                new_autosave_state=old_autosave_state;
                new_autosave_state.SaveOnModelUpdate=0;
                new_autosave_state.SaveBackupOnVersionUpgrade=0;
                set_param(0,'AutoSaveOptions',new_autosave_state);
            end
        end

        function restoreAutoSaveState(obj)
            if~isempty(obj.CachedAutoSaveState)
                old_autosave_state=obj.CachedAutoSaveState;
                set_param(0,'AutoSaveOptions',old_autosave_state);
                obj.CachedAutoSaveState=[];
            end
        end

        function storeOriginalModelParams(obj)
            settingsCache.DirtyStatus=get_param(obj.OrigModelH,'Dirty');
            settingsCache.OldConfigSet=getActiveConfigSet(obj.OrigModelH);
            settingsCache.BusObjectLabelMismatch=...
            get_param(obj.OrigModelH,'BusObjectLabelMismatch');
            settingsCache.CheckMdlBeforeBuild=...
            get_param(obj.OrigModelH,'CheckMdlBeforeBuild');
            obj.SettingsCache=settingsCache;
        end

        function changeModelParams(obj)
            Sldv.utils.replaceConfigSetRefWithCopy(obj.OrigModelH);
            set_param(obj.OrigModelH,'BusObjectLabelMismatch','error');
            set_param(obj.OrigModelH,'CheckMdlBeforeBuild','off');
        end

        function fixExtractedMdlConfigCompName(obj)
            origCS=obj.SettingsCache.OldConfigSet;
            while(isa(origCS,'Simulink.ConfigSetRef'))
                origCS=origCS.getRefConfigSet();
            end
            exCS=getActiveConfigSet(obj.ModelH);
            exCS.Name=origCS.Name;
        end

        function fixExtractedMdlSampleTimeConstraint(obj)
            if~strcmp(get_param(obj.ModelH,'SolverType'),'Variable-step')
                sampleTimeConstraintExtracted=get_param(obj.ModelH,'SampleTimeConstraint');
                sampleTimeConstraintOriginal=get_param(obj.OrigModelH,'SampleTimeConstraint');
                if strcmp(sampleTimeConstraintExtracted,'STIndependent')&&...
                    ~strcmp(sampleTimeConstraintExtracted,sampleTimeConstraintOriginal)



                    set_param(obj.ModelH,'SampleTimeConstraint',sampleTimeConstraintOriginal);
                end
            end
        end

        function fixExtractedMdlConfigSettings(obj)
            if~isempty(obj.SettingsCache)

                if~isempty(obj.ModelH)
                    set_param(obj.ModelH,'BusObjectLabelMismatch',...
                    obj.SettingsCache.BusObjectLabelMismatch);
                    set_param(obj.ModelH,'CheckMdlBeforeBuild',...
                    obj.SettingsCache.CheckMdlBeforeBuild);
                end
            end
        end

        function restoreOriginalModelParams(obj)
            if~isempty(obj.SettingsCache)

                set_param(obj.OrigModelH,'BusObjectLabelMismatch',...
                obj.SettingsCache.BusObjectLabelMismatch);
                set_param(obj.OrigModelH,'CheckMdlBeforeBuild',...
                obj.SettingsCache.CheckMdlBeforeBuild);
                Sldv.utils.restoreConfigSet(obj.OrigModelH,obj.SettingsCache.OldConfigSet);
                set_param(obj.OrigModelH,'Dirty',...
                obj.SettingsCache.DirtyStatus);
                obj.SettingsCache=[];
            end
        end

        function detectReferencedSimulinkSignalVars(obj)
            context=getfullname(obj.SubSystemH);
            filterSignals=...
            @(var)(isa(var,'Simulink.Signal')&&~isa(var,'Simulink.Bus'));
            varsbws=Simulink.findVars(context,'SearchMethod','cached',...
            'WorkspaceType','base',...
            'ReturnResolvedVar',true,...
            'Value',filterSignals);
            varsmws=Simulink.findVars(context,'SearchMethod','cached',...
            'WorkspaceType','model',...
            'ReturnResolvedVar',true,...
            'Value',filterSignals);
            obj.ReferencedSimulinkSignalVars=[varsbws',varsmws'];
        end


        invokess2mdl(obj)


        function deriveSs2mdlError(obj)
            obj.deriveErrorMsg(obj.Ss2mdlExc)
        end

        function deriveSsError(obj,msg,msg_id,blockH)
            if~isempty(blockH)
                err_msg=strrep(msg,newline,' ');
                origModelH=bdroot(blockH);
                sldvshareprivate('avtcgirunsupcollect','clear');
                sldvshareprivate('avtcgirunsupcollect','push',origModelH,...
                'sldv',err_msg,msg_id);
                obj.ErrMsg=...
                sldvshareprivate('avtcgirunsupdialog',origModelH,obj.ShowUI);
            else
                obj.ErrMsg.msgid=msg_id;
                obj.ErrMsg.msg=msg;
            end
        end

        function fixSubsystemName(obj)
            origSubsystemName=get_param(obj.SubSystemH,'Name');


            newSubsystem=find_system(obj.ModelH,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'SID','1');
            newSubsystemH=get_param(newSubsystem,'Handle');
            obj.NewSubsystemH=newSubsystemH;
            set_param(newSubsystemH,'Name',origSubsystemName);
            try
                set_param(obj.ModelH,'DVExtractedSubsystem',origSubsystemName);
            catch Mex %#ok<NASGU>
                add_param(obj.ModelH,'DVExtractedSubsystem',origSubsystemName);
            end
        end

        function fixSubsystemRelativeSettings(obj)
            set_param(obj.ModelH,'CovPath','/');
        end

        addInportsForDSRW(obj)




        copySFDebugSettings(obj)



        saveExtractedModel(obj)


        function restoreLibLinks(obj)
            infoExtractedSS=libinfo(obj.NewSubsystemH,'SearchDepth',0);
            if~isempty(infoExtractedSS)&&strcmp(infoExtractedSS.LinkStatus,'inactive')
                infoOrigSS=libinfo(obj.SubSystemH,'SearchDepth',0);
                if obj.IsAtomicSubchart&&~isempty(get_param(obj.NewSubsystemH,'DSMValues'))
                    set_param(obj.NewSubsystemH,'LinkStatus','none');
                elseif~isempty(infoOrigSS)&&...
                    ~strcmp(infoExtractedSS.LinkStatus,infoOrigSS.LinkStatus)&&...
                    exist(infoExtractedSS.Library,'file')==4
                    set_param(obj.NewSubsystemH,'LinkStatus','restore');
                end
            end
        end

        function fixAtomicSubchartMask(obj)
            if obj.IsAtomicSubchart&&...
                ~isempty(get_param(obj.NewSubsystemH,'MaskValues'))
                ssName=get_param(obj.NewSubsystemH,'Name');
                maskPrompts=get_param(obj.NewSubsystemH,'MaskPrompts');
                maskValues=get_param(obj.NewSubsystemH,'MaskValues');
                maskVariables=get_param(obj.NewSubsystemH,'MaskVariables');

                Simulink.BlockDiagram.createSubSystem(obj.NewSubsystemH);
                newSubsystem=find_system(obj.ModelH,'searchdepth',1,'BlockType','SubSystem');
                if length(newSubsystem)>1
                    for idx=1:length(newSubsystem)
                        childSubsystems=find_system(newSubsystem(idx),'searchdepth',1,'BlockType','SubSystem');
                        childSubsystems(1)=[];
                        if length(childSubsystems)==1&&...
                            strcmp(get_param(childSubsystems,'Name'),ssName)
                            createdSubSystem=newSubsystem(idx);
                            break;
                        end
                    end
                else
                    createdSubSystem=newSubsystem;
                end
                obj.NewSubsystemH=get_param(createdSubSystem,'Handle');

                set_param(obj.NewSubsystemH,'MaskPrompts',maskPrompts);
                set_param(obj.NewSubsystemH,'MaskValues',maskValues);
                set_param(obj.NewSubsystemH,'MaskVariables',maskVariables);
                set_param(obj.NewSubsystemH,'Name',ssName)

                obj.AtomicSubChartWithParam=true;
            end
        end

    end

    methods(Access=public,Static)
        function[solverChanged,msg]=createForcessDiscreteMsg(modelH,oldModelH)
            solverChanged=false;
            msg='';
            modelOb=get_param(oldModelH,'Object');
            modelObAcs=modelOb.getActiveConfigSet;
            modelSolverType=modelObAcs.getProp('SolverType');

            if strcmp(modelSolverType,'Variable-step')
                solverChanged=true;
                msg=[newline,getString(message('Sldv:SubSysExtract:MdlVarStepSolver',getfullname(oldModelH),getfullname(modelH))),newline];
            end
        end

        function status=checkPortConfiguration(blockH)
            status=true;

            blockObj=get_param(blockH,'Object');
            if~blockObj.isa('Simulink.Block')||~strcmp(blockObj.BlockType,'SubSystem')
                status=false;
                return;
            end

            ports=blockObj.Ports;
            if(~strcmpi(blockObj.TreatAsAtomicUnit,'on')&&ports(3)==0&&ports(4)==0)&&...
                ~Sldv.utils.isAtomicSubchartSubsystem(blockH)
                status=false;
                return;
            end






            ssType=Simulink.SubsystemType(blockH);
            if ssType.isInitTermOrResetSubsystem
                status=false;
                return;
            end
        end

        function uniquepath=findUniquePath(blkpath)
            suffixIdx=1;
            stopped=false;
            uniquepath=blkpath;

            while~stopped
                try
                    h=get_param(uniquepath,'Handle');
                    if~isempty(h)
                        uniquepath=[blkpath,'_',num2str(suffixIdx)];
                        suffixIdx=suffixIdx+1;
                    end
                catch Mex %#ok<NASGU>
                    stopped=true;
                end
            end
        end

        function posConsts=genPositionConstants(modelH,portInfo)
            if portInfo.numOfInports>0
                rootMdlInports=find_system(modelH,'searchdepth',1,'BlockType','Inport');
                position=get_param(rootMdlInports(1),'Position');
            elseif portInfo.numOfOutports>0
                rootMdlOutports=find_system(modelH,'searchdepth',1,'BlockType','Outport');
                position=get_param(rootMdlOutports(1),'Position');
            else
                position=[];
            end
            if~isempty(position)
                posConsts.PrtWidth=position(3)-position(1);
                posConsts.PrtHeight=position(4)-position(2);
            else
                posConsts.PrtWidth=30;
                posConsts.PrtHeight=16;
            end

            posConsts.DsWidth=4*posConsts.PrtWidth;
            posConsts.DsHeight=ceil(1.25*posConsts.PrtHeight);

            posConsts.PrtDsDelta=50;

            posConsts.Bottom=Sldv.SubSystemExtract.findBottomLocation(modelH);
        end

        function bottom=findBottomLocation(modelH)
            allBlocks=find_system(modelH,'SearchDepth',1);
            allBlocks(1)=[];
            max_y=0;
            for idx=1:length(allBlocks)
                position=get_param(allBlocks(idx),'Position');
                max_y=max(max_y,position(4));
            end
            bottom=max_y;
        end


        [status,errmsg]=checkPorts(blockH);

        [portH,datastoreH]=addDSM(modelH,dsName,idx,posConsts,isReadFrom,isWrittenTo)

    end

    methods(Access=protected,Static)
        strPorts=getPorts(blockH)


        function retVal=checkSSportInfo(busStruct,fhandle)
            retVal=false;
            if busStruct.type==1||...
                busStruct.type==2&&isfield(busStruct,'prm')
                retVal=fhandle(busStruct);
            else
                for i=1:length(busStruct.node.leafe)
                    if Sldv.SubSystemExtract.checkSSportInfo(busStruct.node.leafe{i},fhandle)
                        retVal=true;
                        break;
                    end
                end
            end
        end

        function retVal=isFcnCallPort(leafeInfo)
            retVal=strcmp(leafeInfo.prm.CompiledPortDataType,'fcn_call');
        end
    end

    methods(Access=public,Static,Hidden)
        function newFilterFileNamesStr=createCovFilterForExtactedModel(origFilterObjs,subSystemBlockH,extractedModelH,extractedModelFullPath)
            newFilterFileNames=cell(size(origFilterObjs));
            [extractedDirPath,extractedModelName]=fileparts(extractedModelFullPath);

            for fIdx=1:length(origFilterObjs)

                newFilterObj=Sldv.Filter.createFilterEditor(extractedModelH,'');

                keys=origFilterObjs(fIdx).filterState.keys;
                for kIdx=1:length(keys)
                    if Simulink.ID.isValid(keys{kIdx})


                        if slfeature('UnifiedHarnessExtract')>0
                            newSID=Simulink.harness.internal.sidmap.getExtractedModelObjectSID(keys{kIdx},subSystemBlockH,extractedModelName);
                        else
                            newSID=Simulink.ID.getSubsystemBuildSID(keys{kIdx},subSystemBlockH,extractedModelName);
                        end
                        if Simulink.ID.isValid(newSID)
                            newFilterObj.setFilter(newSID,origFilterObjs(fIdx).filterState(keys{kIdx}).Rationale);
                        end
                    else

                        newFilterObj.filterState(keys{kIdx})=origFilterObjs(fIdx).filterState(keys{kIdx});
                    end
                end

                fullPath=Sldv.utils.uniqueFileNameUsingNumbers(extractedDirPath,[extractedModelName,'_covfilter'],'.cvf');
                newFilterObj.save(fullPath);

                [~,newFilterFileNames{fIdx}]=fileparts(fullPath);
            end

            newFilterFileNamesStr=strjoin(newFilterFileNames,';');
        end


        function[ableToSaveExtractedMdl,MexFromSave]=copyCoverageAndSldvFilterFiles(origModelH,...
            sldvOpts,...
            subSystemBlockH,...
            extractedModelH,...
            extractedModelFullPath)
            ableToSaveExtractedMdl=true;
            MexFromSave=MException('','');

            if isempty(subSystemBlockH)
                return;
            end


            origFilterFileNameCV=get_param(origModelH,'CovFilter');
            if~isempty(origFilterFileNameCV)
                origFilterObj=Sldv.Filter.createFilterEditor(origModelH,origFilterFileNameCV);
                newFilterFileName=Sldv.SubSystemExtract.createCovFilterForExtactedModel(...
                origFilterObj,subSystemBlockH,extractedModelH,extractedModelFullPath);
                set_param(extractedModelH,'CovFilter',newFilterFileName);
            end


            objParams=get_param(origModelH,'ObjectParameters');
            origFilterFileNamesDV='';
            if strcmpi(sldvOpts.CovFilter,'on')
                origFilterFileNamesDV=sldvOpts.CovFilterFileName;
                if~isfield(objParams,'DVCovFilterFileName')

                    configObj=getActiveConfigSet(extractedModelH);
                    configObj.attachComponent(Sldv.ConfigComp);
                end
            elseif isfield(objParams,'DVCovFilterFileName')
                origFilterFileNamesDV=get_param(origModelH,'DVCovFilterFileName');
            end

            if~isempty(origFilterFileNamesDV)
                [readStatus,origFilterObjs,err]=sldvprivate('readFilterFiles',...
                origModelH,...
                origFilterFileNamesDV);
                if~readStatus
                    error(err);
                end

                newFilterFileNames=Sldv.SubSystemExtract.createCovFilterForExtactedModel(...
                origFilterObjs,subSystemBlockH,extractedModelH,extractedModelFullPath);
                set_param(extractedModelH,'DVCovFilterFileName',newFilterFileNames);
            end

            try
                save_system(extractedModelH,extractedModelFullPath);
            catch MexFromSave
                ableToSaveExtractedMdl=false;
            end
        end
    end
end



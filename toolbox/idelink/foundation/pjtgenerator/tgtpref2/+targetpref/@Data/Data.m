classdef Data<handle





    properties(Access='protected')
        mNeedSave=false;
        mBlock=[];
        mMemento=[];
        mMementoBackup=[];
        mTargetInfo=[];
        mRegistryInfo=[];
        mRegistry=[];
        mBoardRegistry=[];
        mAdaptorRegistry=[];
        mBoard=struct('Type','','Chip','','SubFamily','','CPUClock',0,...
        'FactoryChip',true,...
        'isRT',true,...
        'SourceFiles','',...
        'IncludePaths','',...
        'LibrariesLittleEndian','',...
        'LibrariesBigEndian','',...
        'InitFunction','',...
        'TerminateFunction','',...
        'CodeGenHookPoint','',...
        'StackSize',512,...
        'IDEOptions','');
        mMemBanks=[];
        mCache=struct('Levels',[],'Configs',[]);
        mCompilerSections=[];
        mCustomSections=[];
        mPeripherals=[];
        mDefault=[];
        mTag=[];
        mChip=[];
        mRTOS=[];
        mAssertionMessage=[];
    end


    methods(Access='protected')

        function setTag(h,tag)
            h.mTag=tag;
        end


        function initializeProcessorRegistry(h)
            targetpref.updateCustomProcessorRegistry(h.getTag());
            targetpref.initializeProcessorRegistry(h.getTag());
            h.mRegistry=linkfoundation.pjtgenerator.ProcRegistry.manageInstance('get',h.getTag());
        end


        function initializeBoardRegistry(h)
            currentTag=h.getTag();
            adaptorName=linkfoundation.util.convertTPTagToAdaptorName(currentTag);


            h.mBoardRegistry=[];

            h.getBoardRegistry();
            registryRoot=h.getAdaptorRegistry().getRegistryRoot(adaptorName);
            h.mBoardRegistry.RegistryRoot=registryRoot;
        end


        function retVal=getAdaptorRegistry(h)
            if(isa(h.mAdaptorRegistry,'linkfoundation.pjtgenerator.AdaptorRegistry')&&isvalid(h.mAdaptorRegistry))
                retVal=h.mAdaptorRegistry;
            else
                retVal=linkfoundation.pjtgenerator.AdaptorRegistry.manageInstance('get','EmbeddedIDELink');
                h.mAdaptorRegistry=retVal;
            end
        end


        function retVal=getBoardRegistry(h)
            if(isa(h.mBoardRegistry,'linkfoundation.pjtgenerator.BoardRegistry')&&isvalid(h.mBoardRegistry))
                retVal=h.mBoardRegistry;
            else
                retVal=linkfoundation.pjtgenerator.BoardRegistry.manageInstance('get',h.getTag());
                h.mBoardRegistry=retVal;
            end
        end


        function retVal=getProcRegistry(h)
            if(isa(h.mRegistry,'linkfoundation.pjtgenerator.ProcRegistry')&&isvalid(h.mRegistry))
                retVal=h.mRegistry;
            else
                retVal=linkfoundation.pjtgenerator.ProcRegistry.manageInstance('get',h.getTag());
                h.mRegistry=retVal;
            end
        end



        function initializeFromValidBlock(h,configSet)

            h.initializeProcessorRegistry();
            if~h.isBlockInLibrary(configSet)
                targetpref.Memento.updateOldStruct(configSet,h.mBlock,h.mRegistry);
                pathChanged=targetpref.updateTargetPreferencesProcPaths(configSet,h.mBlock);
                if(pathChanged)

                end
            end

            h.initMemento(configSet);
        end

        function initMemento(h,configSet)
            h.mMemento=targetpref.Memento(configSet,h.mBlock);
            h.mTargetInfo=h.mMemento.getCurData();
            if~isempty(h.mTargetInfo)&&isfield(h.mTargetInfo,'chipInfo')
                h.mTargetInfo=h.reduceTargetInfo(h.mTargetInfo);
                h.updateFromMemento();
            end
        end

        function catList=concatenateLists(h,list1,list2)


            dim=size(list2);
            if(dim(1)~=1)
                catList=[list1,list2'];
            else
                catList=[list1,list2];
            end
        end

        function assertMsg=getAssertionMessage(h)
            if(isempty(h.mAssertionMessage))
                h.mAssertionMessage=DAStudio.message('ERRORHANDLER:tgtpref:DataInconsistent');
            end
            assertMsg=h.mAssertionMessage;
        end

        function updateFromMemento(h)
            h.mBoard.Type=h.mTargetInfo.boardType;
            h.mBoard.Chip=h.mTargetInfo.chipInfo.deviceID;
            h.mBoard.CPUClock=h.mTargetInfo.chipInfo.cpuClockRateMHz;
            h.mBoard.SourceFiles=h.concatenateLists(h.mTargetInfo.chipInfo.src,h.mTargetInfo.customCode.sourceFiles);
            h.mBoard.IncludePaths=h.concatenateLists(h.mTargetInfo.chipInfo.inc,h.mTargetInfo.customCode.includePaths);
            h.mBoard.LibrariesLittleEndian=h.concatenateLists(h.mTargetInfo.chipInfo.lib_le,h.mTargetInfo.customCode.libraries);
            h.mBoard.LibrariesBigEndian=h.concatenateLists(h.mTargetInfo.chipInfo.lib_be,h.mTargetInfo.customCode.libraries);
            h.mBoard.InitFunction=h.mTargetInfo.customCode.initializeFunctions;
            h.mBoard.TerminateFunction=h.mTargetInfo.customCode.terminateFunctions;
            h.mBoard.CurrentRTOS=h.mTargetInfo.RTOS;
            h.mBoard.IDEOptions={h.mTargetInfo.boardName,h.mTargetInfo.procName};

            h.mMemBanks=h.mTargetInfo.mem.bank;

            h.mCompilerSections=h.safeCopySections(h.mTargetInfo.mem.compiler.section);
            h.mCustomSections=h.safeCopySections(h.mTargetInfo.mem.custom.section);

            h.mPeripherals=h.getPeripheralsFromMemento(h.mTargetInfo);

            try
                h.mRegistryInfo=h.getDefaultInfoForProc(h.mBoard.Chip);
            catch ex %#ok<NASGU>
                h.mRegistryInfo=[];
                return;
            end

            if(isempty(h.mRegistryInfo))

                return;
            end

            h.mBoard.SubFamily=h.mRegistryInfo.subFamily;
            h.mBoard.isRT=strcmpi(h.mRegistryInfo.realtimesupport,'on');
            h.mBoard.CodeGenHookPoint=h.mRegistryInfo.codegenhookpoint;
            h.mBoard.StackSize=h.mRegistryInfo.defaultSysStackSize;
            h.mBoard.CompilerOption=h.mRegistryInfo.compileroptions;
            h.mBoard.LinkerOption=h.mRegistryInfo.linkeroptions;
            h.mBoard.PreProc=h.mRegistryInfo.preproc;

            h.mDefault.CPUClock=h.mRegistryInfo.cpuClockRateMHz;
            if(h.mRegistryInfo.intMem.numCacheLvl<1)
                h.mDefault.Cache.Levels={};
                h.mDefault.Cache.Configs={};
            else
                h.mDefault.Cache.Levels={h.mRegistryInfo.intMem.cache(:).label};
                h.mDefault.Cache.Configs={h.mRegistryInfo.intMem.cache(:).options};
            end
            if(~isempty(h.mTargetInfo.cache))
                h.mCache.Levels={h.mTargetInfo.cache(:).levelLabel};
                h.mCache.Configs={h.mTargetInfo.cache(:).cacheSize};
            end


            h.mBoard.FactoryChip=h.mRegistryInfo.isBuiltIn;
            h.mBoard.SupportedRTOS=h.mRegistryInfo.RTOS;

            adaptorName=linkfoundation.util.convertTPTagToAdaptorName(h.getTag());

            h.mChip=h.getAdaptorRegistry().getChipObj(adaptorName,h.mBoard.Chip,h.mBoard.SubFamily,h.mBoard.CodeGenHookPoint);

            usesRTOS=false;
            for i=1:numel(h.mBoard.SupportedRTOS)
                usesRTOS=~strcmpi(h.mBoard.SupportedRTOS{i}.label,'None');
                if(usesRTOS),break;end
            end
            if usesRTOS
                h.mRTOS=h.mTargetInfo.dspbios;
                h.mRTOS.ChipCompilerSectionEndAt=numel(h.mTargetInfo.mem.compiler.section);
                h.mRTOS.codeObjectMem=h.mTargetInfo.mem.dspbios.codeObjectMem;
                h.mRTOS.dataObjectMem=h.mTargetInfo.mem.dspbios.dataObjectMem;
                h.updateCompilerSectionsForRTOS();
                if isfield(h.mTargetInfo,'OS')
                    h.mRTOS.schedulingMode=h.mTargetInfo.OS.schedulingMode;
                    h.mRTOS.baseRatePriority=h.mTargetInfo.OS.baseRatePriority;
                else
                    h.mRTOS.schedulingMode='real-time';
                    h.mRTOS.baseRatePriority=h.getDefaultRTOSRatePriority(h.mBoard.SupportedRTOS);
                end
            else
                h.mRTOS=[];
            end
        end

        function updateFromDefault(h,forProc)
            h.mRegistryInfo=h.getDefaultInfoForProc(forProc);
            assert(~isempty(h.mRegistryInfo),h.getAssertionMessage());
            h.mDefault.CPUClock=h.mRegistryInfo.cpuClockRateMHz;
            if(h.mRegistryInfo.intMem.numCacheLvl<1)
                h.mDefault.Cache.Levels={};
                h.mDefault.Cache.Configs={};
            else
                h.mDefault.Cache.Levels={h.mRegistryInfo.intMem.cache(:).label};
                h.mDefault.Cache.Configs={h.mRegistryInfo.intMem.cache(:).options};
            end

            h.mBoard.Chip=h.mRegistryInfo.deviceID;
            h.mBoard.SubFamily=h.mRegistryInfo.subFamily;
            h.mBoard.CPUClock=h.mRegistryInfo.cpuClockRateMHz;
            h.mBoard.SourceFiles=h.mRegistryInfo.src;
            h.mBoard.FactoryChip=h.mRegistryInfo.isBuiltIn;
            h.mBoard.isRT=strcmpi(h.mRegistryInfo.realtimesupport,'on');
            h.mBoard.IncludePaths=h.mRegistryInfo.inc;
            h.mBoard.LibrariesLittleEndian=h.mRegistryInfo.lib_le;
            h.mBoard.LibrariesBigEndian=h.mRegistryInfo.lib_be;
            h.mBoard.InitFunction={''};
            h.mBoard.TerminateFunction={''};
            h.mBoard.CompilerOption=h.mRegistryInfo.compileroptions;
            h.mBoard.LinkerOption=h.mRegistryInfo.linkeroptions;
            h.mBoard.PreProc=h.mRegistryInfo.preproc;
            h.mBoard.SupportedRTOS=h.mRegistryInfo.RTOS;
            h.mBoard.CurrentRTOS=h.mBoard.SupportedRTOS{1}.label;
            h.mBoard.CodeGenHookPoint=h.mRegistryInfo.codegenhookpoint;
            h.mBoard.StackSize=h.mRegistryInfo.defaultSysStackSize;

            h.mMemBanks=h.mRegistryInfo.intMem.bank;

            if(isfield(h.mRegistryInfo.intMem,'cache'))
                h.mCache.Levels={h.mRegistryInfo.intMem.cache(:).label};
                h.mCache.Configs=cell(length(h.mRegistryInfo.intMem.cache),1);
                for i=1:length(h.mRegistryInfo.intMem.cache)
                    h.mCache.Configs{i}=h.mRegistryInfo.intMem.cache(i).options{1};
                end
            else
                h.mCache=struct('Levels',[],'Configs',[]);
            end

            h.mCompilerSections=h.safeCopySections(struct('name',h.mRegistryInfo.section,...
            'description',h.mRegistryInfo.description,...
            'contents',h.mRegistryInfo.contents,...
            'placement',h.mRegistryInfo.placement,...
            'attributes',h.mRegistryInfo.attributes,...
            'commands',h.mRegistryInfo.commands));
            h.mCustomSections=[];
            h.mPeripherals=h.getPeripheralsFromDefault(h.mRegistryInfo);

            adaptorName=linkfoundation.util.convertTPTagToAdaptorName(h.getTag());

            h.mChip=h.getAdaptorRegistry().getChipObj(adaptorName,h.mBoard.Chip,h.mBoard.SubFamily,h.mBoard.CodeGenHookPoint);

            usesRTOS=false;
            for i=1:numel(h.mBoard.SupportedRTOS)
                usesRTOS=~strcmpi(h.mBoard.SupportedRTOS{i}.label,'None');
                if(usesRTOS),break;end
            end
            if usesRTOS

                h.mRTOS=h.createDefaultRTOS();
                h.mRTOS.ChipCompilerSectionEndAt=numel(h.mCompilerSections);
                banks=h.getMemoryBankNamesForRTOSAny();
                if~isempty(banks)
                    [bankSize(1:length(banks))]=banks.size;
                    [~,indx]=max(bankSize);
                    codeMemSeg=banks(indx).name;
                    dataMemSeg=banks(indx).name;
                else
                    codeMemSeg=h.getMemoryBankNamesForRTOSCode();
                    codeMemSeg=codeMemSeg{1};
                    dataMemSeg=h.getMemoryBankNamesForRTOSData();
                    dataMemSeg=dataMemSeg{1};
                end
                h.mRTOS.codeObjectMem=codeMemSeg;
                h.mRTOS.dataObjectMem=dataMemSeg;
                h.mRTOS.TSK.staticStackMemSegment=dataMemSeg;
                h.mRTOS.TSK.dynamicStackMemSegment=dataMemSeg;
                h.updateDefaultCompilerSectionsForRTOS();
                if isfield(h.mTargetInfo,'OS')
                    h.mRTOS.schedulingMode=h.mTargetInfo.OS.schedulingMode;
                    h.mRTOS.baseRatePriority=h.mTargetInfo.OS.baseRatePriority;
                else
                    h.mRTOS.schedulingMode='real-time';
                    h.mRTOS.baseRatePriority=h.getDefaultRTOSRatePriority(h.mBoard.SupportedRTOS);
                end
            else
                h.mRTOS=[];
            end






        end

        function cellarray=makeCellArrayOfCells(h,array)

            if~iscell(array)
                cellarray={array};
            else
                cellarray=array;
            end
            for i=1:numel(cellarray)
                if~iscell(cellarray{i})
                    cellarray{i}={cellarray{i}};%#ok<CCAT1>
                end
            end
        end

        function sections=safeCopySections(h,srcSections)



            if(isempty(srcSections))

                sections=struct('name',{},...
                'description',{},...
                'contents',{},...
                'placement',{},...
                'attributes',{},...
                'commands',{});
            else
                if(isfield(srcSections,'name'))
                    name={srcSections(:).name};
                else
                    name={repmat('',1,numel(srcSections))};
                end

                if(isfield(srcSections,'placement'))
                    placement=h.makeCellArrayOfCells({srcSections(:).placement});
                else
                    placement=repmat({{''}},1,numel(srcSections));
                end

                if(isfield(srcSections,'description'))
                    description={srcSections(:).description};
                else
                    description={repmat('',1,numel(srcSections))};
                end

                if(isfield(srcSections,'attributes'))
                    attributes=h.makeCellArrayOfCells({srcSections(:).attributes});
                else
                    attributes=repmat({{''}},1,numel(srcSections));
                end

                if(isfield(srcSections,'commands'))
                    commands=h.makeCellArrayOfCells({srcSections(:).commands});
                else
                    commands=repmat({{''}},1,numel(srcSections));
                end

                if(isfield(srcSections,'contents'))
                    contents={srcSections(:).contents};
                else
                    contents={repmat('',1,numel(srcSections))};
                end

                sections=struct('name',name,...
                'description',description,...
                'contents',contents,...
                'placement',placement,...
                'attributes',attributes,...
                'commands',commands);
            end
        end

        function updateCompilerSectionsForRTOS(h)
            assert(~isempty(h.mRTOS),h.getAssertionMessage());
            assert(h.mRTOS.ChipCompilerSectionEndAt>0,h.getAssertionMessage());
            if(~strcmp(h.mBoard.CurrentRTOS,'None'))
                refdspbios=h.mTargetInfo.mem.dspbios.section;
                if~isempty(refdspbios)
                    dspsections=struct('name',{refdspbios(:).name},...
                    'description',{refdspbios(:).description},...
                    'contents',{refdspbios(:).contents},...
                    'placement',{refdspbios(:).placement},...
                    'attributes',repmat({{''}},1,numel(refdspbios)),...
                    'commands',repmat({{''}},1,numel(refdspbios)));
                    h.mCompilerSections=[h.mCompilerSections,dspsections];
                else
                    assert(~strcmp(h.mBoard.CurrentRTOS,'DSP/BIOS'),h.getAssertionMessage());
                end
            end
        end

        function updateDefaultCompilerSectionsForRTOS(h)
            assert(~isempty(h.mRTOS),h.getAssertionMessage());
            assert(h.mRTOS.ChipCompilerSectionEndAt>0,h.getAssertionMessage());
            if(strcmp(h.mBoard.CurrentRTOS,'None'))
                h.mCompilerSections=h.mCompilerSections(1:h.mRTOS.ChipCompilerSectionEndAt);
            else
                refdspbios=h.createDefaultRTOSSections();
                dspsections=struct('name',{refdspbios(:).name},...
                'description',{refdspbios(:).description},...
                'contents',{refdspbios(:).contents},...
                'placement',{refdspbios(:).placement},...
                'attributes',repmat({{''}},1,numel(refdspbios)),...
                'commands',repmat({{''}},1,numel(refdspbios)));
                codebanks=h.getMemoryBankNamesForRTOSCode();
                databanks=h.getMemoryBankNamesForRTOSData();
                for i=1:numel(dspsections)
                    switch(dspsections(i).contents)
                    case 'Code',
                        dspsections(i).placement={codebanks{1}};%#ok<CCAT1>
                    case 'Data',
                        dspsections(i).placement={databanks{1}};%#ok<CCAT1>
                    end
                end
                h.mCompilerSections=[h.mCompilerSections,dspsections];
            end
        end

        function defInfo=getDefaultInfoForProc(h,forProc)
            if(h.getProcRegistry().isProcRegistered(forProc))
                defInfo=h.getProcRegistry().getProcInfo(forProc);
            elseif(h.getProcRegistry().isProcRegistered(['C',forProc]))
                defInfo=h.getProcRegistry().getProcInfo(['C',forProc]);
            else
                defInfo=[];
            end
        end

        function newSection=createEmptySection(h)%#ok<MANU>
            newSection=struct('name','',...
            'description','',...
            'contents','',...
            'placement',{''},...
            'attributes',{''},...
            'commands',{''});
        end


        function fieldreqd=getFieldNameRequiredForPeripherals(h,subfamily)
            switch(subfamily)
            case '281x'
                fieldreqd='c281x';
            case{'280x','2804x'}
                fieldreqd='c280x';
            case '2833x'
                fieldreqd='c2833x';
            case '2802x'
                fieldreqd='c2802x';
            case '2803x'
                fieldreqd='c2803x';
            case '2806x'
                fieldreqd='c2806x';
            case '2834x'
                fieldreqd='c2834x';
            otherwise
                fieldreqd='UNKNOWNCHIPSUBFAMILY';
            end
        end

        function peripherals=getPeripheralsFromMemento(h,tgtInfo)
            peripherals=[];
            fieldreqd=h.getFieldNameRequiredForPeripherals(tgtInfo.chipInfo.subFamily);
            if~isequal(fieldreqd,'UNKNOWNCHIPSUBFAMILY')
                peripherals.value=tgtInfo.peripherals.(fieldreqd);
            end
        end

        function peripherals=getPeripheralsFromDefault(h,defInfo)



            [peripherals.value,peripherals.properties]=...
            h.createDefaultPeripherals(defInfo.codegenhookpoint,defInfo.subFamily);
        end

        function name=makeUniqueSectionName(h)
            namelist=[h.getAllSectionNames(),'newsection'];
            stripped=strrep(namelist,'.','');
            names=genvarname(stripped);
            name=['.',names{end}];
        end

        function name=makeUniqueMemoryBankName(h)
            names=genvarname({h.mMemBanks(:).name,'newbank'});
            name=names{end};
        end

        function newAddr=findNonOverlappingAddr(h,suggAddr,suggSize)%#ok<INUSD>


            endAddr=[h.mMemBanks(:).addr]+[h.mMemBanks(:).size];
            sortedEndAddr=sort(endAddr);
            if(suggAddr>=sortedEndAddr(end))
                newAddr=suggAddr;
            else
                newAddr=sortedEndAddr(end);
            end
        end


        function heap=createDefaultHeapForNewBank(h)%#ok<MANU>
            heap=struct('createHeap',0,...
            'heapSize',256,...
            'defineLabel',0,...
            'heapLabel','segment_name');
        end

    end


    methods(Access='public')
        function h=Data(varargin)
            if(nargin<2)

                return;
            end

            configSet=varargin{1};
            h.mBlock=varargin{2};

            if isequal(nargin,3)
                h.setTag(varargin{3});
            elseif~isempty(h.mBlock)
                h.setTag(get_param(h.mBlock,'Tag'));
            elseif configSet.isValidParam('TargetHardwareResources')&&...
                ~isempty(get_param(configSet,'TargetHardwareResources'))
                tgtHWData=get_param(configSet,'TargetHardwareResources');
                h.setTag(tgtHWData.tag);
            else
                assert(false,'Data constructor error.');
            end



            h.mAdaptorRegistry=[];
            h.getAdaptorRegistry();

            if(h.isTemplate())
                return;
            end

            if~h.isBlockInLibrary(configSet)




                res=strfind(get_param(h.mBlock,'MaskType'),'Target Preferences');
                if~isempty(res)&&targetpref.isTPBlockOlderThanR2007a(h.mBlock)
                    return;
                end


                tagchanged=targetpref.updateTargetPreferencesTag(h.mBlock);
                if(tagchanged)

                    h.setTag(get_param(h.mBlock,'tag'));
                end

                versionUpdate=h.updateDataToLatestVersion(configSet);
                if(versionUpdate)

                end
            end










            h.initializeBoardRegistry();
            h.initializeFromValidBlock(configSet);
        end

        function updated=updateDataToLatestVersion(h,cs)
            updated=false;
            curVersion=getTgtPrefVersion();
            storedVersion=TgtPref_version(h.mBlock,'get',cs);
            if(~strcmpi(curVersion,storedVersion))
                TgtPref_version(h.mBlock,['update to ',curVersion],cs);
                updated=true;
            end
        end


        function ret=needSave(h)
            ret=h.mNeedSave;
        end

        function ret=isBlockInLibrary(h,configSet)%#ok<*INUSL>
            ret=isequal(get_param(configSet.getModel(),'BlockDiagramType'),'library');
        end



        function chipNameList=getChipNameList(h)
            chipNameList={};
            if isempty(h.getProcRegistry())

                return;
            end
            allNames=h.getProcRegistry().getProcNames;
            currentBoard=h.getBoardRegistry().getBoardInfoByName(h.mBoard.Type);
            for index=1:length(allNames)

                procInfo=h.getProcRegistry().getReducedProcInfo(allNames{index});
                if(currentBoard.isProcessorSupported(procInfo))
                    chipNameList{end+1}=procInfo.deviceID;%#ok
                end
            end
        end

        function ret=getCodeGenHookPoint(h)
            ret=h.mBoard.CodeGenHookPoint;
        end


        function adaptorNameList=getAdaptorNameList(h)
            adaptorNameList=h.getAdaptorRegistry().getAdaptorNames();
        end



        function boardNameList=getBoardTypeList(h)
            boardNameList=h.getBoardRegistry().BoardDisplayNames;
        end


        function tag=getTag(h)
            tag=h.mTag;
        end


        function istemplate=isTemplate(h)
            istemplate=strcmpi(h.mTag,'tgtpref');
        end


        function boardType=getBoardType(h)
            boardType=h.mBoard.Type;
        end

        function displayName=getBoardTypeDisplayName(h)
            curBoard=h.getBoardRegistry().getBoardInfoByName(h.mBoard.Type);
            displayName=curBoard.DisplayName;
        end

        function chipName=getCurChipName(h)
            chipName=h.mBoard.Chip;
        end

        function adaptorName=getCurAdaptorName(h)
            adaptorName=linkfoundation.util.convertTPTagToAdaptorName(h.mTag);
        end

        function subFamily=getCurChipSubFamily(h)
            subFamily=h.mBoard.SubFamily;
        end

        function cpuClock=getClockSpeedInMHZ(h)
            cpuClock=h.mBoard.CPUClock;
        end

        function curOS=getCurOS(h)
            curOS=h.mBoard.CurrentRTOS;
        end

        function listOS=getSupportedOSList(h)
            listOS=cell(length(h.mBoard.SupportedRTOS),1);
            for i=1:length(h.mBoard.SupportedRTOS)
                listOS{i}=h.mBoard.SupportedRTOS{i}.label;
            end
        end

        function num=getNumSupportOSConfig(h)
            num=length(h.mBoard.SupportedRTOS);
        end

        function ret=isFactoryChip(h)
            ret=h.mBoard.FactoryChip;
        end

        function isrt=isRealTime(h)
            isrt=h.mBoard.isRT;
        end

        function periphs=hasPeripherals(h)
            periphs=~isempty(h.mPeripherals)&&~isempty(h.mPeripherals.value);
        end

        function boardSourceFiles=getBoardSourceFiles(h)
            boardSourceFiles=sprintf('%s\n',h.mBoard.SourceFiles{:});
        end

        function boardLst=getListOfBoardSourceFiles(h)
            boardLst=h.mBoard.SourceFiles;
        end

        function boardIncludePaths=getIncludePaths(h)
            boardIncludePaths=sprintf('%s\n',h.mBoard.IncludePaths{:});
        end

        function boardIncludePaths=getListOfIncludePaths(h)
            boardIncludePaths=h.mBoard.IncludePaths;
        end

        function boardLibraries=getLibrariesLittleEndian(h)
            if(h.isChipSupportLittleEndian())
                boardLibraries=sprintf('%s\n',h.mBoard.LibrariesLittleEndian{:});
            else
                boardLibraries='';
            end
        end

        function boardLibraries=getListOfLibrariesLittleEndian(h)
            if(h.isChipSupportLittleEndian())
                boardLibraries=h.mBoard.LibrariesLittleEndian;
            else
                boardLibraries={};
            end
        end

        function boardLibraries=getLibrariesBigEndian(h)
            if(h.isChipSupportBigEndian())
                boardLibraries=sprintf('%s\n',h.mBoard.LibrariesBigEndian{:});
            else
                boardLibraries='';
            end
        end

        function boardLibraries=getListOfLibrariesBigEndian(h)
            if(h.isChipSupportBigEndian())
                boardLibraries=h.mBoard.LibrariesBigEndian;
            else
                boardLibraries={};
            end
        end

        function boardLibraries=getAllLibraries(h)
            if(h.isChipSupportBothEndian())
                boardLibraries=sprintf('%s\n--------------------\n%s',...
                h.getLibrariesLittleEndian(),...
                h.getLibrariesBigEndian());
            elseif(h.isChipSupportLittleEndian())
                boardLibraries=h.getLibrariesLittleEndian();
            else
                boardLibraries=h.getLibrariesBigEndian();
            end
        end

        function isle=isChipSupportLittleEndian(h)
            isle=h.getChip().supportsLittleEndian();
        end

        function isbe=isChipSupportBigEndian(h)
            isbe=h.getChip().supportsBigEndian();
        end

        function isboth=isChipSupportBothEndian(h)
            isboth=h.isChipSupportLittleEndian()&&h.isChipSupportBigEndian();
        end

        function boardInitFunction=getInitFunction(h)
            boardInitFunction=sprintf('%s\n',h.mBoard.InitFunction{:});
        end

        function boardTerminateFunction=getTerminateFunction(h)
            boardTerminateFunction=sprintf('%s\n',h.mBoard.TerminateFunction{:});
        end

        function compilerOption=getCompilerOption(h)
            compilerOption=sprintf('%s\n',h.mBoard.CompilerOption{:});
        end

        function compilerOption=getListOfCompilerOption(h)
            compilerOption=h.mBoard.CompilerOption;
        end

        function linkerOption=getLinkerOption(h)
            linkerOption=sprintf('%s\n',h.mBoard.LinkerOption{:});
        end

        function compilerOption=getListOfLinkerOption(h)
            compilerOption=h.mBoard.LinkerOption;
        end

        function preproc=getPreProc(h)
            preproc=sprintf('%s\n',h.mBoard.PreProc{:});
        end

        function preproc=getListOfPreProc(h)
            preproc=h.mBoard.PreProc;
        end


        function compilerOption=getDefaultCompilerOption(h,forProc)
            defInfo=h.getDefaultInfoForProc(forProc);
            compilerOption=defInfo.compileroptions;
        end

        function linkerOption=getDefaultLinkerOption(h,forProc)
            defInfo=h.getDefaultInfoForProc(forProc);
            linkerOption=defInfo.linkeroptions;
        end


        function numBanks=getNumMemoryBanks(h)
            numBanks=length(h.mMemBanks);
        end

        function numBankParams=getNumMemoryBankParameters(h)
            numBankParams=length(h.getMemoryBankParameters());
        end

        function bankParams=getMemoryBankParameters(h)%#ok<MANU>
            bankParams={'Name','Address','Length','Contents'};
        end

        function bankContents=getMemoryBankContentsChoices(h)%#ok<MANU>
            bankContents={'Rsvd','Code','Data','Code & Data'};
        end

        function bankIdx=getMemoryBanksForContent(h,content)
            matchIdx=zeros(h.getNumMemoryBanks(),1);
            for i=1:h.getNumMemoryBanks()
                matchIdx(i)=strcmpi(h.mMemBanks(i).contents,content)||...
                strcmpi(h.mMemBanks(i).contents,'Code & Data')||...
                strcmpi(content,'Any');
            end
            bankIdx=find(matchIdx==true);
        end

        function bankNames=getAllMemoryBankNames(h)
            bankNames={h.mMemBanks(:).name};
        end

        function bankName=getMemoryBankName(h,idx)
            bankName=h.mMemBanks(idx).name;
        end

        function addr=getMemoryBankAddr(h,idx)
            addr=h.mMemBanks(idx).addr;
        end

        function addr=getMemoryBankLength(h,idx)
            addr=h.mMemBanks(idx).size;
        end

        function ret=isMemoryBankContentChangeable(h,idx)
            ret=~h.mMemBanks(idx).iscontentsfixed;
        end

        function ret=getMemoryBankContents(h,idx)
            ret=h.mMemBanks(idx).contents;
        end

        function bankNames=getMemoryBankNamesForSection(h,secIdx)
            content=h.getMemCompilerSectionContents(secIdx);
            idx=h.getMemoryBanksForContent(content);
            bankNames={h.mMemBanks(idx).name};




        end

        function bankNames=getMemoryBankNamesForCustomSection(h,secIdx)
            content=h.getMemCustomSectionContents(secIdx);
            idx=h.getMemoryBanksForContent(content);
            bankNames={h.mMemBanks(idx).name};




        end

        function bankEntry=getMemoryBankInfo(h,idx)
            bankEntry.Name=h.mMemBanks(idx).name;
            bankEntry.Address=h.mMemBanks(idx).addr;
            bankEntry.Length=h.mMemBanks(idx).size;
            bankEntry.Contents=h.mMemBanks(idx).contents;
            bankEntry.ContentsChangeable=~h.mMemBanks(idx).iscontentsfixed;
        end

        function numCacheEntries=getNumCacheEntries(h)
            numCacheEntries=length(h.mDefault.Cache.Levels);
        end

        function cacheEntries=getDefaultCacheLevelEntries(h)
            cacheEntries=h.mDefault.Cache.Levels;
        end

        function cacheConfigs=getDefaultCacheConfigEntries(h)
            cacheConfigs=h.mDefault.Cache.Configs;
        end

        function cacheConfigs=getDefaultCacheConfigEntriesForLevel(h,idx)
            cacheConfigs=h.mDefault.Cache.Configs{idx};
        end

        function cacheConfigs=getCurCacheConfigEntries(h)
            cacheConfigs=h.mCache.Configs;
        end

        function isRemove=isMemoryBankRemovable(h,memBankIdx)
            isRemove=h.mMemBanks(memBankIdx).isremovable==1;
        end


        function contents=getCustomSectionContentsChoices(h)%#ok<MANU>
            contents={'Any','Code','Data'};
        end

        function sections=getMemCompilerSectionNames(h)
            if(~isempty(h.mCompilerSections))
                sections={h.mCompilerSections(:).name};
            else
                sections={};
            end
        end

        function sections=getAllSectionNames(h)

            sections=[h.getMemCompilerSectionNames(),h.getMemCustomSectionNames()];
        end

        function ret=getMemCompilerSectionName(h,idx)
            ret=h.mCompilerSections(idx).name;
        end

        function ret=getMemCompilerSectionDescription(h,idx)

            ret=h.mCompilerSections(idx).description;
        end

        function ret=getMemCompilerSectionAttributes(h,idx)
            ret=h.mCompilerSections(idx).attributes;
        end

        function ret=getMemCompilerSectionCommands(h,idx)
            ret=h.mCompilerSections(idx).commands;
        end

        function ret=getMemCompilerSectionContents(h,idx)
            ret=h.mCompilerSections(idx).contents;
        end

        function ret=getMemCompilerSectionPlacement(h,idx)
            ret=h.mCompilerSections(idx).placement;
        end

        function sections=getMemCustomSectionNames(h)
            if(~isempty(h.mCustomSections))
                sections={h.mCustomSections(:).name};
            else
                sections={};
            end
        end

        function ret=getNumMemCustomSections(h)
            ret=length(h.mCustomSections);
        end

        function ret=getMemCustomSectionName(h,idx)
            ret=h.mCustomSections(idx).name;
        end

        function ret=getMemCustomSectionPlacement(h,idx)
            ret=h.mCustomSections(idx).placement;
        end

        function ret=getMemCustomSectionDescription(h,idx)
            ret=h.mCustomSections(idx).description;
        end

        function ret=getMemCustomSectionAttributes(h,idx)
            ret=h.mCustomSections(idx).attributes;
        end

        function ret=getMemCustomSectionCommands(h,idx)
            if(isfield(h.mCustomSections(idx),'commands'))
                ret=h.mCustomSections(idx).commands;
            else
                ret='';
            end
        end

        function ret=getMemCustomSectionContents(h,idx)
            ret=h.mCustomSections(idx).contents;
        end

        function stackSize=getStackSize(h)
            stackSize=h.mBoard.StackSize;
        end

        function idx=getCustomSectionIdx(h,sectionName)
            listNames=h.getMemCustomSectionNames();
            idx=strmatch(sectionName,listNames,'exact');
        end


        function peripherals=getPeripherals(h)
            peripherals=h.mPeripherals;
            cgHook=h.mBoard.CodeGenHookPoint;
            subFamily=h.mBoard.SubFamily;
            [~,properties]=createDefaultPeripherals(h,cgHook,subFamily);
            h.mPeripherals.properties=properties;
            peripherals.properties=properties;
        end

        function peripheralNames=getPeripheralNames(h)
            assert(hasPeripherals(h),h.getAssertionMessage());
            cgHook=h.mBoard.CodeGenHookPoint;
            subFamily=h.mBoard.SubFamily;
            [~,properties]=createDefaultPeripherals(h,cgHook,subFamily);
            peripheralNames=fields(properties.prompt)';
        end

        function[properties,prompts,options,curvalues]=getPeripheralDetail(h,forPeriph)
            assert(isfield(h.mPeripherals.properties.prompt,forPeriph),h.getAssertionMessage());
            fieldsForPeriph=fields(h.mPeripherals.properties.prompt.(forPeriph));
            properties=cell(1,length(fieldsForPeriph));
            prompts=cell(1,length(fieldsForPeriph));
            options=cell(1,length(fieldsForPeriph));
            curvalues=cell(1,length(fieldsForPeriph));
            for i=1:length(fieldsForPeriph)
                properties{i}=fieldsForPeriph{i};
                prompts{i}=h.mPeripherals.properties.prompt.(forPeriph).(fieldsForPeriph{i});
                options{i}=h.mPeripherals.properties.fields.(forPeriph).(fieldsForPeriph{i});
                curvalues{i}=h.mPeripherals.value.(forPeriph).(fieldsForPeriph{i});
            end
        end


        function numBankParams=getNumRTOSHeapParameters(h)
            numBankParams=length(h.getRTOSHeapParameters());
        end

        function bankParams=getRTOSHeapParameters(h)%#ok<MANU>
            bankParams={'Create','Label','Size'};
        end

        function idx=getMemoryBanksIdxForRTOS(h,bankName)
            idx=strmatch(bankName,{h.mMemBanks(:).name},'exact');
            assert(~isempty(idx)&&idx>0&&idx<=numel(h.mMemBanks),h.getAssertionMessage());
        end

        function bankNames=getMemoryBankNamesForRTOSData(h)
            idx=h.getMemoryBanksForContent('Data');
            bankNames={h.mMemBanks(idx).name};
        end

        function banks=getMemoryBankNamesForRTOSAny(h)
            idx=h.getMemoryBanksForContent('Code & Data');
            if~isempty(idx)
                banks=struct('name',[],'size',[]);
                len=numel(idx);
                [banks(1:len).name]=deal(h.mMemBanks(idx).name);
                [banks(1:len).size]=deal(h.mMemBanks(idx).size);
            else
                banks=[];
            end
        end

        function ret=getRTOSHeapCreate(h,bankName)
            idx=h.getMemoryBanksIdxForRTOS(bankName);
            ret=h.mMemBanks(idx).heap.createHeap;
        end

        function ret=getRTOSHeapLabelFor(h,bankName)
            idx=h.getMemoryBanksIdxForRTOS(bankName);
            if(h.mMemBanks(idx).heap.defineLabel)
                ret=h.mMemBanks(idx).heap.heapLabel;
            else
                ret='';
            end
        end

        function ret=getRTOSHeapSizeFor(h,bankName)
            idx=h.getMemoryBanksIdxForRTOS(bankName);
            ret=h.mMemBanks(idx).heap.heapSize;
        end

        function bankNames=getMemoryBankNamesForRTOSCode(h)
            idx=h.getMemoryBanksForContent('Code');
            bankNames={h.mMemBanks(idx).name};
        end

        function bankNames=getMemoryBankNamesForHeap(h,idx)%#ok<INUSD>
            bankNames=h.getMemoryBankNamesForRTOSData();
        end

        function heapLabels=getAllRTOSHeapLabels(h)
            heapLabels={};
            for i=1:numel(h.mMemBanks)
                if(h.mMemBanks(i).heap.defineLabel)
                    heapLabels{end+1}=h.mMemBanks(i).heap.heapLabel;%#ok<AGROW>
                end
            end
        end

        function num=getNumRTOSHeaps(h)
            num=0;
            for i=1:numel(h.mMemBanks)
                if(h.mMemBanks(i).heap.createHeap)
                    num=num+1;
                end
            end
        end

        function bankNames=getMemoryBankNamesForRTOSDynamicStack(h)
            bankNames={};
            for i=1:numel(h.mMemBanks)
                if(h.mMemBanks(i).heap.createHeap)
                    bankNames{end+1}=h.mMemBanks(i).name;%#ok<AGROW>
                end
            end
        end

        function bankName=getRTOSDataObjectPlacement(h)
            bankName=h.mRTOS.dataObjectMem;
        end

        function bankName=getRTOSCodeObjectPlacement(h)
            bankName=h.mRTOS.codeObjectMem;
        end

        function stackSize=getRTOSStackSize(h)
            stackSize=h.mRTOS.TSK.stackSize;
        end

        function bankName=getRTOSStaticStackPlacement(h)
            bankName=h.mRTOS.TSK.staticStackMemSegment;
        end

        function bankName=getRTOSDynamicStackPlacement(h)
            bankName=h.mRTOS.TSK.dynamicStackMemSegment;
        end

        function listMode=getOSSchedulingModes(h)%#ok<MANU>
            listMode={'real-time','free-running'};
        end

        function curMode=getCurOSSchedulingMode(h)
            assert(~isempty(h.mRTOS),h.getAssertionMessage());
            curMode=h.mRTOS.schedulingMode;
        end

        function curPriority=getOSBaseRatePriority(h)
            assert(~isempty(h.mRTOS),h.getAssertionMessage());
            curPriority=h.mRTOS.baseRatePriority;
        end


        function options=getIDEOptions(h)
            options=h.mBoard.IDEOptions;
        end
    end




    methods(Access='public',Hidden)
        function hChip=getChip(h)
            hChip=h.mChip;
        end

        function nameList=getFactoryBoardList(h)
            nameList=h.mChip.getFactoryBoardNames();
        end



        function ret=setIDE(h,configSet,ideName)
            ret=false;
            tag=linkfoundation.util.convertAdaptorNameToTPTag(ideName);
            if(isempty(tag))
                return;
            end

            fcnHandle_getIDETag=h.getAdaptorRegistry().getIDETag(ideName);
            board=h.getBoardRegistry().getBoardInfoByName(h.mBoard.Type);
            assert(isa(board,'linkfoundation.pjtgenerator.BoardInfo'),...
            DAStudio.message('ERRORHANDLER:tgtpref:InvalidBoardInfo'));
            validTag=fcnHandle_getIDETag(tag,board.DSPBIOSDefined);
            ret=h.onTagChange(configSet,validTag,h.mBoard.Type);
        end

        function ret=onTagChange(h,configSet,tag,boardName)
            ret=false;

            currentTag=h.mTag;
            h.setTag(tag);
            h.initializeBoardRegistry();
            if(3>nargin)
                defaultBoard=h.getBoardRegistry().DefaultBoard;
            else
                defaultBoard=h.getBoardRegistry().getBoardInfoByName(boardName);
                if(isempty(defaultBoard))
                    defaultBoard=h.getBoardRegistry().DefaultBoard;
                end
            end

            if(~h.onUDChange(configSet,defaultBoard.UDFileName))

                h.mTag=currentTag;
                h.initializeBoardRegistry();
                return;
            end
            if~isempty(h.mBlock)
                set_param(h.mBlock,'tag',h.mTag);
            end
            h.initializeFromValidBlock(configSet);
            ret=true;
        end

        function ret=onUDChange(h,configSet,udFileName)
            ret=false;




            file=linkfoundation.util.File(fullfile(h.getBoardRegistry().UDRepository,udFileName));
            if(~file.exists())
                return;
            end
            try
                newTargetInfo=load(file.FullPathName);
            catch ex %#ok
                return;
            end
            newTargetInfo=newTargetInfo.ud;


            if(isempty(newTargetInfo.boardType))
                newTargetInfo.boardType=h.mBoard.Type;
            end

            newTargetInfo.tag=h.mTag;
            newTargetInfo=h.reduceTargetInfo(newTargetInfo);

            h.mNeedSave=true;
            h.mMemento.saveData(configSet,newTargetInfo);

            if~isempty(h.mBlock)
                set_param(h.mBlock,'Tag',newTargetInfo.tag);
            end

            if h.updateDataToLatestVersion(configSet);
                h.mMemento.saveData(configSet,get_param(configSet,'TargetHardwareResources'));
            end

            h.mNeedSave=false;
            ret=true;
        end


        function[userDataChange,tagChange]=setBoardType(h,configSet,boardType)
            userDataChange=false;
            tagChange=false;


            curBoard=h.getBoardRegistry().getBoardInfoByName(h.mBoard.Type);
            board=h.getBoardRegistry().getBoardInfoByDisplayName(boardType);
            if(curBoard==board)


                return;
            end
            h.mNeedSave=true;
            h.mBoard.Type=board.Name;

            if(xor(board.DSPBIOSDefined,curBoard.DSPBIOSDefined))



                ideName=linkfoundation.util.convertTPTagToAdaptorName(h.mTag);
                fcnHandle_getIDETag=h.getAdaptorRegistry().getIDETag(ideName);
                validTag=fcnHandle_getIDETag(h.mTag,board.DSPBIOSDefined);
                if(~h.onTagChange(configSet,validTag,board.Name))
                    return;
                end
                userDataChange=true;
                tagChange=true;
            else
                if(~h.onUDChange(configSet,board.UDFileName))
                    return;
                end
                h.initializeFromValidBlock(configSet);
                userDataChange=true;
            end
        end

        function setProcessor(h,newProcessor)
            h.mNeedSave=true;
            h.updateFromDefault(newProcessor);
        end

        function setClockSpeed(h,value)
            h.mNeedSave=true;
            h.mBoard.CPUClock=value;
        end

        function setCurOS(h,value)
            h.mNeedSave=true;
            h.mBoard.CurrentRTOS=value;
            h.updateDefaultCompilerSectionsForRTOS();

            h.setOSBaseRatePriority(h.getDefaultRTOSRatePriority(h.mBoard.SupportedRTOS));
        end

        function setBoardSourceFiles(h,value)
            h.mNeedSave=true;
            h.mBoard.SourceFiles=value;
        end

        function setIncludePaths(h,value)
            h.mNeedSave=true;
            h.mBoard.IncludePaths=value;
        end

        function setLibrariesLittleEndian(h,value)
            h.mNeedSave=true;
            h.mBoard.LibrariesLittleEndian=value;
        end

        function setLibrariesBigEndian(h,value)
            h.mNeedSave=true;
            h.mBoard.LibrariesBigEndian=value;
        end

        function setInitFunction(h,value)
            h.mNeedSave=true;
            h.mBoard.InitFunction=value;
        end

        function setTerminateFunction(h,value)
            h.mNeedSave=true;
            h.mBoard.TerminateFunction=value;
        end

        function setIDEOption(h,idx,value)
            h.mBoard.IDEOptions{idx}=value;
        end


        function setMemoryBankName(h,configSet,idx,val)
            h.mNeedSave=true;
            h.mMemBanks(idx).name=val;
            h.save(configSet);
        end

        function setMemoryBankAddr(h,configSet,idx,val)
            h.mNeedSave=true;
            h.mMemBanks(idx).addr=val;
            h.save(configSet);
        end

        function setMemoryBankLength(h,configSet,idx,val)
            h.mNeedSave=true;
            h.mMemBanks(idx).size=val;
            h.save(configSet);
        end

        function setMemoryBankContents(h,configSet,idx,val)
            h.mNeedSave=true;
            h.mMemBanks(idx).contents=val;
            h.save(configSet);
        end

        function setCurCacheConfig(h,configSet,lvlIdx,val)
            h.mNeedSave=true;
            h.mCache.Configs{lvlIdx}=val;
            h.save(configSet);
        end

        function ret=WillHaveRequiredBanks(h,memIdx,val)
            contents={h.mMemBanks(:).contents};
            contents{memIdx}=val;
            bankContents=h.getMemoryBankContentsChoices();
            code=strmatch(bankContents{2},contents,'exact');
            data=strmatch(bankContents{3},contents,'exact');
            codeAndData=strmatch(bankContents{4},contents,'exact');
            ret=((numel(code)>0)&&(numel(data)>0))||...
            (numel(codeAndData)>0);
        end


        function addedIdx=addMemoryBank(h,useMemIdx)
            h.mNeedSave=true;
            newBank=h.mMemBanks(useMemIdx);
            newBank.isremovable=true;
            newBank.iscontentsfixed=false;

            newBank.addr=h.findNonOverlappingAddr(newBank.addr+newBank.size,newBank.size);
            newBank.name=h.makeUniqueMemoryBankName();
            newBank.heap=h.createDefaultHeapForNewBank();
            h.mMemBanks(end+1)=newBank;
            addedIdx=length(h.mMemBanks);
        end

        function prevIdx=deleteMemoryBank(h,idx)
            h.mNeedSave=true;
            h.mMemBanks(idx)=[];
            if(length(h.mMemBanks)>idx)
                prevIdx=idx;
            else
                prevIdx=length(h.mMemBanks);
            end
        end

        function newPlacement=getNextBestPlacement(h,curPlacement,avoid,forContent)
            found=strmatch(avoid,curPlacement,'exact');
            newPlacement=curPlacement;
            if(numel(found)>0)
                newPlacement(found)=[];
                if(numel(newPlacement)<1)
                    bankIdx=h.getMemoryBanksForContent(forContent);
                    newPlacement={h.mMemBanks(bankIdx(1)).name};
                end
            end
            assert(iscell(newPlacement),h.getAssertionMessage());
        end

        function moveAllSectionsAwayFrom(h,memIdx)

            contents={h.mMemBanks(:).contents};
            bankContents=h.getMemoryBankContentsChoices();
            code=strmatch(bankContents{2},contents,'exact');
            data=strmatch(bankContents{3},contents,'exact');
            codeAndData=strmatch(bankContents{4},contents,'exact');
            assert(((numel(code)>0)&&(numel(data)>0))||...
            (numel(codeAndData)>0),h.getAssertionMessage());


            avoid=h.mMemBanks(memIdx).name;
            for i=1:length(h.mCompilerSections)
                curPlacement=h.mCompilerSections(i).placement;
                h.mCompilerSections(i).placement=h.getNextBestPlacement(...
                curPlacement,avoid,h.mCompilerSections(i).contents);
            end

            for i=1:length(h.mCustomSections)
                curPlacement=h.mCustomSections(i).placement;
                h.mCustomSections(i).placement=h.getNextBestPlacement(...
                curPlacement,avoid,h.mCustomSections(i).contents);
            end

            h.moveAllRTOSObjectsAwayFrom(memIdx);
        end


        function setMemCompilerSectionPlacement(h,idx,placement)
            h.mNeedSave=true;
            assert(iscell(placement),h.getAssertionMessage());
            h.mCompilerSections(idx).placement=placement;
        end

        function setMemCompilerSectionAttributes(h,idx,attributes)
            h.mNeedSave=true;
            assert(iscell(attributes),h.getAssertionMessage());
            h.mCompilerSections(idx).attributes=attributes;
        end

        function setMemCompilerSectionCommands(h,idx,commands)
            h.mNeedSave=true;
            assert(iscell(commands),h.getAssertionMessage());
            h.mCompilerSections(idx).commands=commands;
        end

        function addedName=addCustomSection(h,useSection)
            h.mNeedSave=true;
            if(~isempty(useSection))
                useId=h.getCustomSectionIdx(useSection);
                newSection=h.mCustomSections(useId);
            else
                newSection=h.createEmptySection();
                choices=h.getCustomSectionContentsChoices();
                newSection.contents=choices{1};
                bankIdx=h.getMemoryBanksForContent(choices{1});
                newSection.placement={h.mMemBanks(bankIdx(1)).name};
            end
            newSection.name=h.makeUniqueSectionName();
            if(isempty(h.mCustomSections))
                h.mCustomSections=newSection;
            else
                h.mCustomSections(end+1)=newSection;
            end
            addedName=newSection.name;
        end

        function deleteCustomSection(h,sectionName)
            h.mNeedSave=true;
            idx=h.getCustomSectionIdx(sectionName);
            assert(~isempty(idx)&&idx>0&&idx<=length(h.mCustomSections),h.getAssertionMessage());
            h.mCustomSections(idx)=[];
        end

        function setCustomSectionName(h,idx,sectionName)
            h.mNeedSave=true;
            assert(~iscell(sectionName),h.getAssertionMessage());
            h.mCustomSections(idx).name=sectionName;
        end

        function setMemCustomSectionPlacement(h,idx,placement)
            h.mNeedSave=true;
            assert(iscell(placement),h.getAssertionMessage());
            h.mCustomSections(idx).placement=placement;
        end

        function setMemCustomSectionContents(h,idx,contents)
            h.mNeedSave=true;
            assert(~iscell(contents),h.getAssertionMessage());
            h.mCustomSections(idx).contents=contents;
        end

        function setMemCustomSectionAttributes(h,idx,attributes)
            h.mNeedSave=true;
            assert(iscell(attributes),h.getAssertionMessage());
            h.mCustomSections(idx).attributes=attributes;
        end

        function setMemCustomSectionCommands(h,idx,commands)
            h.mNeedSave=true;
            assert(iscell(commands),h.getAssertionMessage());
            h.mCustomSections(idx).commands=commands;
        end


        function setPeripherals(h,newPeripherals)
            h.mNeedSave=true;
            h.mPeripherals=newPeripherals;
        end


        function moveAllRTOSObjectsAwayFrom(h,memIdx)
            avoid=h.mMemBanks(memIdx).name;
            bankNames=h.getMemoryBankNamesForRTOSData();
            found=strmatch(avoid,bankNames,'exact');
            bankNames(found)=[];
            assert(numel(bankNames)>0,h.getAssertionMessage());
            if(~isempty(h.mRTOS))
                if(strcmp(h.mRTOS.codeObjectMem,avoid))
                    h.mRTOS.codeObjectMem=bankNames{1};
                end
                if(strcmp(h.mRTOS.dataObjectMem,avoid))
                    h.mRTOS.dataObjectMem=bankNames{1};
                end
                if(strcmp(h.mRTOS.TSK.staticStackMemSegment,avoid))
                    h.mRTOS.TSK.staticStackMemSegment=bankNames{1};
                end
                if(strcmp(h.mRTOS.TSK.dynamicStackMemSegment,avoid))
                    h.mRTOS.TSK.dynamicStackMemSegment=bankNames{1};
                end
            end
        end

        function setRTOSCreateHeap(h,bankName,val)
            h.mNeedSave=true;
            idx=h.getMemoryBanksIdxForRTOS(bankName);
            h.mMemBanks(idx).heap.createHeap=double(val);
        end

        function setRTOSHeapSizeFor(h,bankName,val)
            h.mNeedSave=true;
            idx=h.getMemoryBanksIdxForRTOS(bankName);
            h.mMemBanks(idx).heap.heapSize=val;
        end

        function setRTOSHeapLabelFor(h,bankName,val)
            h.mNeedSave=true;
            idx=h.getMemoryBanksIdxForRTOS(bankName);
            h.mMemBanks(idx).heap.defineLabel=double(~isempty(val));
            h.mMemBanks(idx).heap.heapLabel=val;
        end

        function setRTOSCodePlacement(h,bankName)
            h.mNeedSave=true;
            h.mRTOS.codeObjectMem=bankName;
        end

        function setRTOSDataPlacement(h,bankName)
            h.mNeedSave=true;
            h.mRTOS.dataObjectMem=bankName;
        end

        function setRTOSStackSize(h,value)
            h.mNeedSave=true;
            h.mRTOS.TSK.stackSize=value;
        end

        function setRTOSStaticTasks(h,bankName)
            h.mNeedSave=true;
            h.mRTOS.TSK.staticStackMemSegment=bankName;
        end

        function setRTOSDynamicTasks(h,bankName)
            h.mNeedSave=true;
            h.mRTOS.TSK.dynamicStackMemSegment=bankName;
        end

        function setOSSchedulingMode(h,osMode)
            h.mNeedSave=true;
            h.mRTOS.schedulingMode=osMode;
        end

        function setOSBaseRatePriority(h,priority)
            h.mNeedSave=true;
            h.mRTOS.baseRatePriority=priority;
        end


        function newData=createData(h)

















            newData=struct('chipInfo','',...
            'mem','',...
            'cache','',...
            'boardType','',...
            'isSimulator',0,...
            'enableHSRTDX',0,...
            'versionNumber',getTgtPrefVersion(),...
            'dspbios','',...
            'lastErr',struct('errId','','errMsg',''),...
            'customCode','',...
            'enableDSPBIOSTab',0,...
            'RTOS','None',...
            'peripherals','',...
            'procName','',...
            'boardName','',...
            'realtimesupport','');

            newData.chipInfo=h.mRegistryInfo;
            newData.chipInfo.cpuClockRateMHz=h.mBoard.CPUClock;
            newData.chipInfo.src=h.mBoard.SourceFiles;
            if(numel(h.mBoard.SourceFiles)>0)
                newData.chipInfo.copysrc=repmat({[0]},1,numel(h.mBoard.SourceFiles));%#ok<NBRAK>
            else
                newData.chipInfo.copysrc={};
            end

            newData.chipInfo.inc=h.mBoard.IncludePaths;
            newData.chipInfo.lib_le=h.mBoard.LibrariesLittleEndian;
            newData.chipInfo.lib_be=h.mBoard.LibrariesBigEndian;
            newData.chipInfo.compileroptions=h.mBoard.CompilerOption;
            newData.chipInfo.linkeroptions=h.mBoard.LinkerOption;

            newData.boardType=h.mBoard.Type;

            newData.lastErr.errId=[];
            newData.lastErr.errMsg={};

            newData.customCode.sourceFiles={};
            newData.customCode.includePaths={};
            newData.customCode.libraries={};
            if(numel(h.mBoard.InitFunction)==1&&isempty(h.mBoard.InitFunction{1}))
                newData.customCode.initializeFunctions={};
            else
                newData.customCode.initializeFunctions=h.mBoard.InitFunction;
            end
            if(numel(h.mBoard.TerminateFunction)==1&&isempty(h.mBoard.TerminateFunction{1}))
                newData.customCode.terminateFunctions={};
            else
                newData.customCode.terminateFunctions=h.mBoard.TerminateFunction;
            end

            newData.RTOS=h.mBoard.CurrentRTOS;
            if(h.mBoard.isRT)
                newData.realtimesupport='on';
            else
                newData.realtimesupport='off';
            end

            newData.procName=h.mBoard.IDEOptions{2};
            newData.boardName=h.mBoard.IDEOptions{1};

            newData.mem=struct('numBanks',numel(h.mMemBanks),...
            'bank',h.mMemBanks,...
            'compiler',struct('section',h.mCompilerSections,...
            'numSections',numel(h.mCompilerSections)),...
            'dspbios','',...
            'custom',struct('numSections',numel(h.mCustomSections),...
            'section',h.mCustomSections));

            if h.getNumCacheEntries()>0
                cache=struct('levelLabel',{h.mCache.Levels{:}},...
                'cacheSize',{h.mCache.Configs{:}});%#ok<CCAT1>
                newData.cache=cache;
            else
                newData.cache=[];
            end

            newData=h.copyDataForCompatibility(newData);


            if(~isempty(h.mRTOS)&&isfield(h.mRTOS,'ChipCompilerSectionEndAt'))

                newData.mem.compiler.section=h.mCompilerSections(1:h.mRTOS.ChipCompilerSectionEndAt);
                newData.mem.compiler.numSections=h.mRTOS.ChipCompilerSectionEndAt;
                newData.mem.dspbios.section=struct('name',{h.mCompilerSections(h.mRTOS.ChipCompilerSectionEndAt+1:end).name},...
                'description',{h.mCompilerSections(h.mRTOS.ChipCompilerSectionEndAt+1:end).description},...
                'contents',{h.mCompilerSections(h.mRTOS.ChipCompilerSectionEndAt+1:end).contents},...
                'placement',{h.mCompilerSections(h.mRTOS.ChipCompilerSectionEndAt+1:end).placement});
                newData.mem.dspbios.numSections=numel(h.mCompilerSections)-h.mRTOS.ChipCompilerSectionEndAt;
                newData.mem.dspbios.codeObjectMem=h.mRTOS.codeObjectMem;
                newData.mem.dspbios.dataObjectMem=h.mRTOS.dataObjectMem;
                newData.dspbios=rmfield(h.mRTOS,{'ChipCompilerSectionEndAt','codeObjectMem','dataObjectMem'});
                newData.OS.schedulingMode=h.mRTOS.schedulingMode;
                newData.OS.baseRatePriority=h.mRTOS.baseRatePriority;
            end

            if(h.hasPeripherals())

                newData.peripherals=[];
                fieldreqd=h.getFieldNameRequiredForPeripherals(newData.chipInfo.subFamily);
                if~isequal(fieldreqd,'UNKNOWNCHIPSUBFAMILY')
                    newData.peripherals.(fieldreqd)=h.mPeripherals.value;
                end
            end

        end


        function save(h,configSet)
            newTargetInfo=h.createData();
            newTargetInfo.tag=h.mTag;

            h.mMemento.saveData(configSet,newTargetInfo);
            h.mNeedSave=false;
            h.mTargetInfo=h.mMemento.getCurData();
            h.updateFromMemento();

        end

        function verify(h,newData)%#ok<INUSD>









        end

        function[valid,errorstr]=validateMemorySetting(h)

            errorstr='';


            contents={h.mMemBanks(:).contents};
            bankContents=h.getMemoryBankContentsChoices();
            code=strmatch(bankContents{2},contents,'exact');
            data=strmatch(bankContents{3},contents,'exact');
            codeAndData=strmatch(bankContents{4},contents,'exact');
            valid=(((numel(code)>0)&&(numel(data)>0))||...
            (numel(codeAndData)>0));
            if~valid
                errorstr=DAStudio.message('ERRORHANDLER:tgtpref:ValidateMinBankConfig');
                return;
            end

            allBanks=h.getAllMemoryBankNames();

            for i=1:length(h.mCompilerSections)
                curPlacement=h.mCompilerSections(i).placement;
                emptystr=cellfun(@isempty,curPlacement);
                if(any(emptystr))
                    valid=false;
                    errorstr=DAStudio.message('ERRORHANDLER:tgtpref:SectionNotMapped',h.mCompilerSections(i).name);
                end
                for j=1:length(curPlacement)
                    found=strmatch(curPlacement{j},allBanks,'exact');
                    if(isempty(found))
                        valid=false;
                        errorstr=DAStudio.message('ERRORHANDLER:tgtpref:SectionNotMapped',h.mCompilerSections(i).name);
                    end
                end
            end

            for i=1:length(h.mCustomSections)
                curPlacement=h.mCustomSections(i).placement;
                emptystr=cellfun(@isempty,curPlacement);
                if(any(emptystr))
                    valid=false;
                    errorstr=DAStudio.message('ERRORHANDLER:tgtpref:SectionNotMapped',h.mCustomSections(i).name);
                end
                for j=1:length(curPlacement)
                    found=strmatch(curPlacement{j},allBanks,'exact');
                    if(isempty(found))
                        valid=false;
                        errorstr=DAStudio.message('ERRORHANDLER:tgtpref:SectionNotMapped',h.mCompilerSections(i).name);
                    end
                end
            end
        end


        function ret=ensureCellStr(h,str)%#ok<INUSL>
            if~iscell(str)
                ret={str};
            else
                ret=str;
            end
        end

        function newData=copyForCustomChip(h,Name,BasedOn,...
            CompilerOption,LinkerOption)
            assert(strcmp(h.mBoard.Chip,BasedOn),h.getAssertionMessage());

            newData=targetpref.Data;

            newData.mBlock=h.mBlock;
            newData.mTargetInfo=[];
            newData.mRegistryInfo=h.mRegistryInfo;
            newData.mRegistry=h.getProcRegistry();
            newData.mMemento=h.mMemento;

            newData.mBoard=h.mBoard;
            newData.mBoard.Chip=Name;
            newData.mBoard.CompilerOption=h.ensureCellStr(CompilerOption);
            newData.mBoard.LinkerOption=h.ensureCellStr(LinkerOption);

            newData.mMemBanks=h.mMemBanks;

            for i=1:numel(h.mMemBanks)
                newData.mMemBanks(i).iscontentsfixed=false;
                newData.mMemBanks(i).isremovable=true;
            end

            newData.mCache=h.mCache;
            newData.mCompilerSections=h.mCompilerSections;
            newData.mCustomSections=h.mCustomSections;
            newData.mPeripherals=h.mPeripherals;
            newData.mDefault=h.mDefault;
            newData.setTag(h.mTag);
            newData.mChip=h.mChip;
        end


        function[procInfo,toolInfo]=splitNewChipData(h,chipInfo)%#ok<INUSL>


            procinfofields={'deviceID','subFamily','cpuClockRateMHz','intMem'};

            for i=1:length(procinfofields)
                val=chipInfo.(procinfofields{i});
                procInfo.(procinfofields{i})=val;
            end

            toolInfo=rmfield(chipInfo,procinfofields);
        end

        function[procInfo,toolInfo]=createInfoForRegistry(h)
            chipInfo=h.mRegistryInfo;
            chipInfo.isBuiltIn=false;
            chipInfo.deviceID=h.mBoard.Chip;
            chipInfo.subFamily=h.mBoard.SubFamily;
            chipInfo.cpuClockRateMHz=h.mBoard.CPUClock;
            chipInfo.src=h.mBoard.SourceFiles;
            chipInfo.copysrc=repmat({[0]},1,numel(h.mBoard.SourceFiles));%#ok<NBRAK>
            chipInfo.inc=h.mBoard.IncludePaths;
            chipInfo.lib_le=h.mBoard.LibrariesLittleEndian;
            chipInfo.lib_be=h.mBoard.LibrariesBigEndian;
            chipInfo.codegenhookpoint=h.mBoard.CodeGenHookPoint;
            chipInfo.defaultSysStackSize=h.mBoard.StackSize;
            chipInfo.compileroptions=h.mBoard.CompilerOption;
            chipInfo.linkeroptions=h.mBoard.LinkerOption;
            [procInfo,toolInfo]=h.splitNewChipData(chipInfo);
        end

        function ret=isProcRegistered(h)
            reg=h.getProcRegistry();
            if~reg.isInitialized()
                h.initializeProcessorRegistry();
            end
            ret=h.getProcRegistry().isProcRegistered(h.mTargetInfo.chipInfo.deviceID);
        end

        function newTargetInfo=getDefaultTargetInfo(h)
            boardRegistry=h.getBoardRegistry();
            if exist('registertic2000.m','file')
                fileName='ccslinktgtpref_201_ud.mat';
            elseif exist('registerxilinxise.m','file')
                fileName='xilinxisetgtpref_401_ud';
            end
            file=linkfoundation.util.File(fullfile(boardRegistry.UDRepository,fileName));
            newTargetInfo=load(file.FullPathName);
            newTargetInfo=newTargetInfo.ud;
            newTargetInfo=h.reduceTargetInfo(newTargetInfo);
            newTargetInfo.tag=h.getTag();
        end

        function targetInfo=reduceTargetInfo(h,targetInfo)
            if~isempty(targetInfo)&&isfield(targetInfo,'chipInfo')
                allPeripherals=targetInfo.peripherals;
                targetInfo.peripherals=[];
                fieldreqd=h.getFieldNameRequiredForPeripherals(targetInfo.chipInfo.subFamily);
                if~isequal(fieldreqd,'UNKNOWNCHIPSUBFAMILY')
                    targetInfo.peripherals.(fieldreqd)=allPeripherals.(fieldreqd);
                end
            end
        end

    end

end

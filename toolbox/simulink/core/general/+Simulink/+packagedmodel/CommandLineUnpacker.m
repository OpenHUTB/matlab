classdef CommandLineUnpacker<handle




    properties(GetAccess=public,SetAccess=private)
CloseTopModel
CoderConfig
DiagnosticThrown
Inputs
Indices
Model
Platform
Release
SubModelsTable
TopModelTable
SIMCompiler
CoderCompiler
    end

    methods(Access=public)
        function this=CommandLineUnpacker()
            this.CloseTopModel=false;
            this.CoderConfig=[];
            this.DiagnosticThrown=false;
            this.Indices=[];
            this.Inputs=[];
            this.Model='';
            this.Platform=Simulink.packagedmodel.getPlatform(false);
            this.Release=Simulink.packagedmodel.getRelease();
            this.SubModelsTable=table;
            this.TopModelTable=[];
            this.SIMCompiler='';
            this.CoderCompiler='';
        end

        function delete(this)
            builtin('_clearSLCacheSUTracker');
            builtin('_removeAllSLCacheModelInfo');
            if this.CloseTopModel
                close_system(this.Model,0);
            end
        end

        function unpack(this,inputs)
            this.setup(inputs);
            if isempty(this.TopModelTable)
                return;
            end
            this.verifyFileGenControl();
            this.verifyModelsNotCompiling();
            this.processTopModel();
            this.extract();
        end

        function result=getUnpackedInfo(this)


            result=table();
            if~isempty(this.Indices)
                result=this.TopModelTable(this.Indices,1:4);
            end

            if isempty(result)&&~this.DiagnosticThrown
                this.showNoExtractablesDiagnostic();
            end



            if~isempty(this.SubModelsTable)
                this.SubModelsTable.Properties.VariableNames=...
                result.Properties.VariableNames;
                result=[result;this.SubModelsTable];
            end
        end
    end

    methods(Access=private)
        function setup(this,inputs)
            this.Inputs=inputs;


            inspectorType=Simulink.packagedmodel.inspect.ContentInspectorType.TRANSLATE;
            inspector=Simulink.packagedmodel.inspect.getInspector(inspectorType,...
            this.Inputs.slxcFile);
            aTable=inspector.populate();


            if~any(aTable.IsExtractable)
                this.showNoExtractablesDiagnostic();
                return;
            end


            this.TopModelTable=aTable(aTable.IsExtractable,:);
        end

        function showNoExtractablesDiagnostic(this)
            MSLDiagnostic('Simulink:cache:noExtractableContentInSLXC',...
            this.Inputs.slxcFile).reportAsWarning;
            this.DiagnosticThrown=true;
        end


        function verifyFileGenControl(this)
            cacheFolder=Simulink.fileGenControl('get','CacheFolder');
            slxcDir=dir(this.Inputs.slxcFile);



            slxcDir.folder=coder.make.internal.transformPaths(slxcDir.folder,'pathType','full');
            if~isequal(slxcDir.folder,cacheFolder)
                DAStudio.error('Simulink:cache:extractSLXCNotInCacheFolder',...
                this.Inputs.slxcFile,cacheFolder);
            end
        end


        function processTopModel(this)
            [~,this.Model]=fileparts(this.Inputs.slxcFile);
            this.CloseTopModel=~bdIsLoaded(this.Model);
            try
                load_system(this.Model);
            catch ME
                if~strcmp(ME.identifier,'Simulink:Commands:OpenSystemUnknownSystem')
                    rethrow(ME);
                end
                DAStudio.error('Simulink:cache:clMissingModel',this.Model,this.Inputs.slxcFile);
            end
        end

        function result=isModelCompiled(~,model)
            result=~strcmp(get_param(model,'SimulationStatus'),...
            'stopped');
        end

        function verifyModelsNotCompiling(this)
            models=find_system('type','block_diagram');
            for i=1:numel(models)
                model=models{i};

                if this.isModelCompiled(model)
                    DAStudio.error('Simulink:cache:clUnpackAbortModelCompiling',...
                    this.Inputs.slxcFile,model);
                end
            end
        end

        function extract(this)
            switch(this.Inputs.Target)
            case 'All'
                this.unpackSimulation();
                this.unpackCodeGeneration();
            case 'Simulation'
                this.unpackSimulation();
            case 'CodeGeneration'
                this.unpackCodeGeneration();
            otherwise
                DAStudio.error('Simulink:cache:unknownType',this.Inputs.Target,...
                mfilename());
            end
            this.unpackSubModels();
        end

        function record=getRecord(this,i)
            record=this.TopModelTable(i,'Data').Data;
            if iscell(record)
                record=record{1};
            end
        end

        function mode=getMode(~,record)
            if isa(record,'slcache.Modes')
                mode=record;
            elseif isa(record,'struct')
                mode=record.mode;
            elseif isa(record,'cell')
                mode=record{1};
            else
                DAStudio.error('Simulink:cache:unknownMode',record,...
                mfilename());
            end
        end

        function storeIndex(this,i)
            this.Indices(end+1)=i;
        end



        function getModelCoderConfig(this)
            Simulink.filegen.internal.FolderConfiguration.clearCache();
            Simulink.filegen.internal.FolderConfiguration.updateCache(this.Model);
            this.CoderConfig.STFName=strrep(get_param(this.Model,'SystemTargetFile'),'.tlc','');
            this.CoderConfig.CODER_TOP.TargetSuffix=Simulink.packagedmodel.getTargetSuffix(this.Model,'ModelCode',this.CoderConfig.STFName);
            this.CoderConfig.CODER.TargetSuffix=Simulink.packagedmodel.getTargetSuffix(this.Model,'ModelReferenceCode',this.CoderConfig.STFName);
            this.CoderConfig.FolderConfig=char(Simulink.fileGenControl('get','CodeGenFolderStructure'));

            this.CoderCompiler=Simulink.packagedmodel.getCoderCompiler(this.Model);
        end



        function result=CoderConfigMatch(this,mode,record)
            if~any(strcmp(mode,{'CODER','CODER_TOP'}))
                result=true;
                return;
            end
            mode=char(mode);


            result=isequal(record.STFName,this.CoderConfig.STFName)&&...
            isequal(record.targetSuffix,this.CoderConfig.(mode).TargetSuffix)&&...
            isequal(record.folderConfig,this.CoderConfig.FolderConfig);
        end

        function unpackSimulation(this)
            this.SIMCompiler=Simulink.packagedmodel.getSimCompiler();
            for i=1:height(this.TopModelTable)
                record=this.getRecord(i);
                mode=this.getMode(record);
                switch(mode)
                case 'SIM'
                    builtin('_unpackSLCacheSIM',this.Model,this.Model,...
                    false,'SIM',this.SIMCompiler);
                case 'RAPID'
                    builtin('_unpackSLCacheRapidAccel',this.Model);
                case 'ACCEL'
                    builtin('_unpackSLCacheAccel',this.Model);
                otherwise
                    continue;
                end

                if this.unpackedOrUpToDate(this.Model,mode)
                    this.storeIndex(i);
                end
                this.showVerboseMsg(mode,this.Model);
            end
        end

        function unpackCodeGeneration(this)
            this.getModelCoderConfig();
            for i=1:height(this.TopModelTable)
                record=this.getRecord(i);
                mode=this.getMode(record);

                if~this.CoderConfigMatch(mode,record)
                    continue;
                end

                switch(mode)
                case 'CODER'
                    builtin('_unpackSLCacheCoder',this.Model,this.Model,...
                    false,'RTW',record.STFName,record.targetSuffix,...
                    record.genCodeOnly,record.folderConfig,this.CoderCompiler);
                case 'CODER_TOP'
                    builtin('_unpackSLCacheCoderTop',this.Model,false,...
                    record.STFName,record.targetSuffix,record.genCodeOnly,...
                    record.folderConfig,this.CoderCompiler);
                otherwise
                    continue;
                end

                if this.unpackedOrUpToDate(this.Model,mode)
                    this.storeIndex(i);
                end
                this.showVerboseMsg(mode,this.Model);
                this.CoderConfig.GenCodeOnly=record.genCodeOnly;
                this.CoderConfig.CoderTableEntry=this.TopModelTable.Target{i};
            end
        end

        function unpackSubModels(this)



            if~this.Inputs.UnpackReferencedModels||isempty(this.Indices)
                return;
            end

            unpackSimSubModels=any(strcmp(this.Inputs.Target,...
            {'All','Simulation'}));
            unpackCoderSubModels=any(strcmp(this.Inputs.Target,...
            {'All','CodeGeneration'}))&&...
            isfield(this.CoderConfig,'GenCodeOnly');
            subModels=this.getSubModels();
            for k=1:length(subModels)
                if unpackSimSubModels
                    builtin('_unpackSLCacheSIM',this.Model,subModels{k},...
                    false,'SIM',this.SIMCompiler);
                    this.showVerboseMsg(slcache.Modes.SIM,subModels{k});
                    this.addToSubModelTable(subModels{k},slcache.Modes.SIM);
                end
                if unpackCoderSubModels
                    coder.internal.modelRefUtil(subModels{k},'setupFolderCacheForReferencedModel',this.Model);
                    builtin('_unpackSLCacheCoder',this.Model,subModels{k},...
                    false,'RTW',this.CoderConfig.STFName,...
                    this.CoderConfig.CODER.TargetSuffix,...
                    this.CoderConfig.GenCodeOnly,this.CoderConfig.FolderConfig,...
                    this.CoderCompiler);
                    this.showVerboseMsg(slcache.Modes.CODER,subModels{k});
                    this.addToSubModelTable(subModels{k},slcache.Modes.CODER);
                end
            end
        end



        function subModels=getSubModels(this)
            [info,m]=builtin('_getSLCacheExtraInformation',...
            this.Inputs.slxcFile,this.Release,this.Platform);%#ok<ASGLU>
            subModels=info.subModels.toArray();
            if~isempty(subModels)
                subModels=subModels';
            else
                subModels=this.getSubModelsFromFirstLevel();
            end
        end



        function subModels=getSubModelsFromFirstLevel(this)


            firstLevelModels=find_mdlrefs(this.Model,'AllLevels',false,...
            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
            'ReturnTopModelAsLastElement',false);
            subModels=firstLevelModels;



            for i=1:numel(firstLevelModels)
                aModel=firstLevelModels{i};
                [isSlxcAvailable,slxcFile]=sl('isPackagedModelAvailable',aModel);
                if~isSlxcAvailable
                    continue;
                end

                [info,m]=builtin('_getSLCacheExtraInformation',...
                slxcFile,this.Release,this.Platform);%#ok<ASGLU>
                if~isempty(info.subModels.toArray())
                    subModels=[info.subModels.toArray()';subModels];%#ok<AGROW>
                end
            end

            subModels=unique(subModels,'stable');
        end

        function addToSubModelTable(this,model,mode)
            if~this.unpackedOrUpToDate(model,mode)
                return;
            end
            if mode==slcache.Modes.SIM
                target=DAStudio.message('Simulink:cache:reportSupportsSimTarget');
            else
                target=this.CoderConfig.CoderTableEntry;
                mdlRefText=DAStudio.message('Simulink:cache:reportModelRefContext');
                topModelText=DAStudio.message('Simulink:cache:reportStandaloneContext');
                target=regexprep(target,topModelText,mdlRefText);
            end
            release=string(Simulink.packagedmodel.getRelease());
            platform=string(Simulink.packagedmodel.getPlatform(false));
            model=string(model);
            this.SubModelsTable=[this.SubModelsTable;...
            {model,release,platform,target}];
        end

        function showVerboseMsg(this,mode,model)
            if~this.Inputs.Verbose
                return;
            end


            [isCoder,msgID]=this.getUnpackMsgIDForMode(mode);
            reason=this.getUnpackReasonMsg(model,mode);


            if isCoder
                msg=DAStudio.message(msgID,this.CoderConfig.STFName,...
                model,this.CoderConfig.FolderConfig,reason);
            else
                msg=DAStudio.message(msgID,model,reason);
            end
            sl('sl_disp_info',msg,true);
        end

        function[isCoder,msgID]=getUnpackMsgIDForMode(~,mode)
            switch(mode)
            case 'SIM'
                msgID='Simulink:cache:clUnpackedSIMTarget';
                isCoder=false;
            case 'RAPID'
                msgID='Simulink:cache:clUnpackedRapidTarget';
                isCoder=false;
            case 'ACCEL'
                msgID='Simulink:cache:clUnpackedAccelTarget';
                isCoder=false;
            case 'CODER'
                msgID='Simulink:cache:clUnpackedCoderTarget';
                isCoder=true;
            case 'CODER_TOP'
                msgID='Simulink:cache:clUnpackedCoderTopTarget';
                isCoder=true;
            otherwise
                DAStudio.error('Simulink:cache:unknownMode',char(mode),...
                mfilename());
            end
        end

        function result=unpackedOrUpToDate(~,model,mode)
            info=builtin('_getSLCacheModelInfo',model,mode);
            result=~any(strcmp(info.unpackReason,{'UNPACK_SKIP_MISSING_OPC',...
            'UNPACK_SKIP_UNSUPPORTED_MODE','UNPACK_SKIP_UNSUPPORTED_COMPILER'}));
        end

        function reason=getUnpackReasonMsg(~,model,mode)
            info=builtin('_getSLCacheModelInfo',model,mode);
            switch(info.unpackReason)
            case{'UNPACKED_NO_TARGET',...
                'UNPACKED_TARGET_CHECKSUM_MISMATCH',...
                'UNPACKED_EXTRA_CHECKS'}
                unpackID='Simulink:cache:clUnpacked';
            case 'UNPACK_SKIP_MISSING_OPC'
                unpackID='Simulink:cache:clUnpackSkipMissingOPC';
            case{'UNPACK_SKIP_OPC_CHECKSUM_MATCH',...
                'UNPACK_SKIP_TARGET_CHECKSUM_MATCH'}
                unpackID='Simulink:cache:clUnpackSkipTargetUpToDate';
            case 'UNPACK_SKIP_UNSUPPORTED_MODE'
                unpackID='Simulink:cache:clUnpackSkipTargetNotSupported';
            case 'UNPACK_SKIP_UNSUPPORTED_COMPILER'
                unpackID='Simulink:cache:clUnpackSkipCompilerNotSupported';
            otherwise
                DAStudio.error('Simulink:cache:unknownType',char(info.unpackReason),...
                mfilename());
            end
            reason=DAStudio.message(unpackID);
        end
    end

end



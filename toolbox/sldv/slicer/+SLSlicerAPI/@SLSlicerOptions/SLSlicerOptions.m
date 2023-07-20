classdef SLSlicerOptions<handle&matlab.mixin.CustomDisplay





    properties
        StorageOptions=struct(...
        'SaveInModel',false,...
        'ConfigurationFile','<default>'...
        );
        AnalysisOptions=struct(...
        'AutomaticRefresh',true...
        );
        SliceOptions=struct(...
        'SignalObservers',false,...
        'ExtendSubsystems',true,...
        'RootLevelInterfaces',true...
        );
        InlineOptions=struct(...
        'Libraries',true,...
        'Masks',true,...
        'ModelBlocks',true,...
        'Variants',true,...
        'SubsystemReferences',true...
        );
    end
    properties(Dependent)
        Name='';
        Description='';
        UseTimeWindow;
        Color;
        SignalPropagation;
        CoverageFile;
        UseDeadLogic;
        DeadLogicFile;
        ActiveConfig;
        DisplayedConfig;
        StartingPoint;
        ExclusionPoint;
        Constraint;
        Configuration;
        SliceComponent;
        StartTime;
        StopTime;
        HighlightCommonBlocksOnly;
    end
    properties(Access=private)
        actConfig=1;
        dispConfig=[];
        cfgCounter=1;
    end
    properties(Access=protected)
        cfg;
        internalCfg;
    end
    methods
        function obj=SLSlicerOptions(varargin)
            if nargin==0
                obj.cfg=SLSlicerAPI.SLSlicerConfig;
            elseif nargin==1
                scfg=convertStringsToChars(varargin{1});
                if isa(scfg,'SLSlicerAPI.SLSlicerOptions')
                    obj.clone(scfg);
                elseif isa(scfg,'SlicerConfiguration')


                    obj.applySlicerConfiguration(scfg);
                elseif ischar(scfg)
                    obj.applySLMSFile(scfg);
                end
            end
        end
        function clone(obj,slopts)

            obj.StorageOptions=slopts.StorageOptions;
            obj.AnalysisOptions=slopts.AnalysisOptions;
            obj.SliceOptions=slopts.SliceOptions;
            obj.InlineOptions=slopts.InlineOptions;
            obj.cfg=slopts.cfg;
            obj.actConfig=slopts.actConfig;
            obj.dispConfig=slopts.dispConfig;
            obj.cfgCounter=slopts.cfgCounter;
            obj.internalCfg=slopts.internalCfg;
        end

        function addConfiguration(obj,config)
            if~exist('config','var')

                if obj.needSync
                    sc=obj.internalCfg.addCriterion;
                    slcfg=SLSlicerAPI.SLSlicerConfig(sc,obj.scfg);
                else
                    slcfg=SLSlicerAPI.SLSlicerConfig;
                end
            elseif isa(config,'SLSlicerAPI.SLSlicerConfig')
                slcfg=config;
                if obj.needSync
                    sc=obj.internalCfg.addCriterion;
                    slcfg.applySliceCriterion(sc);
                end
            else
                error('ModelSlicer:API:InvalidArgumentAddConfig',...
                getString(message('Sldv:ModelSlicer:SLSlicerAPI:InvalidArgumentAddConfig')));
            end

            obj.cfgCounter=obj.cfgCounter+1;
            slcfg.setDefaultColor(obj.cfgCounter);
            obj.cfg(end+1)=slcfg;

            obj.actConfig=numel(obj.cfg);
            if obj.needSync
                obj.internalCfg.selectedIdx=obj.actConfig;
                obj.internalCfg.allDisplayed=obj.dispConfig;
            end
        end
        function removeConfiguration(obj,idx)
            if idx>length(obj.Configuration)
                error(getString(message('Sldv:ModelSlicer:SLSlicerAPI:IndexExeedsNumberOfConfiguration')));
            elseif length(obj.Configuration)<=1
                error(getString(message('Sldv:ModelSlicer:SLSlicerAPI:CannotRemoveConfigurationSlicer')));
            else
                obj.cfg(idx)=[];
                if obj.needSync
                    obj.internalCfg.sliceCriteria(idx)=[];
                end

                if ismember(obj.actConfig,idx)
                    if numel(obj.cfg)==1

                        obj.actConfig=1;
                    elseif isscalar(idx)


                        obj.actConfig=obj.actConfig-1;
                    else
                        if min(idx)>1
                            obj.actConfig=min(idx)-1;
                        else
                            obj.actConfig=1;
                        end
                    end
                elseif any(obj.actConfig>idx)
                    obj.actConfig=obj.actConfig-sum(obj.actConfig>idx);
                elseif numel(obj.cfg)<obj.actConfig
                    obj.actConfig=numel(obj.cfg);
                end
                if obj.needSync
                    obj.internalCfg.selectedIdx=obj.actConfig;
                    obj.internalCfg.allDisplayed=obj.dispConfig;
                end
            end
        end


        function addStartingPoint(obj,item,varargin)
            obj.cfg(obj.ActiveConfig).addStartingPoint(item,varargin{:});
        end
        function removeStartingPoint(obj,idx,varargin)
            obj.cfg(obj.ActiveConfig).removeStartingPoint(idx,varargin{:});
        end
        function addExclusionPoint(obj,item)
            obj.cfg(obj.ActiveConfig).addExclusionPoint(item);
        end
        function removeExclusionPoint(obj,idx)
            obj.cfg(obj.ActiveConfig).removeExclusionPoint(idx);
        end
        function addConstraint(obj,item,varargin)
            obj.cfg(obj.ActiveConfig).addConstraint(item,varargin{:});
        end
        function removeConstraint(obj,idx)
            obj.cfg(obj.ActiveConfig).removeConstraint(idx);
        end
        function addSliceComponent(obj,item)
            obj.cfg(obj.ActiveConfig).addSliceComponent(item);
        end
        function removeSliceComponent(obj)
            obj.cfg(obj.ActiveConfig).removeSliceComponent();
        end
        function addCovConstraint(obj,mdlObj)
            obj.cfg(obj.ActiveConfig).addCovConstraint(mdlObj);
        end
        function removeCovConstraint(obj,idx)
            obj.cfg(obj.ActiveConfig).removeCovConstraint(idx);
        end
        function refineDeadLogic(obj,sysH,varargin)
            obj.cfg(obj.ActiveConfig).refineDeadLogic(sysH,varargin{:});
        end
        function sys=getSysRefinedForDeadLogic(obj)
            sys=obj.cfg(obj.ActiveConfig).getSysRefinedForDeadLogic;
        end
        function removeDeadLogic(obj,sysH)
            obj.cfg(obj.ActiveConfig).removeDeadLogic(sysH);
        end
        function runAndPause(obj,time)
            obj.Configuration(obj.ActiveConfig).runAndPause(time);
        end
        function showPortLabel(obj)
            obj.Configuration(obj.ActiveConfig).showPortLabel();
        end
        function hidePortLabel(obj)
            obj.Configuration(obj.ActiveConfig).hidePortLabel();
        end
        function rollBackAndPause(obj,time)
            obj.Configuration(obj.ActiveConfig).rollBackAndPause(time);
        end
        function unsetPauseTime(obj,time)
            obj.Configuration(obj.ActiveConfig).unsetPauseTime(time);
        end
        function continueSim(obj)
            obj.Configuration(obj.ActiveConfig).continueSimulation();
        end
        function stopSim(obj)
            obj.Configuration(obj.ActiveConfig).stopSimulation();
        end
        function stepForward(obj)
            obj.Configuration(obj.ActiveConfig).stepForward();
        end
        function stepBack(obj)
            obj.Configuration(obj.ActiveConfig).stepBack();
        end
        function applySimInToModel(obj,simIn)
            obj.Configuration(obj.ActiveConfig).applySimInToModel(simIn);
        end
    end
    methods(Access=public,Hidden=true)

        function addSliceSubSystem(obj,item)
            warning('ModelSlicer:API:DeprecatedAPI',...
            getString(message('Sldv:ModelSlicer:SLSlicerAPI:DeprecatedAPI',...
            'addSliceSubSystem','addSliceComponent')));
            obj.addSliceComponent(item);
        end
        function removeSliceSubSystem(obj)
            warning('ModelSlicer:API:DeprecatedAPI',...
            getString(message('Sldv:ModelSlicer:SLSlicerAPI:DeprecatedAPI',...
            'removeSliceSubSystem','removeSliceComponent')));

            obj.removeSliceComponent();
        end
    end

    methods

        function set.ActiveConfig(obj,idx)
            if numel(idx)~=1
                error('ModelSlicer:API:IndexMustAScalar',...
                getString(message('Sldv:ModelSlicer:SLSlicerAPI:IndexMustAScalar')));
            elseif idx>obj.getNumConfig
                error('ModelSlicer:API:IndexExeedsNumberOfConfiguration',...
                getString(message('Sldv:ModelSlicer:SLSlicerAPI:IndexExeedsNumberOfConfiguration')))
            else
                obj.actConfig=idx;
            end
            if obj.needSync
                obj.internalCfg.selectedIdx=idx;
            end
        end
        function idx=get.ActiveConfig(obj)
            idx=obj.actConfig;
        end

        function set.DisplayedConfig(obj,in)%#ok<INUSD>
            error('ModelSlicer:API:DisplayedConfigIsReadOnly',...
            getString(message('Sldv:ModelSlicer:SLSlicerAPI:DisplayedConfigIsReadOnly')));
        end

        function dispCfg=get.DisplayedConfig(obj)
            dispCfg=[];
            for n=1:length(obj.cfg)
                if obj.cfg(n).highlighted
                    dispCfg(end+1)=n;%#ok<AGROW>
                end
            end
        end

        function out=get.StartingPoint(obj)
            out=obj.cfg(obj.ActiveConfig).StartingPoint;
        end
        function set.StartingPoint(obj,s)
            obj.cfg(obj.ActiveConfig).StartingPoint=s;
        end
        function out=get.ExclusionPoint(obj)
            out=obj.cfg(obj.ActiveConfig).ExclusionPoint;
        end
        function set.ExclusionPoint(obj,e)
            obj.cfg(obj.ActiveConfig).ExclusionPoint=e;
        end
        function set.Constraint(obj,c)
            obj.cfg(obj.ActiveConfig).Constraint=c;
        end
        function out=get.Constraint(obj)
            out=obj.cfg(obj.ActiveConfig).Constraint;
        end
        function set.SliceComponent(obj,c)
            obj.cfg(obj.ActiveConfig).SliceComponent=c;
        end
        function out=get.SliceComponent(obj)
            out=obj.cfg(obj.ActiveConfig).SliceComponent;
        end
        function out=get.Configuration(obj)
            out=obj.cfg;
        end
        function set.Configuration(obj,c)
            if isempty(c)


                error('ModelSlicer:API:EmptyAssignment',...
                getString(message('Sldv:ModelSlicer:SLSlicerAPI:EmptyAssinmentIsNot')));
            else
                obj.cfg=c;
            end
        end
        function set.Name(obj,n)
            obj.cfg(obj.actConfig).Name=n;
        end
        function out=get.Name(obj)
            out=obj.cfg(obj.actConfig).Name;
        end

        function set.Description(obj,n)
            obj.cfg(obj.actConfig).Description=n;
        end
        function out=get.Description(obj)
            out=obj.cfg(obj.actConfig).Description;
        end

        function set.UseTimeWindow(obj,n)
            obj.cfg(obj.actConfig).UseTimeWindow=n;
        end
        function out=get.UseTimeWindow(obj)
            out=obj.cfg(obj.actConfig).UseTimeWindow;
        end
        function set.Color(obj,n)
            obj.cfg(obj.actConfig).Color=n;
        end
        function out=get.Color(obj)
            out=obj.cfg(obj.actConfig).Color;
        end
        function set.SignalPropagation(obj,n)
            obj.cfg(obj.actConfig).SignalPropagation=n;
        end
        function out=get.SignalPropagation(obj)
            out=obj.cfg(obj.actConfig).SignalPropagation;
        end
        function set.CoverageFile(obj,n)
            obj.cfg(obj.actConfig).CoverageFile=n;
            obj.cfg(obj.actConfig).clearCvd();
        end
        function out=get.CoverageFile(obj)
            out=obj.cfg(obj.actConfig).CoverageFile;
        end
        function set.DeadLogicFile(obj,n)
            obj.cfg(obj.actConfig).DeadLogicFile=n;
            obj.cfg(obj.actConfig).clearDeadLogic();
        end
        function out=get.DeadLogicFile(obj)
            out=obj.cfg(obj.actConfig).DeadLogicFile;
        end
        function set.UseDeadLogic(obj,n)
            obj.cfg(obj.actConfig).UseDeadLogic=n;
        end
        function out=get.UseDeadLogic(obj)
            out=obj.cfg(obj.actConfig).UseDeadLogic;
        end
        function set.StorageOptions(obj,opt)
            obj.StorageOptions=opt;
            if obj.needSync
                obj.scfg.options.StorageOptions=opt;
            end
        end
        function set.AnalysisOptions(obj,opt)
            obj.AnalysisOptions=opt;
            if obj.needSync
                obj.scfg.options.AnalysisOptions=opt;
            end
        end
        function set.SliceOptions(obj,opt)
            obj.SliceOptions=opt;
            if obj.needSync
                obj.scfg.options.SliceOptions=opt;
            end
        end
        function set.InlineOptions(obj,opt)
            obj.InlineOptions=opt;
            if obj.needSync
                obj.scfg.options.InlineOptions=opt;
            end
        end
        function out=get.StartTime(obj)
            out=obj.cfg(obj.actConfig).StartTime;
        end
        function out=get.StopTime(obj)
            out=obj.cfg(obj.actConfig).StopTime;
        end
        function out=get.HighlightCommonBlocksOnly(obj)
            out=obj.internalCfg.highlightCommonBlocksVal;
        end
        function set.HighlightCommonBlocksOnly(obj,val)
            obj.highlightOnlyCommonBlocks(val);
        end
    end

    methods(Hidden)

        function applySlicerConfiguration(obj,scfg)


            obj.StorageOptions=scfg.options.Storage;
            obj.AnalysisOptions=scfg.options.AnalysisOptions;
            obj.SliceOptions=scfg.options.SliceOptions;
            obj.InlineOptions=scfg.options.InlineOptions;

            for n=1:length(scfg.sliceCriteria)
                slcfg=SLSlicerAPI.SLSlicerConfig(scfg.sliceCriteria(n),scfg);
                if n==1
                    obj.Configuration=slcfg;
                else
                    obj.addConfiguration(slcfg);
                end
            end
            obj.actConfig=scfg.selectedIdx;
            obj.internalCfg=scfg;
        end
        function updateSlicerConfiguration(obj,model)
            scfg=SLSlicerAPI.SLSlicerOptions.SLSlicerOptions2SlicerConfigulation(model,obj);
            obj.internalCfg=scfg;
            for n=1:length(scfg.sliceCriteria)
                obj.Configuration(n).assignSliceCriterion(scfg.sliceCriteria(n),scfg);
            end
        end
        function applySLMSFile(obj,slmsFile)



            inCfg=load(slmsFile','-mat');
            if isfield(inCfg.Options.InlineOptions,'VariantSubsystems')

                inCfg.Options.InlineOptions.Variants=inCfg.Options.InlineOptions.VariantSubsystems;
                inCfg.Options.InlineOptions=rmfield(inCfg.Options.InlineOptions,'VariantSubsystems');
            end
            if~isfield(inCfg.Options.InlineOptions,'SubsystemReferences')

                inCfg.Options.InlineOptions.SubsystemReferences=true;
            end

            obj.StorageOptions=inCfg.Options.Storage;
            obj.AnalysisOptions=inCfg.Options.AnalysisOptions;
            obj.SliceOptions=inCfg.Options.SliceOptions;
            obj.InlineOptions=inCfg.Options.InlineOptions;

            for n=1:length(inCfg.SliceCriteria)
                slcfg=SLSlicerAPI.SLSlicerConfig(inCfg.SliceCriteria(n),[]);
                if n==1
                    obj.Configuration=slcfg;
                else
                    obj.addConfiguration(slcfg);
                end
            end

            if isfield(inCfg,'selectedIdx')
                obj.ActiveConfig=inCfg.selectedIdx;
            end
        end
    end
    methods(Access=private)
        function n=getNumConfig(obj)
            n=numel(obj.Configuration);
        end
        function out=scfg(obj)
            out=obj.internalCfg;
        end
        function highlightOnlyCommonBlocks(obj,highlightCommonBlocks)
            if length(obj.DisplayedConfig)>1



                orignalAllDisplayed=obj.internalCfg.allDisplayed;
                obj.internalCfg.allDisplayed=obj.DisplayedConfig;
                obj.internalCfg.highlightCommonBlocksOnly(highlightCommonBlocks);
                obj.internalCfg.allDisplayed=orignalAllDisplayed;
            else
                error('ModelSlicer:API:FunctionRequiresMoreThanOneConfigurationActive',...
                getString(message('Sldv:ModelSlicer:SLSlicerAPI:HighlightCommonRequiresMoreThanOneConfigurationActive')));
            end
        end
    end
    methods(Static,Hidden)

        function slopts=SlicerConfiguration2SLSlicerOptions(scfg)
            slopts=SLSlicerAPI.SLSlicerOptions();
            slopts.applySlicerConfiguration(scfg);
        end
        function scfg=SLSlicerOptions2SlicerConfigulation(model,slopts)
            scfg=SlicerConfiguration(model);
            scfg.options.Storage=slopts.StorageOptions;
            scfg.options.AnalysisOptions=slopts.AnalysisOptions;
            scfg.options.SliceOptions=slopts.SliceOptions;
            scfg.options.InlineOptions=slopts.InlineOptions;
            scfg.allDisplayed=slopts.DisplayedConfig;
            scfg.selectedIdx=slopts.ActiveConfig;
            for n=1:length(slopts.Configuration)
                sc=SLSlicerAPI.SLSlicerConfig.SLSlicerConfig2SliceCriteria(model,slopts.Configuration(n));
                scfg.sliceCriteria(n)=sc;
            end
        end
    end
    methods(Access=protected)
        function yesno=needSync(obj)


            yesno=~isempty(obj.internalCfg);
        end

        function propgrp=getPropertyGroups(obj)
            propList1={'Configuration','ActiveConfig','DisplayedConfig','StorageOptions','AnalysisOptions','SliceOptions','InlineOptions'};
            propgrp(1)=matlab.mixin.util.PropertyGroup(propList1);
            propgrp(2)=getPropertyGroups(obj.cfg(obj.actConfig));
            propgrp(2).Title=getString(message('Sldv:ModelSlicer:SLSlicerAPI:ContentsOfActiveConfiguration'));
        end
    end
end

classdef LookupTableFinder<handle




    properties(Constant)

        DefaultConfig=cellfun(@(args)lutdesigner.lutfinder.Config(args{:}),{
        {"SubSystem","Repeating table","","rep_seq_y",{'rep_seq_t'}}
        {"SubSystem","Repeating Sequence Interpolated","","OutValues",{'TimeValues'}}
        });
    end

    properties(Dependent)

CustomConfig
    end

    properties(Access=private)
InfoMap
    end

    methods(Access=private)
        function this=LookupTableFinder()
            this.updateInfoMap(this.CustomConfig);
        end
    end

    methods
        function config=get.CustomConfig(~)
            customConfigSetting=lutdesigner.config.CustomSettings.getCustomConfig();
            config=lutdesigner.lutfinder.Config.fromSetting(customConfigSetting(:));
        end

        function set.CustomConfig(this,config)
            validateattributes(config,{'lutdesigner.lutfinder.Config'},{});
            this.updateInfoMap(config);
            customConfigSettings=toSetting(config(:));
            lutdesigner.config.CustomSettings.setCustomConfig(customConfigSettings);
        end

        function builder=getLookupTableBlockDataProxyBuilder(this,block)
            blockType=get_param(block,'BlockType');
            maskType=get_param(block,'MaskType');

            baseConfigId=lutdesigner.lutfinder.Config.createId(blockType,'');
            if this.InfoMap.isKey(baseConfigId)
                builder=this.InfoMap(baseConfigId);
            else
                fullConfigId=lutdesigner.lutfinder.Config.createId(blockType,maskType);
                builder=this.InfoMap(fullConfigId);
            end
        end
    end

    methods(Access=private)
        function updateInfoMap(this,customConfig)
            import lutdesigner.lutfinder.Config
            import lutdesigner.lutfinder.datafinder.*

            infoMap=containers.Map;


            infoMap(Config.createId('Lookup_n-D',''))=LookupndMap;
            infoMap(Config.createId('Interpolation_n-D',''))=InterpMap;
            infoMap(Config.createId('PreLookup',''))=PrelookupMap;
            infoMap(Config.createId('LookupNDDirect',''))=DirectLookupMap;
            infoMap(Config.createId('SimscapeBlock','PS Lookup Table (1D)'))=SIMSCAPELookupndMap;
            infoMap(Config.createId('SimscapeBlock','PS Lookup Table (2D)'))=SIMSCAPELookupndMap;
            infoMap(Config.createId('SimscapeBlock','PS Lookup Table (3D)'))=SIMSCAPELookupndMap;
            infoMap(Config.createId('SimscapeBlock','PS Lookup Table (4D)'))=SIMSCAPELookupndMap;


            for i=1:numel(this.DefaultConfig)
                config=this.DefaultConfig(i);
                configId=config.Id;
                assert(~infoMap.isKey(configId),...
                'lutdesigner:lutfinder:defaultConfigDuplicated',...
                'Detected duplicated default configuration.');
                infoMap(configId)=CustomMap(config);
            end


            for i=1:numel(customConfig)
                config=customConfig(i);
                configId=config.Id;
                assert(~infoMap.isKey(configId),...
                'lutdesigner:lutfinder:customConfigDuplicated',...
                'Detected duplicated custom configuration.');
                infoMap(configId)=CustomMap(config);
            end

            this.InfoMap=infoMap;
        end
    end

    methods(Static)
        function obj=getInstance()
            persistent instance
            if isempty(instance)||~isvalid(instance)
                instance=lutdesigner.lutfinder.LookupTableFinder();
            end
            obj=instance;
        end

        function setting=getLookupTableCustomConfigTable()
            obj=lutdesigner.lutfinder.LookupTableFinder.getInstance();
            setting=obj.CustomConfig.toSetting();
        end

        function setLookupTableCustomConfigTable(setting)
            obj=lutdesigner.lutfinder.LookupTableFinder.getInstance();
            obj.CustomConfig=lutdesigner.lutfinder.Config.fromSetting(setting);
        end
    end

    methods(Static)
        function tf=isLookupTableBlock(sys)
            if~strcmp(get_param(sys,'Type'),'block')
                tf=false;
                return;
            end

            blockType=get_param(sys,'BlockType');
            maskType=get_param(sys,'MaskType');
            obj=lutdesigner.lutfinder.LookupTableFinder.getInstance();
            tf=obj.InfoMap.isKey(lutdesigner.lutfinder.Config.createId(blockType,''))||...
            obj.InfoMap.isKey(lutdesigner.lutfinder.Config.createId(blockType,maskType));
        end

        function blocks=findLookupTableBlocks(sys,varargin)



            blocks=find_system(sys,...
            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
            'MatchFilter',@lutdesigner.lutfinder.matchfilter.matchSystemRegisteredAsLookupTableBlock,...
            'LookUnderMasks','all',varargin{:});

            blocks=regexprep(blocks,'\n',' ');
        end

        function dataProxy=getLookupTableBlockDataProxy(block)
            obj=lutdesigner.lutfinder.LookupTableFinder.getInstance();
            dataProxyBuilder=obj.getLookupTableBlockDataProxyBuilder(block);
            dataProxy=dataProxyBuilder.getBlockDataProxy(block);
        end
    end

    methods(Static)
        function tf=hasLookupTableControl(sys,varargin)
            tf=~isempty(Simulink.Mask.get(sys))&&...
            Simulink.Mask.Util.hasDialogControlOfType(sys,'lookuptablecontrol')&&...
            ~isempty(lutdesigner.lutfinder.LookupTableFinder.getLookupTableControls(sys,varargin{:}));
        end

        function systems=findLookupTableControlSystems(sys,varargin)



            systems=find_system(sys,...
            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
            'MatchFilter',@lutdesigner.lutfinder.matchfilter.matchSystemWithVisibleLookupTableControl,...
            'LookUnderMasks','all',varargin{:});

            systems=regexprep(systems,'\n',' ');
        end

        function lutControls=getLookupTableControls(sys,varargin)
            lutControls=Simulink.Mask.Util.getDialogControlsByType(sys,'lookuptablecontrol');
            lutControls=lutControls(arrayfun(@(c)lutctrlIsRoutine(c)&&lutctrlHasAttributes(c,varargin{:}),lutControls));
        end

        function dataProxy=getLookupTableControlDataProxy(sys,controlName)
            dataProxyBuilder=lutdesigner.lutfinder.datafinder.LookupTableControlDataProxyBuilder(sys,controlName);
            dataProxy=dataProxyBuilder.getDataProxy();
        end
    end
end

function tf=lutctrlIsRoutine(lutControl)


    tf=~xor(isempty(lutControl.Table.Name),isempty(lutControl.Breakpoints));
end

function tf=lutctrlHasAttributes(lutControl,varargin)
    tf=isempty(varargin)||all(arrayfun(@(i)strcmp(lutControl.(varargin{i}),varargin{i+1}),1:2:numel(varargin)));
end

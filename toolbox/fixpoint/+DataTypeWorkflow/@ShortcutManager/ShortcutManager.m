classdef ShortcutManager<handle




    properties(Constant,Hidden)
        CleanupShortcut=fxptui.message('lblOriginalSettings');
        DefaultFactoryNames={...
        fxptui.message('lblDblOverride'),...
        fxptui.message('lblFxptOverride'),...
        fxptui.message('lblSglOverride'),...
        fxptui.message('lblMMOOff'),...
        fxptui.message('lblDTOMMOOff'),...
        fxptui.message('lblSclDblOverride')...
        };
    end

    properties(GetAccess='private',SetAccess='private')
        ModelName='';
        ModelObject='';
FactoryShortcuts
CustomShortcuts
ShortcutOptionMap
        DefaultShortcutOptions={...
        fxptui.message('lblDblOverride'),...
        fxptui.message('lblFxptOverride'),...
        fxptui.message('lblDTOMMOOff'),...
        };
        UntranslatedFactoryNames={
        fxptui.message('lblDblOverrideUntranslated'),...
        fxptui.message('lblFxptOverrideUntranslated'),...
        fxptui.message('lblSglOverrideUntranslated'),...
        fxptui.message('lblMMOOffUntranslated'),...
        fxptui.message('lblDTOMMOOffUntranslated'),...
        fxptui.message('lblSclDblOverrideUntranslated')...
        };
        FactoryShortcutNames;
        CaptureInstrumentation=true;
        CaptureDTO=true;
        ModifyDefaultRun=true;
        IdealizedBehaviorShortcut=fxptui.message('lblDblOverride');
        FixedPointBehaviorShortcut=fxptui.message('lblFxptOverride');
        UserDefinedShortcutNames={};
        LastUsedIdealizedShortcut;
        LastUsedShortcut;
    end

    events
        UpdateCustomShortcuts;
    end

    methods
        function this=ShortcutManager(model)
            this.CustomShortcuts=Simulink.sdi.Map(double(1.0),?handle);
            this.ShortcutOptionMap=Simulink.sdi.Map(double(1.0),?handle);
            this.FactoryShortcutNames=[this.DefaultFactoryNames,this.UntranslatedFactoryNames];
            if nargin>0
                this.setModel(model);
            end
        end

        function setModel(this,modelName)
            if~isequal(this.ModelName,modelName)
                sys=find_system('type','block_diagram','Name',modelName);
                if isempty(sys)
                    [msg,identifier]=fxptui.message('modelNotLoaded',modelName);
                    e=MException(identifier,msg);
                    throwAsCaller(e);
                else
                    this.ModelName=modelName;
                    this.ModelObject=get_param(this.ModelName,'Object');
                end
                this.initFactoryShortcuts;
                this.ShortcutOptionMap.insert(get_param(this.ModelName,'Handle'),this.DefaultShortcutOptions);
                this.loadCustomShortcuts;
                this.setUserDefinedShortcutNames(this.getCustomShortcutNames);
            end
        end

        function shortcutButtons=getShortcutOptions(this)
            bd=this.ModelObject;
            if this.ShortcutOptionMap.isKey(bd.Handle)
                shortcutButtons=this.ShortcutOptionMap.getDataByKey(bd.Handle);
            else
                shortcutButtons=this.DefaultShortcutOptions;
            end

        end

        function factoryShortcuts=getFactoryShortcuts(this)
            factoryShortcuts=this.FactoryShortcuts;
        end

        function customShortcuts=getCustomShortcuts(this)
            customShortcuts=Simulink.sdi.Map(double(1.0),?handle);
            modelHandle=get_param(this.ModelName,'Handle');


            if this.CustomShortcuts.isKey(modelHandle)
                customShortcuts=this.CustomShortcuts.getDataByKey(modelHandle);
            end
        end

        function userDefinedShortcuts=getUserDefinedShortcuts(this)
            userDefinedShortcuts=this.UserDefinedShortcutNames;
        end

        function list=getCustomShortcutNames(this)


            custom_names={};
            bd=this.ModelObject;

            if this.CustomShortcuts.isKey(bd.Handle)
                customShortcutSettings=this.CustomShortcuts.getDataByKey(bd.Handle);
                for i=1:customShortcutSettings.getCount
                    custom_names{i}=customShortcutSettings.getKeyByIndex(i);
                end
            end

            list=custom_names;
        end

        function b=isFactoryShortcut(this,shortcutName)
            b=false;
            factoryNames=this.FactoryShortcutNames;
            for i=1:length(factoryNames)
                if strcmp(shortcutName,factoryNames{i})
                    b=true;
                    return;
                end
            end
        end

        function runName=getRunNameForShortcut(this,shortcutName)
            runName='';
            map=this.getGlobalSettingMapForShortcut(shortcutName);
            if map.isKey('RunName')
                runName=map.getDataByKey('RunName');
            end
        end

        function updateCustomShortcuts(this,shortcutName,action)
            evtdata=fxptui.CustomShortcutEventData(shortcutName,action);
            notify(this,'UpdateCustomShortcuts',evtdata);
        end
    end

    methods
        captureCurrentSystemSettings(this,shortcutName);
        saveShortcuts(this);
        applyShortcut(this,shortcutName);
        updateShortcutsForModelNameChange(this,mdlObj,newMdlName);

    end

    methods(Hidden)

        children=getChildrenForSystem(this,sysName);
        saveGlobalSettings(this,treeNode,batchName);
        saveSystemSettings(this,treeNode,batchName);

        function removeAllShortcutOptions(this)
            this.setShortcutButtonListForModel({});
        end

        function batchActionMap=getSettingsMapForShortcut(this,batchactionName)
            bd=get_param(this.ModelName,'Object');
            batchActionMap=[];

            if this.isFactoryShortcut(batchactionName)
                batchActionMap=this.getFactoryShortcutWithName(batchactionName);
            elseif this.CustomShortcuts.isKey(bd.Handle)
                customBatchAction=this.CustomShortcuts.getDataByKey(bd.Handle);
                if customBatchAction.isKey(batchactionName)
                    batchActionMap=customBatchAction.getDataByKey(batchactionName);
                end
            end
        end

        function sysSettingMap=getSystemSettingMapForShortcut(this,blkSID,batchName)


            bd=get_param(this.ModelName,'Object');

            blksBatchSettingMap=getSettingsMapForShortcut(this,batchName);
            if~isempty(blksBatchSettingMap)


                if blksBatchSettingMap.isKey('SystemSettingMap')
                    settingMap=blksBatchSettingMap.getDataByKey('SystemSettingMap');
                    if settingMap.isKey(blkSID)
                        sysSettingMap=settingMap.getDataByKey(blkSID);
                    else
                        sysSettingMap=Simulink.sdi.Map(char('a'),?handle);
                        settingMap.insert(blkSID,sysSettingMap);
                    end
                else
                    settingMap=Simulink.sdi.Map(char('a'),?handle);
                    sysSettingMap=Simulink.sdi.Map(char('a'),?handle);
                    settingMap.insert(blkSID,sysSettingMap);
                    blksBatchSettingMap.insert('SystemSettingMap',settingMap);
                end
            else

                blksBatchSettingMap=Simulink.sdi.Map(char('a'),?handle);

                settingMap=Simulink.sdi.Map(char('a'),?handle);

                sysSettingMap=Simulink.sdi.Map(char('a'),?handle);
                settingMap.insert(blkSID,sysSettingMap);
                blksBatchSettingMap.insert('SystemSettingMap',settingMap);


                if this.CustomShortcuts.isKey(bd.Handle)
                    customSettingMap=this.CustomShortcuts.getDataByKey(bd.Handle);
                    customSettingMap.insert(batchName,blksBatchSettingMap);
                else
                    customSettingMap=Simulink.sdi.Map(char('a'),?handle);
                    customSettingMap.insert(batchName,blksBatchSettingMap);
                end
                this.CustomShortcuts.insert(get_param(this.ModelName,'Handle'),customSettingMap);
            end
            blksBatchSettingMap.insert('TopModelName',this.ModelName);
        end

        function setShortcutButtonListForModel(this,BatchActionButtons)




            this.ShortcutOptionMap.insert(get_param(this.ModelName,'Handle'),BatchActionButtons)
        end

        function mdlSettingMap=getGlobalSettingMapForShortcut(this,batchName)



            bd=get_param(this.ModelName,'Object');

            blksBatchSettingMap=this.getSettingsMapForShortcut(batchName);
            if~isempty(blksBatchSettingMap)


                if blksBatchSettingMap.isKey('GlobalModelSettings')
                    mdlSettingMap=blksBatchSettingMap.getDataByKey('GlobalModelSettings');
                else
                    mdlSettingMap=Simulink.sdi.Map(char('a'),?handle);
                    blksBatchSettingMap.insert('GlobalModelSettings',mdlSettingMap);
                end
            else

                blksBatchSettingMap=Simulink.sdi.Map(char('a'),?handle);


                mdlSettingMap=Simulink.sdi.Map(char('a'),?handle);
                blksBatchSettingMap.insert('GlobalModelSettings',mdlSettingMap);


                if this.CustomShortcuts.isKey(bd.Handle)
                    customSettingMap=this.CustomShortcuts.getDataByKey(bd.Handle);
                    customSettingMap.insert(batchName,blksBatchSettingMap);
                else
                    customSettingMap=Simulink.sdi.Map(char('a'),?handle);
                    customSettingMap.insert(batchName,blksBatchSettingMap);
                end
                this.CustomShortcuts.insert(bd.Handle,customSettingMap);
            end
        end

        function customBatchActionMap=getCustomShortcutMapForModel(this)

            bd=this.ModelObject;
            if this.CustomShortcuts.isKey(bd.Handle)
                customBatchActionMap=this.CustomShortcuts.getDataByKey(bd.Handle);
            else
                customBatchActionMap=Simulink.sdi.Map(char('a'),?handle);
                this.CustomShortcuts.insert(bd.Handle,customBatchActionMap)
            end
        end

        function list=getShortcutNames(this)


            factory_names={};
            for i=1:this.FactoryShortcuts.getCount
                factory_names{i}=this.FactoryShortcuts.getKeyByIndex(i);%#ok<*AGROW>
            end


            custom_names=this.getCustomShortcutNames();

            list=[factory_names,custom_names];
        end

        function idealizedBehaviorShortcut=getIdealizedBehaviorShortcut(this)


            idealizedBehaviorShortcut=this.IdealizedBehaviorShortcut;
        end

        function fixedPointBehaviorShortcut=getFixedPointBehaviorShortcut(this)


            fixedPointBehaviorShortcut=this.FixedPointBehaviorShortcut;
        end

        function applyIdealizedShortcut(this)
            this.applyShortcut(this.IdealizedBehaviorShortcut);
            this.LastUsedShortcut=this.IdealizedBehaviorShortcut;
        end

        function applyVerificationShortcut(this)
            this.applyShortcut(this.FixedPointBehaviorShortcut);
            this.LastUsedShortcut=this.FixedPointBehaviorShortcut;
        end

        function applyCleanupShortcut(this)
            this.applyShortcut(this.CleanupShortcut);
            this.LastUsedShortcut=this.CleanupShortcut;
        end

        function setIdealizedShortcut(this,shortcutName)





            switch shortcutName
            case 'DoubleOverride'
                shortcutName=fxptui.message('lblDblOverride');
            case 'SingleOverride'
                shortcutName=fxptui.message('lblSglOverride');
            case 'ScaledDoubles'
                shortcutName=fxptui.message('lblSclDblOverride');
            case 'SpecifiedType'
                shortcutName=fxptui.message('lblFxptOverride');
            end
            this.IdealizedBehaviorShortcut=shortcutName;
        end

        function setVerifyShortcut(this,shortcutName)
            switch shortcutName
            case 'SpecifiedType'
                shortcutName=fxptui.message('lblFxptOverride');
            end
            this.FixedPointBehaviorShortcut=shortcutName;
        end

        function shortcutName=getLastUsedShortcut(this)

            shortcutName=this.LastUsedShortcut;
        end

        function shortcutName=getTranslatedShortcut(~,shortcutName)



            switch shortcutName
            case fxptui.message('lblDblOverrideUntranslated')
                shortcutName=fxptui.message('lblDblOverride');
            case fxptui.message('lblFxptOverrideUntranslated')
                shortcutName=fxptui.message('lblFxptOverride');
            case fxptui.message('lblSglOverrideUntranslated')
                shortcutName=fxptui.message('lblSglOverride');
            case fxptui.message('lblSclDblOverrideUntranslated')
                shortcutName=fxptui.message('lblSclDblOverride');
            case fxptui.message('lblMMOOffUntranslated')
                shortcutName=fxptui.message('lblMMOOff');
            case fxptui.message('lblDTOMMOOffUntranslated')
                shortcutName=fxptui.message('lblDTOMMOOff');
            end
        end

        function setUserDefinedShortcutNames(this,shortcutNames)
            this.UserDefinedShortcutNames=shortcutNames;
        end
    end

    methods(Access='private')
        initFactoryShortcuts(this);
        loadCustomShortcuts(this);
    end

    methods(Access='private')
        function blkSID=createSIDFromPathTrace(this,topModelPathTrace)


            topModelName=this.ModelName;
            blkSID=[topModelName,topModelPathTrace{1}];
            for i=2:length(topModelPathTrace)
                daobj=get_param(Simulink.ID.getHandle(blkSID),'Object');
                mdlName=daobj.ModelName;
                blkSID=[mdlName,topModelPathTrace{i}];
            end
            daobj=get_param(Simulink.ID.getHandle(blkSID),'Object');
            blkSID=daobj.ModelName;
        end

        function factoryShortcut=getFactoryShortcutWithName(this,shortcutName)
            switch shortcutName
            case{fxptui.message('lblDblOverride'),fxptui.message('lblDblOverrideUntranslated')}
                factoryShortcut=this.FactoryShortcuts.getDataByKey(fxptui.message('lblDblOverride'));
            case{fxptui.message('lblFxptOverride'),fxptui.message('lblFxptOverrideUntranslated')}
                factoryShortcut=this.FactoryShortcuts.getDataByKey(fxptui.message('lblFxptOverride'));
            case{fxptui.message('lblSglOverride'),fxptui.message('lblSglOverrideUntranslated')}
                factoryShortcut=this.FactoryShortcuts.getDataByKey(fxptui.message('lblSglOverride'));
            case{fxptui.message('lblMMOOff'),fxptui.message('lblMMOOffUntranslated')}
                factoryShortcut=this.FactoryShortcuts.getDataByKey(fxptui.message('lblMMOOff'));
            case{fxptui.message('lblDTOMMOOff'),fxptui.message('lblDTOMMOOffUntranslated')}
                factoryShortcut=this.FactoryShortcuts.getDataByKey(fxptui.message('lblDTOMMOOff'));
            case{fxptui.message('lblSclDblOverride'),fxptui.message('lblSclDblOverrideUntranslated')}
                factoryShortcut=this.FactoryShortcuts.getDataByKey(fxptui.message('lblSclDblOverride'));
            otherwise
                factoryShortcut=[];
            end
        end

        function changeToLocalSettings(this)



            [refMdls,~]=find_mdlrefs(this.ModelName,...
            'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices);

            for i=1:length(refMdls)
                load_system(refMdls{i});
                if this.CaptureDTO
                    fxptui.updateToUseLocalSettings(refMdls{i},'DataTypeOverride');
                end
                if this.CaptureInstrumentation
                    fxptui.updateToUseLocalSettings(refMdls{i},'MinMaxOverflowLogging');
                end
            end
        end
    end
end

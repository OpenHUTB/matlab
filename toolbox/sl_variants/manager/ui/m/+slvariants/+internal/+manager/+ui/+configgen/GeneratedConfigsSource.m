classdef(Sealed)GeneratedConfigsSource<handle





    properties(Access=private)

        GeneratedVCD Simulink.VariantConfigurationData;

        ConfigsInfo;

        ConfigRows(1,:)slvariants.internal.manager.ui.configgen.GeneratedConfigsRow;

        ModelName(1,:)char;
    end

    methods
        function obj=GeneratedConfigsSource(generatedVCD,configsInfo,bdName)
            obj.GeneratedVCD=generatedVCD;
            obj.ConfigsInfo=configsInfo;
            obj.ModelName=bdName;
            obj.enableOrDisableAddSelectedButton();
        end

        function delete(obj)
            obj.ConfigRows.delete();
        end

        function vcd=getGeneratedVCD(obj)
            vcd=obj.GeneratedVCD;
        end

        function children=getChildren(obj,~)
            numOfConfigs=numel(obj.GeneratedVCD.getConfigurations());
            if isempty(obj.ConfigRows)&&numOfConfigs>0
                obj.ConfigRows(1,numOfConfigs)=slvariants.internal.manager.ui.configgen.GeneratedConfigsRow;
                for idx=1:numOfConfigs
                    config=obj.GeneratedVCD.Configurations(idx);
                    configInfoStruct=obj.ConfigsInfo(idx);
                    Simulink.variant.utils.assert(isequal(config.Name,configInfoStruct.Name),"Config info not found in order");
                    obj.ConfigRows(idx)=slvariants.internal.manager.ui.configgen.GeneratedConfigsRow(idx,config,configInfoStruct.ValidityStatus,obj);
                end
            end
            children=obj.ConfigRows;
        end

        function success=changeConfigName(obj,oldConfigName,newConfigName)
            if isempty(newConfigName)

                success=false;
                return;
            end

            existingCfgNames=obj.GeneratedVCD.getConfigurationNames();
            if ismember(newConfigName,existingCfgNames)

                success=false;
                return;
            end

            obj.GeneratedVCD.setConfigurationName(oldConfigName,newConfigName);
            success=true;
        end

        function enableAddSelectedBtn=canAddSelectedButtonEnabled(obj)

            childRows=obj.getChildren();
            enableAddSelectedBtn=false;
            for idx=1:numel(childRows)
                if childRows(idx).getIsSelected()
                    enableAddSelectedBtn=true;
                    break;
                end
            end
        end

        function enableOrDisableAddSelectedButton(obj)
            slvariants.internal.manager.ui.configgen.refreshToolStripActions(obj.ModelName);
        end

        function selectAllConfigs(obj)
            import slvariants.internal.manager.ui.config.VMgrConstants;
            for idx=1:numel(obj.ConfigRows)
                obj.ConfigRows(idx).setPropValue(VMgrConstants.SelectCol,'1');
            end
        end

        function deselectAllConfigs(obj)
            import slvariants.internal.manager.ui.config.VMgrConstants;
            for idx=1:numel(obj.ConfigRows)
                obj.ConfigRows(idx).setPropValue(VMgrConstants.SelectCol,'0');
            end
        end
    end
end

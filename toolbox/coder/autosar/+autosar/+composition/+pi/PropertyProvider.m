classdef PropertyProvider<handle





    properties(Constant,Hidden)
        AUTOSARPropertyTagNames={'AUTOSAR:ComponentKind',...
        'AUTOSAR:ExportedCompositionName',...
        'AUTOSAR:PortDataType',...
        'AUTOSAR:PortKind'};
    end

    properties(Constant,Access=private)
        DefaultPropSpec=struct('Tag','','DisplayLabel','',...
        'AppliesTo','');
    end

    methods(Static)
        function propSpecs=getAUTOSARPropertySpecs()
            propSpecs=horzcat(autosar.composition.pi.PropertyProvider.getCompBlockPropertySpecs,...
            autosar.composition.pi.PropertyProvider.getArchModelPropertySpecs,...
            autosar.composition.pi.PropertyProvider.getPortPropertySpecs);
        end

        function propSpecs=getCompBlockPropertySpecs()
            import autosar.composition.pi.PropertyProvider
            propCompKind=autosar.composition.pi.PropertyProvider.DefaultPropSpec;
            propCompKind.Tag='AUTOSAR:ComponentKind';
            propCompKind.DisplayLabel=PropertyProvider.getPropertyDisplayLabel(propCompKind.Tag);
            propCompKind.AppliesTo='CompBlock';


            propSpecs=propCompKind;
        end

        function propSpecs=getArchModelPropertySpecs()
            import autosar.composition.pi.PropertyProvider
            propExportedCompositionName=autosar.composition.pi.PropertyProvider.DefaultPropSpec;
            propExportedCompositionName.Tag='AUTOSAR:ExportedCompositionName';
            propExportedCompositionName.DisplayLabel=PropertyProvider.getPropertyDisplayLabel(propExportedCompositionName.Tag);
            propExportedCompositionName.AppliesTo='ArchModel';


            propSpecs=propExportedCompositionName;
        end

        function propSpecs=getPortPropertySpecs()
            import autosar.composition.pi.PropertyProvider

            portDataType=autosar.composition.pi.PropertyProvider.DefaultPropSpec;
            portDataType.Tag='AUTOSAR:PortDataType';
            portDataType.DisplayLabel=PropertyProvider.getPropertyDisplayLabel(portDataType.Tag);
            portDataType.AppliesTo='PortBlock';

            portKind=autosar.composition.pi.PropertyProvider.DefaultPropSpec;
            portKind.Tag='AUTOSAR:PortKind';
            portKind.DisplayLabel=PropertyProvider.getPropertyDisplayLabel(portKind.Tag);
            portKind.AppliesTo='PortBlock';


            propSpecs=[portDataType,portKind];
        end

        function enabled=isPropertyEnabled(blkH,prop)
            switch(prop)
            case 'AUTOSAR:ComponentKind'
                if autosar.composition.Utils.isComponentBlock(blkH)&&...
                    ~Simulink.CodeMapping.isAutosarAdaptiveSTF(getfullname(bdroot(blkH)))
                    enabled=~autosar.composition.Utils.isCompBlockLinked(blkH);
                else


                    enabled=false;
                end
            case 'AUTOSAR:ExportedCompositionName'
                enabled=true;
            case 'AUTOSAR:PortDataType'
                component=get_param(blkH,'Parent');
                isPortBlockOwnerLinkedComponent=strcmp(get_param(component,'type'),'block_diagram')&&...
                ~autosar.composition.Utils.isModelInCompositionDomain(component);
                enabled=~isPortBlockOwnerLinkedComponent;
            case 'AUTOSAR:PortKind'
                enabled=false;
            otherwise
                assert(false,'Unrecognized AUTOSAR property: %s',prop);
            end
        end

        function editor=getPropertyEditor(blkH,prop)
            switch(prop)
            case 'AUTOSAR:ComponentKind'
                editor=DAStudio.UI.Widgets.ComboBox;
                editor.CurrentText=autosar.composition.pi.PropertyProvider.getPropertyValue(blkH,prop);
                if Simulink.CodeMapping.isAutosarAdaptiveSTF(getfullname(bdroot(blkH)))
                    editor.Entries={'AdaptiveApplication'};
                else
                    editor.Entries=autosar.composition.Utils.getSupportedComponentKinds();
                end
            case 'AUTOSAR:ExportedCompositionName'
                editor=DAStudio.UI.Widgets.Edit;
                editor.Text=...
                autosar.composition.pi.PropertyHandler.getPropertyValue(...
                blkH,'ComponentName');
            case 'AUTOSAR:PortDataType'
                editor=DAStudio.UI.Widgets.ComboBox;
                editor.CurrentText=autosar.composition.pi.PropertyProvider.getPropertyValue(...
                blkH,'AUTOSAR:PortDataType');


                dts=slprivate('slGetUserDataTypesFromWSDD',...
                get_param(blkH,'Object'),[],[],true);
                dts=dts(startsWith(dts,'Bus:'));

                editor.Entries=[{'Inherit: auto'},dts];
            otherwise
                assert(false,'Unrecognized AUTOSAR property: %s',prop);
            end
        end

        function value=getPropertyValue(blkH,prop)


            switch(prop)
            case{'AUTOSAR:ComponentKind','AUTOSAR:ExportedCompositionName'}
                if strcmp(prop,'AUTOSAR:ExportedCompositionName')

                    prop='ComponentName';
                else
                    prop=strrep(prop,'AUTOSAR:','');
                end
                value=autosar.composition.pi.PropertyHandler.getPropertyValue(...
                blkH,prop);
            case 'AUTOSAR:PortDataType'
                value=autosar.simulink.bep.Utils.getParam(...
                blkH,true,'OutDataTypeStr');
            case 'AUTOSAR:PortKind'
                if autosar.composition.Utils.isDataSenderPort(blkH)
                    value='Sender';
                else
                    value='Receiver';
                end
            otherwise
                assert(false,'Unrecognized AUTOSAR property: %s',prop);
            end
        end

        function setPropertyValue(blkH,prop,newValue)


            switch(prop)
            case{'AUTOSAR:ComponentKind','AUTOSAR:ExportedCompositionName'}

                if strcmp(prop,'AUTOSAR:ExportedCompositionName')

                    prop='ComponentName';
                else
                    prop=strrep(prop,'AUTOSAR:','');
                end
                autosar.composition.pi.PropertyHandler.setPropertyValue(...
                blkH,prop,newValue);
            case 'AUTOSAR:PortDataType'
                autosar.simulink.bep.Utils.setParam(...
                blkH,true,'OutDataTypeStr',newValue);
            otherwise
                assert(false,'Unrecognized AUTOSAR property: %s',prop);
            end


        end

        function mode=getPropertyRenderMode(prop)
            switch prop
            case{'AUTOSAR:ComponentKind','AUTOSAR:PortDataType'}
                mode='RenderAsComboBox';
            case{'AUTOSAR:ExportedCompositionName','AUTOSAR:PortKind'}
                mode='RenderAsText';
            otherwise
                assert(false,'Unrecognized AUTOSAR property: %s',prop);
            end
        end

        function label=getPropertyDisplayLabel(prop)
            switch prop
            case{'AUTOSAR:ComponentKind','AUTOSAR:PortKind'}
                label=DAStudio.message('autosarstandard:ui:uiCommonKind');
            case 'AUTOSAR:ExportedCompositionName'
                label=DAStudio.message('autosarstandard:studio:ExportedCompositionName');
            case 'AUTOSAR:PortDataType'
                label=DAStudio.message('SystemArchitecture:PropertyInspector:Interface');
            otherwise
                assert(false,'Unrecognized AUTOSAR property: %s',prop);
            end
        end
    end
end



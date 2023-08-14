classdef ComponentAdapter<handle






    properties
        MappingKey;
    end

    properties(SetAccess=immutable,GetAccess=protected)
        ModelName;
    end

    properties(Dependent)
        MaxShortNameLength;
    end

    methods
        function this=ComponentAdapter(mdlName)
            this.ModelName=mdlName;
        end

        function maxShortNameLength=get.MaxShortNameLength(this)
            maxShortNameLength=get_param(this.ModelName,'AutosarMaxShortNameLength');
        end
    end

    methods(Abstract)
        portName=getAutosarPortName(slPortBlk);
        elmName=getAutosarElementName(slPortBlk);
        intfName=getAutosarInterfaceName(slPortBlk)
        mapM3iComponent(this,m3iComp);
    end

    methods(Access=protected)
        function portName=derivePortNameFromSlPortName(this,slPortBlk)

            portName=get_param(slPortBlk,'PortName');
            if~autosarcore.checkIdentifier(portName,'shortname',this.MaxShortNameLength)

                portName=arxml.arxml_private('p_create_aridentifier',...
                arblk.convertPortNameToArgName(portName),this.MaxShortNameLength);
            end
        end

        function intfName=deriveAutosarInterfaceName(this,slPortBlk)
            if strcmp(get_param(slPortBlk,'isBusElementPort'),'on')&&...
                autosar.simulink.bep.Utils.isBEPUsingBusObject(slPortBlk)


                [~,busObjName]=autosar.simulink.bep.Utils.isBEPUsingBusObject(slPortBlk);
                intfName=busObjName;
            else
                intfName=this.derivePortNameFromSlPortName(slPortBlk);
            end
        end

        function elmName=deriveElementNameFromSlPortName(this,slPortBlk)
            if strcmp(get_param(slPortBlk,'isBusElementPort'),'on')

                elmName=get_param(slPortBlk,'Element');
                if~autosarcore.checkIdentifier(elmName,'shortname',this.MaxShortNameLength)

                    elmName=arxml.arxml_private('p_create_aridentifier',...
                    arblk.convertPortNameToArgName(elmName),this.MaxShortNameLength);
                end
            else
                elmName=this.derivePortNameFromSlPortName(slPortBlk);
            end
        end
    end

    methods(Static)
        function componentAdapter=getComponentAdapter(modelName,isAdaptive)
            if nargin<2
                isAdaptive=Simulink.CodeMapping.isAutosarAdaptiveSTF(modelName);
            end
            if isAdaptive
                componentAdapter=autosar.ui.wizard.builder.AdaptiveComponentAdapter(modelName);
            else
                componentAdapter=autosar.ui.wizard.builder.ClassicComponentAdapter(modelName);
            end
        end
    end
end



classdef AdaptiveComponentAdapter<autosar.ui.wizard.builder.ComponentAdapter






    methods

        function this=AdaptiveComponentAdapter(mdlName)
            this@autosar.ui.wizard.builder.ComponentAdapter(mdlName);
            this.MappingKey='AutosarTargetCPP';
        end


        function portName=getAutosarPortName(this,slPortBlk)
            if strcmp(get_param(slPortBlk,'IsComposite'),'off')
                portName=this.getDefaultPortName(slPortBlk);
            else
                portName=this.derivePortNameFromSlPortName(slPortBlk);
            end
        end

        function elmName=getAutosarElementName(this,slPortBlk)
            elmName=this.deriveElementNameFromSlPortName(slPortBlk);
            if strcmp(get_param(slPortBlk,'isBusElementPort'),'on')


            else



                elmName(1)=upper(elmName(1));
            end
        end


        function interfaceName=getAutosarInterfaceName(this,slPortBlk)
            if strcmp(get_param(slPortBlk,'isBusElementPort'),'off')
                if strcmp(get_param(slPortBlk,'BlockType'),'Inport')
                    interfaceName=autosar.ui.metamodel.PackageString.DefaultRequiredServiceInterfaceName;
                else
                    interfaceName=autosar.ui.metamodel.PackageString.DefaultProvidedServiceInterfaceName;
                end
            else
                interfaceName=this.deriveAutosarInterfaceName(slPortBlk);
            end
        end

        function mapM3iComponent(this,m3iComp)


            assert(isa(m3iComp,autosar.ui.metamodel.PackageString.ComponentsCell{4}),...
            'Component should be AdaptiveApplication');


            mapping=autosar.api.Utils.modelMapping(this.ModelName);
            assert(~isempty(mapping));


            componentId=m3iComp.qualifiedName;
            appObj=Simulink.AutosarTarget.Application(componentId,m3iComp.Name);


            mapping.mapApplication(appObj);
        end
    end

    methods(Static,Access=public)
        function methodName=getAutosarMethodName(fcnName)
            if contains(fcnName,'.')
                tokens=strsplit(fcnName,'.');
                assert(length(tokens),2,'Expected two names from caller');
                methodName=tokens{2};
                methodName=autosar.simulink.functionPorts.Utils.escapeBrackets(methodName);
            else
                methodName=fcnName;
            end
        end
    end

    methods(Static,Access=private)
        function portName=getDefaultPortName(slPortBlk)
            if strcmp(get_param(slPortBlk,'BlockType'),'Inport')
                portName=autosar.ui.metamodel.PackageString.DefaultRequiredPortName;
            else
                portName=autosar.ui.metamodel.PackageString.DefaultProvidedPortName;
            end

            modelH=get_param(slPortBlk,'Parent');
            csPortHs=[autosar.simulink.functionPorts.Utils.findClientPorts(modelH);...
            autosar.simulink.functionPorts.Utils.findServerPorts(modelH)];
            csPortNames=unique(get_param(csPortHs,'PortName'));
            startingPortName=portName;
            idx=1;
            while ismember(portName,csPortNames)

                portName=[startingPortName,'_',num2str(idx)];
            end
        end
    end
end



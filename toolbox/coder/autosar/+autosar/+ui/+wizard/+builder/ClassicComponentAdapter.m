classdef ClassicComponentAdapter<autosar.ui.wizard.builder.ComponentAdapter






    methods

        function this=ClassicComponentAdapter(mdlName)
            this@autosar.ui.wizard.builder.ComponentAdapter(mdlName);
            this.MappingKey='AutosarTarget';
        end


        function portName=getAutosarPortName(this,slPortBlk)
            portName=this.derivePortNameFromSlPortName(slPortBlk);
        end

        function elementName=getAutosarElementName(this,slPortBlk)
            elementName=this.deriveElementNameFromSlPortName(slPortBlk);
        end

        function interfaceName=getAutosarInterfaceName(this,slPortBlk)
            interfaceName=this.deriveAutosarInterfaceName(slPortBlk);
        end

        function mapM3iComponent(this,m3iComp)


            assert(isa(m3iComp,autosar.ui.metamodel.PackageString.ComponentsCell{1}),...
            'Component should be Atomic Component');


            mapping=autosar.api.Utils.modelMapping(this.ModelName);
            assert(~isempty(mapping));


            componentId=m3iComp.qualifiedName;
            compObj=Simulink.AutosarTarget.Component(componentId,m3iComp.Name);


            mapping.mapComponent(compObj);
        end
    end
end



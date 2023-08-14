classdef SLModelXmlOptionsModifier<autosar.ui.xmlOptions.XmlOptionsModifier





    properties(Access=private)
        ModelName;
        ApiObj autosar.api.getAUTOSARProperties;
    end

    methods(Static,Access=public)
        function modifier=getModifier(modelName,dialog,m3iModel)


            if autosar.api.Utils.isMappedToComponent(modelName)||...
                autosar.api.Utils.isMappedToAdaptiveApplication(modelName)
                modifier=autosar.ui.xmlOptions.ComponentModelXmlOptionsModifier(...
                modelName,dialog,m3iModel);
            else
                assert(autosar.api.Utils.isMappedToComposition(modelName),...
                'Expected to only get here for compositions');
                modifier=autosar.ui.xmlOptions.ArchitectureModelXmlOptionsModifier(...
                modelName,dialog,m3iModel);
            end
        end
    end

    methods(Access=protected)
        function this=SLModelXmlOptionsModifier(modelName,dialog,m3iModel)

            this@autosar.ui.xmlOptions.XmlOptionsModifier(dialog,m3iModel);

            this.ModelName=modelName;
            this.ApiObj=autosar.api.getAUTOSARProperties(this.ModelName,true);
        end

        function value=getXmlOptionValue(this,optionName)
            value=this.ApiObj.get('XmlOptions',optionName);
        end

        function setXmlOption(this,optionName,newValue)
            this.ApiObj.set('XmlOptions',optionName,newValue,...
            'MoveElements',this.MoveElementsMode);
        end
    end
end

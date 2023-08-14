classdef(Sealed)CustomLayerClassValidator<dltargets.internal.compbuilder.CodegenLayerValidator




    methods(Access=public)


        function obj=CustomLayerClassValidator(net,dlcfg,layerInfoMap,isCnnCodegenWorkflow,errorHandler)
            obj=obj@dltargets.internal.compbuilder.CodegenLayerValidator(...
            net,dlcfg,layerInfoMap,isCnnCodegenWorkflow,errorHandler);
        end

        function validate(obj)
            for i=1:numel(obj.layers)
                coder.internal.ctarget.layerClassBuilder.CustomLayerClassBuilder.doValidate(obj.layers(i),obj);
            end
        end

    end
end


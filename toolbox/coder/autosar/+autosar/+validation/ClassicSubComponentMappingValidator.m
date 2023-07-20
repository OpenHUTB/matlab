classdef ClassicSubComponentMappingValidator





    methods(Static,Access=public)

        function validate(hModel)

            [isMapped,mapping]=autosarcore.ModelUtils.isMappedToComponent(hModel);

            if~isMapped||~mapping.IsSubComponent
                return;
            end





            numInstances=get_param(bdroot,'ModelReferenceNumInstancesAllowed');

            if~strcmp(numInstances,'Multi')

                isInvalidMapping=any(arrayfun(@(x)isequal(x.MappedTo.ArDataRole,'PerInstanceParameter'),mapping.ModelScopedParameters))...
                ||any(arrayfun(@(x)isequal(x.MappedTo.ArDataRole,'ArTypedPerInstanceMemory'),mapping.Signals))...
                ||any(arrayfun(@(x)isequal(x.MappedTo.ArDataRole,'ArTypedPerInstanceMemory'),mapping.States))...
                ||any(arrayfun(@(x)isequal(x.MappedTo.ArDataRole,'ArTypedPerInstanceMemory'),mapping.DataStores));

                if isInvalidMapping
                    autosar.validation.Validator.logError('RTW:autosar:invalidMappedToForSingleInstanceSubComponent');
                end
            end
        end
    end
end




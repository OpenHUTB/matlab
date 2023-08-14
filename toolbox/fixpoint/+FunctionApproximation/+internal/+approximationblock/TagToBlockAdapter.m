classdef TagToBlockAdapter<handle







    methods
        function variantSystemHandle=getSubSystemHandle(~,variantSystemTag)

            variantSystemHandle=[];
            schema=FunctionApproximation.internal.approximationblock.BlockSchema();


            models=find_system('Type','block_diagram');
            subSystemHandles=[];
            for iModel=1:numel(models)
                localHandles=Simulink.findBlocksOfType(models{iModel},'SubSystem');
                subSystemHandles=[subSystemHandles;localHandles(:)];%#ok<AGROW>
            end




            for iSub=1:numel(subSystemHandles)
                localHandle=subSystemHandles(iSub);
                if FunctionApproximation.internal.approximationblock.isCreatedByFunctionApproximation(localHandle)
                    maskObject=Simulink.Mask.get(localHandle);
                    parameters=maskObject.Parameters;
                    v=parameters(strcmp(schema.VariantTagParameterName,{parameters.Name})).Value;
                    if strcmp(v,variantSystemTag)
                        variantSystemHandle=localHandle;
                        break;
                    end
                end
            end
        end

        function variantHandle=getVariantHandle(~,variantSystemHandle,variantTag)



            variantChoices=get(variantSystemHandle,'Variants');
            for iChoice=1:numel(variantChoices)
                variant=variantChoices(iChoice);
                if strcmp(get_param(variant.BlockName,'Tag'),variantTag)
                    variantHandle=get_param(variant.BlockName,'Handle');
                    break;
                end
            end
        end
    end
end

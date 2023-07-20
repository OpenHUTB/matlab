classdef LayerSpecificationBuilder<dltargets.internal.quantization.specificationbuilder.SpecificationBuilder







    properties(SetAccess=private)
SpecificationAdapter
LayerIndexNameMap
    end

    methods
        function obj=LayerSpecificationBuilder(adapter,dltIdxToLayerNameMap)
            obj.SpecificationAdapter=adapter;
            obj.LayerIndexNameMap=dltIdxToLayerNameMap;
        end

        function spec=build(obj)







            p=dnn_pir;
            comps=p.getTopNetwork.Components();






            exponentStruct([])=struct('Name',[],'Exponent',[]);


            structIdx=1;

            for idx=1:numel(comps)

                compKey=comps(idx).getCompKey;

                fusedDLTIndices=sort(comps(idx).getFusedDLTLayerIndicesForMatlab);


                fusedDLTIndices=fusedDLTIndices(fusedDLTIndices>-1);

                if(isempty(fusedDLTIndices)&&strcmpi(compKey,'gpucoder.elementwise_affine_layer_comp'))







                    fusedDLTIndices=comps(idx).getDLTActivationLayerIndex();
                end

                if strcmpi(compKey,'gpucoder.output_layer_comp')...
                    ||(isempty(fusedDLTIndices))
                    exponentStruct(structIdx).Name=comps(idx).getName;
                    exponentStruct(structIdx).Exponent=0;
                    structIdx=structIdx+1;
                    continue;
                end

                fusedDLTLayerNames=arrayfun(@(fusedIndex)obj.LayerIndexNameMap(fusedIndex),fusedDLTIndices,'UniformOutput',false);

                switch compKey
                case{'gpucoder.conv_layer_comp',...
                    'gpucoder.fused_conv_activation_layer_comp',...
                    'gpucoder.fc_layer_comp'}





                    exponentStruct(structIdx).Name=comps(idx).getName;
                    exponentStruct(structIdx).Exponent=obj.SpecificationAdapter.getActivationsExponent(fusedDLTLayerNames);

                    structIdx=structIdx+1;


                    exponentStruct(structIdx).Name=strcat(comps(idx).getName,'_','Weights');
                    exponentStruct(structIdx).Exponent=obj.SpecificationAdapter.getWeightsExponent(fusedDLTLayerNames);

                    structIdx=structIdx+1;


                    exponentStruct(structIdx).Name=strcat(comps(idx).getName,'_','Bias');
                    exponentStruct(structIdx).Exponent=obj.SpecificationAdapter.getBiasExponent(fusedDLTLayerNames);

                    structIdx=structIdx+1;
                case 'gpucoder.batch_norm_layer_comp'



                    if obj.SpecificationAdapter.hasActivationsValue(fusedDLTLayerNames{1})



                        exponentStruct(structIdx).Name=comps(idx).getName;
                        exponentStruct(structIdx).Exponent=obj.SpecificationAdapter.getActivationsExponent(fusedDLTLayerNames);

                        structIdx=structIdx+1;
                    else



                        continue;
                    end


                otherwise




                    exponentStruct(structIdx).Name=comps(idx).getName;
                    exponentStruct(structIdx).Exponent=obj.SpecificationAdapter.getActivationsExponent(fusedDLTLayerNames);

                    structIdx=structIdx+1;

                    if obj.SpecificationAdapter.hasParameterValue(fusedDLTLayerNames)

                        exponentStruct(structIdx).Name=strcat(comps(idx).getName,'_','Parameter');
                        exponentStruct(structIdx).Exponent=obj.SpecificationAdapter.getParameterExponent(fusedDLTLayerNames);

                        structIdx=structIdx+1;
                    end


                end


                obj.SpecificationAdapter=obj.SpecificationAdapter.setSkipLayer(fusedDLTLayerNames,compKey,comps(idx).getName);

            end

            skipLayers=obj.SpecificationAdapter.getSkipLayers();


            spec=struct('exponentsData',exponentStruct,'skipLayers',skipLayers,'quantizedDLNetwork',true);
        end
    end

end



function builder = getSpecificationBuilder( networkInfo, options )

arguments
    networkInfo
    options.GenerateExponents = false;
end

layerSpecMap = networkInfo.LayerExecutionSpecification;
isQuantizedNetworkSpecification = deep.internal.quantization.isCompositeQuantizationEnabled( layerSpecMap );

isDLQuantizerSpecification = ~isempty( networkInfo.DLQuantizerContext );

if ~( isQuantizedNetworkSpecification || isDLQuantizerSpecification )
    builder = dltargets.internal.quantization.specificationbuilder.NullSpecificationBuilder(  );
    return ;
end

if isQuantizedNetworkSpecification
    specAdapter = dltargets.internal.quantization.specificationadapter.CompositeSpecificationAdapter( layerSpecMap );
    builder = dltargets.internal.quantization.specificationbuilder.LayerSpecificationBuilder( specAdapter, networkInfo.OriginalDLTIdxToLayerNameMap );
    return ;
end

if networkInfo.DLQuantizerContext.hasGenericCalibrationStatistics

    if options.GenerateExponents
        specAdapter = dltargets.internal.quantization.specificationadapter.TableSpecificationAdapter( networkInfo.DLQuantizerContext );
        builder = dltargets.internal.quantization.specificationbuilder.LayerSpecificationBuilder( specAdapter, networkInfo.OriginalDLTIdxToLayerNameMap );
    else
        builder = dltargets.internal.quantization.specificationbuilder.DefaultQuantizationSpecificationBuilder(  );
    end
else
    builder = dltargets.internal.quantization.specificationbuilder.DLQuantizerSpecificationBuilder( networkInfo.DLQuantizerContext );
end

end




















function quantizationSpec=processQuantizationSpec(networkInfo)
    specBuilder=dltargets.internal.quantization.getSpecificationBuilder(networkInfo,GenerateExponents=true);
    quantizationSpec=specBuilder.build();
end



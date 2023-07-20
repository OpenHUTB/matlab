









function comp=createAndSetElementwiseAffineLayerComp(this,layer)



    compKind=dltargets.internal.compbuilder.ElementwiseAffineCompBuilder.getCompKind();
    newLayerName=[layer.Name,'_normalization'];
    comp=dltargets.internal.compbuilder.CodegenCompBuilder.addComponentToNetwork(...
    this.CodegenInfo.hN,compKind,newLayerName);


    comp.setCompKey('gpucoder.elementwise_affine_layer_comp');

    layerInfo=this.CodegenInfo.NetworkInfo.getLayerInfo(layer.Name);


    dltargets.internal.setCompOutputDimensions(layerInfo.outputSizes,layerInfo.outputFormats,comp);


    comp.setScaleHeight(size(this.scale,1));
    comp.setScaleWidth(size(this.scale,2));
    comp.setScaleChannels(size(this.scale,3));
    comp.setOffsetHeight(size(this.offset,1));
    comp.setOffsetWidth(size(this.offset,2));
    comp.setOffsetChannels(size(this.offset,3));


    if strcmpi(layer.Normalization,'rescale-symmetric')
        comp.setIsClippedAffine(logical(1));%#ok
        comp.setLowerBound(-1);
        comp.setUpperBound(1);
    elseif strcmpi(layer.Normalization,'rescale-zero-one')
        comp.setIsClippedAffine(logical(1));%#ok
        comp.setLowerBound(0);
        comp.setUpperBound(1);
    end


    filePrefix=strcat('cnn_',this.CodegenInfo.netname,'_');
    scaleFileNamePostfix='_scale';
    offsetFileNamePostfix='_offset';
    scaleFileName=strcat(filePrefix,layer.Name,scaleFileNamePostfix);
    offsetFileName=strcat(filePrefix,layer.Name,offsetFileNamePostfix);

    comp.setScaleFile(igetCompFileName(scaleFileName,this.CodegenInfo.codegendir,this.CodegenInfo.codegentarget));
    comp.setOffsetFile(igetCompFileName(offsetFileName,this.CodegenInfo.codegendir,this.CodegenInfo.codegentarget));

    layerHeaders=dltargets.internal.SupportedLayers.m_headerFiles;

    dltargets.internal.utils.LayerToCompUtils.setCustomHeaderProperty(comp,layerHeaders);

end



function compFilename=igetCompFileName(filename,codegendir,codegentarget)

    compFilename=dltargets.internal.utils.LayerToCompUtils.getCompFileName(filename,...
    codegendir,codegentarget);

end

function previousLayerParam=commonReluParams(this,layer,previousLayerParam)




    previousLayerParam.reLUScaleExp=0;
    previousLayerParam.reLUValue=0;
    if(isfield(previousLayerParam,'reLUMode'))

        if(previousLayerParam.reLUMode~=0)
            msg=message('dnnfpga:dnnfpgacompiler:UnsupportedReLUSequence',layer.Name,previousLayerParam.phase);
            error(msg);
        end
        previousLayerParam.reLUMode=1;
        previousLayerParam.frontendLayers(end+1)={layer.Name};

    end

end


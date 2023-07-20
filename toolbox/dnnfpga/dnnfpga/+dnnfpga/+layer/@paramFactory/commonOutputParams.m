function param=commonOutputParams(this,layer,pvpairs)




    param=struct;
    disp("creating output params");
    param.type='SW_SeriesNetwork';
    param.internal_type='';
    param.phase=layer.Name;
    param.frontendLayers={layer.Name};
    param.snLayer=layer;
    param.WL=1;

    if(isfield(pvpairs,'hastrueoutputlayer'))
        hasTrueOutputLayer=pvpairs.hastrueoutputlayer;
    else
        hasTrueOutputLayer=true;
    end

    if(isfield(pvpairs,'hastrueinputlayer'))
        hasTrueInputLayer=pvpairs.hastrueinputlayer;
    else
        hasTrueInputLayer=true;
    end

    param.hasTrueOutputLayer=hasTrueOutputLayer;
    param.hasTrueInputLayer=hasTrueInputLayer;

    if~pvpairs.leglevel
        msg=message('dnnfpga:dnnfpgadisp:SoftwareLayerNotice',layer.Name,class(layer));
        dnnfpga.disp(msg,1,pvpairs.verbose);
    end

end


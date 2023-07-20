function param=commonInputParams(this,layer,pvpairs)






    param=struct;
    disp("creating input params");
    InputImgSize=layer.InputSize;
    param.type='SW_SeriesNetwork';
    param.internal_type='SW_SeriesNetwork_Input';
    param.phase=layer.Name;
    param.WL=1;
    param.frontendLayers={layer.Name};
    param.snLayer=layer;
    param.ExpData=0;
    param.inputFeatureNum=InputImgSize(3);
    param.origImgSize=[InputImgSize(1);InputImgSize(2);1];


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


function param=averagepoolParams(this,layer,param)




    if(isa(layer,'nnet.cnn.layer.AveragePooling2DLayer'))
        param.type='FPGA_Avgpool2D';
    end

end


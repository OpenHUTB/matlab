function param=quantizedOutputParams(this,WL,param,previousLayerParam,layer,mapObjOutputExp)




    if(~(WL==1))
        if(isa(layer,'nnet.cnn.layer.ClassificationOutputLayer')||isa(layer,'nnet.cnn.layer.YOLOv2OutputLayer')||isa(layer,'nnet.cnn.layer.PixelClassificationLayer'))
            param.ExpData=0;
        else
            prevLayer=previousLayerParam.phase;
            if(contains(prevLayer,'_insertZeros'))
                prevLayer=erase(prevLayer,'_insertZeros');
            end
            param.ExpData=mapObjOutputExp(prevLayer);
        end
        param.WL=WL;
    end
end


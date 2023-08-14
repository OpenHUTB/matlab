function validateDLNetwork(net)






    if~net.Initialized

        msgID='dnnfpga:dnnfpgacompiler:DLNetUnintialized';
        error(message(msgID));
    else

        inames=net.InputNames;
        layerNames=arrayfun(@(x)x.Name,net.Layers,'UniformOutput',false);
        layerClasses=arrayfun(@(x)class(x),net.Layers,'UniformOutput',false);
        for i=1:numel(inames)
            tf=strcmp(layerNames,inames{i});
            if~strcmp(layerClasses(tf),'nnet.cnn.layer.ImageInputLayer')
                msgID='dnnfpga:dnnfpgacompiler:DLNetUnsupportedInputLayers';
                expectedClass=class(imageInputLayer([10,10]));
                error(message(msgID,expectedClass));
            end
        end
    end

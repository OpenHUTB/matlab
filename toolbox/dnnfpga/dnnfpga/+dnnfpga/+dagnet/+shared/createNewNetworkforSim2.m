function[snet,image]=createNewNetworkforSim2(imageSize,weightSize)

    if nargin<1
        imageSize=[5,5,4];
    end

    if nargin<2
        weightSize=[10,20,30,40];
    end

    rng('default');

    image=randi(255,imageSize);


    a=1;
    for i=1:imageSize(3)
        for j=1:imageSize(2)
            for k=1:imageSize(1)
                image(k,j,i)=a;
                a=a+1;
            end
        end
    end

    layers(1)=imageInputLayer(size(image),'Name','data','Normalization','none');


    fcLayerInd=1;
    fcLayerNum=numel(weightSize);
    for layerNum=1:fcLayerNum
        if(layerNum==1)
            InputDepth=prod(imageSize);
        else
            InputDepth=weightSize(layerNum-1);
        end
        OutputDepth=weightSize(layerNum);
        matrixSize=[InputDepth,OutputDepth];
        fc_weights=dnnfpga.cosimbase.randNum([matrixSize],[-2,2]);
        fc_bias=dnnfpga.cosimbase.randNum([OutputDepth,1],[-2,2]);

        fcLayerName=sprintf('fc%d',layerNum);
        layers(fcLayerInd+layerNum)=fullyConnectedLayer(OutputDepth,'Name',fcLayerName);
        layers(fcLayerInd+layerNum).Weights=fc_weights';
        layers(fcLayerInd+layerNum).Bias=fc_bias;


    end

    layers(fcLayerInd+layerNum+1)=regressionLayer('Name','output');
    snet=assembleNetwork(layers);
end

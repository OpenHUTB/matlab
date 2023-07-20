function[mapObjInputExp,mapObjOutputExp]=mapLayerExponents(exponentData,net)


    exponentTable=struct2table(exponentData);
    keySet=strings(size(exponentTable.Exponent));
    keyVal=zeros(size(exponentTable.Exponent));
    isImageLayer=1;

    for k=1:height(exponentTable)
        if(contains(exponentTable.Name(k),'Weights')||contains(exponentTable.Name(k),'Bias')||contains(exponentTable.Name(k),'Parameter'))

            keySet(k)=string(exponentTable.Name(k));
            keyVal(k)=double(exponentTable.Exponent(k));
        else
            if(isImageLayer)

                prevLayerOut=double(exponentTable.Exponent(k));
                isImageLayer=0;
            end

            keySet(k)=string(exponentTable.Name(k));
            keyVal(k)=prevLayerOut;
            prevLayerOut=double(exponentTable.Exponent(k));
        end
    end
    mapObjInputExp=containers.Map(keySet,keyVal);


    n=numel(net.Layers);
    j=1;
    for i=1:n
        if(i~=n)
            nextLayer=i+1;
        else
            nextLayer=i;
        end
        if(any(ismember(exponentTable.Name,net.Layers(i).Name)))
            k=find(ismember(exponentTable.Name,net.Layers(i).Name));
            if((strcmp(class(net.Layers(i)),'nnet.cnn.layer.Convolution2DLayer')...
                ||strcmp(class(net.Layers(i)),'nnet.cnn.layer.FullyConnectedLayer'))...
                &&((strcmp(class(net.Layers(nextLayer)),'nnet.cnn.layer.ReLULayer'))...
                ||(strcmp(class(net.Layers(nextLayer)),'nnet.cnn.layer.LeakyReLULayer'))...
                ||(strcmp(class(net.Layers(nextLayer)),'nnet.cnn.layer.ClippedReLULayer'))))
                keySetOut(j)=string(exponentTable.Name(k));
                keyValOut(j)=double(exponentTable.Exponent(k+1));
            elseif(strcmp(class(net.Layers(i)),'nnet.cnn.layer.ImageInputLayer'))
                imageName=net.Layers(i).Name;
                imageName=strcat(imageName,'_normalization');
                if(find(ismember(exponentTable.Name,imageName)))
                    keySetOut(j)=string(exponentTable.Name(k));
                    keyValOut(j)=double(exponentTable.Exponent(k+1));
                else
                    keySetOut(j)=string(exponentTable.Name(k));
                    keyValOut(j)=double(exponentTable.Exponent(k));
                end
            else
                keySetOut(j)=string(exponentTable.Name(k));
                keyValOut(j)=double(exponentTable.Exponent(k));
            end
            j=j+1;
        elseif(any(ismember(exponentTable.Name,erase(net.Layers(i).Name,'_insertZeros'))))
            k=find(ismember(exponentTable.Name,erase(net.Layers(i).Name,'_insertZeros')));
            if strcmpi(class(net.Layers(i)),'nnet.cnn.layer.Convolution2DLayer')
                keySetOut(j)=string(exponentTable.Name(k));
            else
                keySetOut(j)=string(net.Layers(i).Name);
            end
            keyValOut(j)=double(exponentTable.Exponent(k-1));
            j=j+1;
        end
    end
    mapObjOutputExp=containers.Map(keySetOut,keyValOut);
end



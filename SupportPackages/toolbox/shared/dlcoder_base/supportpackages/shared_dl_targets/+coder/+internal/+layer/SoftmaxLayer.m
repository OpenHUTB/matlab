classdef SoftmaxLayer<nnet.layer.Layer













%#codegen


    properties

        ChannelDim;
    end

    methods
        function layer=SoftmaxLayer(name,ChannelDim)
            layer.Name=name;
            layer.ChannelDim=ChannelDim;
        end

        function Z1=predict(layer,X1)
            coder.allowpcode('plain');
            Z1=coder.nullcopy(X1);



            if(coder.const(layer.ChannelDim)==1)

                seqLength=size(X1,3);
                batch=size(X1,2);
                numFeats=size(X1,1);

                outerDimsProduct=(batch*seqLength);






                if outerDimsProduct>1

                    coder.internal.treatAsParfor();
                    coder.internal.parallelRelax();
                    for outerDimsProductIdx=1:outerDimsProduct

                        batchIdx=mod((outerDimsProductIdx-1),batch)+1;
                        seqLengthIdx=floor(mod((outerDimsProductIdx-1)/batch,seqLength))+1;


                        dataSoftmax=X1(:,batchIdx,seqLengthIdx);


                        maxVal=dataSoftmax(1);
                        for numFeatsIdx=2:numFeats
                            maxVal=max(maxVal,dataSoftmax(numFeatsIdx));
                        end


                        dataExp=exp(dataSoftmax-maxVal);


                        sumX=sum(dataExp);


                        Z1(:,batchIdx,seqLengthIdx)=dataExp./sumX;

                    end

                else


                    dataSoftmax=X1(:,1,1);


                    maxVal=dataSoftmax(1);
                    for numFeatsIdx=2:numFeats
                        maxVal=max(maxVal,dataSoftmax(numFeatsIdx));
                    end


                    dataExp=exp(dataSoftmax-maxVal);


                    sumX=sum(dataExp);


                    Z1(:,1,1)=dataExp./sumX;

                end


            else


                seqLength=size(X1,5);
                batch=size(X1,4);
                channel=size(X1,3);
                width=size(X1,2);
                height=size(X1,1);


                outerDimsProduct=(seqLength*batch*width*height);






                if outerDimsProduct>1

                    coder.internal.treatAsParfor();
                    coder.internal.parallelRelax();
                    for outerDimsProductIdx=1:outerDimsProduct


                        heightIdx=mod((outerDimsProductIdx-1),height)+1;
                        widthIdx=floor(mod((outerDimsProductIdx-1)/height,width))+1;
                        batchIdx=floor(mod((outerDimsProductIdx-1)/(height*width),batch))+1;
                        seqLengthIdx=floor(mod((outerDimsProductIdx-1)/(height*width*batch),seqLength))+1;


                        dataSoftmax=X1(heightIdx,widthIdx,:,batchIdx,seqLengthIdx);


                        maxVal=dataSoftmax(1);
                        for channelIdx=2:channel
                            maxVal=max(maxVal,dataSoftmax(channelIdx));
                        end


                        dataExp=exp(dataSoftmax-maxVal);


                        sumX=sum(dataExp);


                        Z1(heightIdx,widthIdx,:,batchIdx,seqLengthIdx)=dataExp./sumX;

                    end

                else

                    dataSoftmax=X1(1,1,:,1,1);


                    maxVal=dataSoftmax(1);
                    for channelIdx=2:channel
                        maxVal=max(maxVal,dataSoftmax(channelIdx));
                    end


                    dataExp=exp(dataSoftmax-maxVal);


                    sumX=sum(dataExp);


                    Z1(1,1,:,1,1)=dataExp./sumX;
                end
            end
        end
    end

end

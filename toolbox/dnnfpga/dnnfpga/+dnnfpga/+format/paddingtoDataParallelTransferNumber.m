function inputNew=paddingtoDataParallelTransferNumber(input,dataTransNum,threadNum)


























































































































































    if nargin<3
        threadNum=dataTransNum;
    end

    if dataTransNum>threadNum

        inputSize=size(input);
        chunckNum=ceil(size(input,3)/threadNum);


        paddedInputSize=[inputSize(1:2),chunckNum*dataTransNum];
        inputNew=zeros(paddedInputSize,'like',input);





        if~mod(size(input,3),threadNum)
            prevIndexes=[1:threadNum:size(input,3);
            threadNum:threadNum:size(input,3)];
        else
            prevIndexes=[1:threadNum:size(input,3);
            threadNum:threadNum:size(input,3),size(input,3)];
        end
        postIndexes=[1:dataTransNum:size(inputNew,3);
        dataTransNum:dataTransNum:size(inputNew,3)];


        for idx=1:chunckNum
            preInterval=prevIndexes(1,idx):prevIndexes(2,idx);
            postInterval=postIndexes(1,idx):postIndexes(2,idx);
            paddingSize=length(postInterval)-length(preInterval);
            inputNew(:,:,postInterval)=dnnfpga.assembler.padImage(input(:,:,preInterval),[0,0,paddingSize],'post');
        end
    else

        inputNew=input;
        if(dataTransNum>1)
            inputFeatureNum=size(input,3);
            modNum=mod(inputFeatureNum,dataTransNum);
            if(modNum~=0)



                inputNew=dnnfpga.assembler.padImage(input,[0,0,dataTransNum-modNum],'post');
            end
        end
    end

end


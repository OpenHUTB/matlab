function data_out=dnnfpgaPaddinglogiclibFeaturesPadding(data,threadNumLimit,numofInputFeatures,BIN_SIZE,numOfBitsPerChannel)
%#codegen
    coder.allowpcode('plain');
    temp=fi((zeros(BIN_SIZE,threadNumLimit)),0,32,0);

    for tid=1:threadNumLimit
        for idx=1:BIN_SIZE
            if(tid>numofInputFeatures)
                temp(idx,tid)=0;
            else
                temp(idx,tid)=data(tid);
            end
        end
    end
    data_out=reshape(temp,[BIN_SIZE*threadNumLimit,1]);
end
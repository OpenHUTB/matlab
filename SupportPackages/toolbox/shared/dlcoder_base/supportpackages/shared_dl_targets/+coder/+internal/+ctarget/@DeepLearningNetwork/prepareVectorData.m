
function outData=prepareVectorData(~,inData)




%#codegen


    coder.inline('always');
    coder.allowpcode('plain');

    inDataSz=size(inData);
    if numel(inDataSz)>2

        coder.internal.assert(size(inData,1)==1,"dlcoder_spkg:cnncodegen:IncorrectHWDimsForCcodegen","Height");
        coder.internal.assert(size(inData,2)==1,"dlcoder_spkg:cnncodegen:IncorrectHWDimsForCcodegen","Width");
        outData=reshape(inData,size(inData,[3,4]));

    else

        outData=inData;
    end

end

function[rInd,zInd,hInd,rInd_rec,zInd_rec,hInd_rec]=gruGateIndices(HiddenSize)





%#codegen


    coder.allowpcode('plain');



































    rInd=1:HiddenSize;
    zInd=(1+HiddenSize):2*HiddenSize;
    hInd=(1+2*HiddenSize):3*HiddenSize;

    recurrentIndexStart=3*HiddenSize;
    rInd_rec=recurrentIndexStart+(1:HiddenSize);
    zInd_rec=recurrentIndexStart+(HiddenSize+1:2*HiddenSize);
    hInd_rec=recurrentIndexStart+(2*HiddenSize+1:3*HiddenSize);
end



function[PSD,PSDMaxHold,PSDMinHold,Fout]=computeFilterBankPSDNormalRate(obj,x)








    z=obj.States;
    v=obj.vextra;
    polyMtx=obj.PolyphaseMatrix;
    M=obj.pNFFT;
    isIPP=obj.IPPflag;
    [~,numSegs,numChan]=size(x);

    segLen=obj.pFreqVectLength;
    PSD=zeros(segLen,numSegs,numChan);
    PSDMaxHold=zeros(segLen,numSegs,numChan);
    PSDMinHold=zeros(segLen,numSegs,numChan);
    Fout=obj.pFreqVect;
    maskTesterAvailable=~isempty(obj.MaskTester);



    for i=1:numSegs

        input=cast(squeeze(x(:,i,:)),'like',z);
        [Pall,z]=dsp.SpectrumEstimator.computePSD(input,v,z,polyMtx,M,isIPP);
        if strcmpi(obj.AveragingMethod,'Running')



            updatePeriodogramMatrix(obj,Pall);

            Pxx(:,:)=getPeriodogramMatrixAverage(obj);
        else

            Pxx=computeExponentialAveraging(obj,Pall);
        end



        currPSD=convertAndScale(obj,Pxx);
        PSD(:,numSegs-i+1,:)=currPSD;



        if obj.MaxHoldTrace
            obj.pMaxHoldPSD=max(obj.pMaxHoldPSD,squeeze(currPSD));
            PSDMaxHold(:,numSegs-i+1,:)=obj.pMaxHoldPSD;
        end
        if obj.MinHoldTrace
            obj.pMinHoldPSD=min(obj.pMinHoldPSD,squeeze(currPSD));
            PSDMinHold(:,numSegs-i+1,:)=obj.pMinHoldPSD;
        end

        if maskTesterAvailable
            performMaskTest(obj.MaskTester,currPSD,Fout,i);
        end
    end

    obj.States=z;
end

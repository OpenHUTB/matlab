function[PSD,PSDMaxHold,PSDMinHold,Fout]=computeFilterBankPSDReducedRate(obj,x)





    polyMtx=obj.PolyphaseMatrix;
    M=obj.pNFFT;
    isIPP=obj.IPPflag;
    z=obj.States;
    v=obj.vextra;
    maskTesterAvailable=~isempty(obj.MaskTester);

    [~,numSegs,~]=size(x);
    Fout=obj.pFreqVect;
    for i=1:numSegs

        input=cast(squeeze(x(:,i,:)),'like',z);
        [Pall,z]=dsp.SpectrumEstimator.computePSD(input,v,z,polyMtx,M,isIPP);
        if strcmpi(obj.AveragingMethod,'Running')



            updatePeriodogramMatrix(obj,Pall);

            Pxx(:,:)=getPeriodogramMatrixAverage(obj);
        else
            Pxx=computeExponentialAveraging(obj,Pall);
        end



        PSD=convertAndScale(obj,Pxx);



        if obj.MaxHoldTrace
            obj.pMaxHoldPSD=max(obj.pMaxHoldPSD,PSD);
        end
        if obj.MinHoldTrace
            obj.pMinHoldPSD=min(obj.pMinHoldPSD,PSD);
        end

        if maskTesterAvailable
            performMaskTest(obj.MaskTester,PSD,Fout,i);
        end
    end

    obj.States=z;

    PSDMaxHold=obj.pMaxHoldPSD;
    PSDMinHold=obj.pMinHoldPSD;
end

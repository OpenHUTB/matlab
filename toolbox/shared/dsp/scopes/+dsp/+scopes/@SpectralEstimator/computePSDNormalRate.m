function[PSD,PSDMaxHold,PSDMinHold,Fout]=computePSDNormalRate(obj,x)





    Pall=computePeriodogram(obj,x);
    [~,numSegs,numChan]=size(Pall);
    segLen=obj.pFreqVectLength;
    PSD=zeros(segLen,numSegs,numChan);
    PSDMaxHold=zeros(segLen,numSegs,numChan);
    PSDMinHold=zeros(segLen,numSegs,numChan);
    Fout=obj.pFreqVect;
    maskTesterAvailable=~isempty(obj.MaskTester);



    for i=1:numSegs
        if strcmpi(obj.AveragingMethod,'Running')



            updatePeriodogramMatrix(obj,Pall,i);

            Pxx(:,:)=getPeriodogramMatrixAverage(obj);
        else

            input=squeeze(Pall(:,i,:));
            Pxx=computeExponentialAveraging(obj,input);
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
end
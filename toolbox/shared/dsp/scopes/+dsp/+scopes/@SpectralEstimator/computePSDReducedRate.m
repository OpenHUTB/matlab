function[PSD,PSDMaxHold,PSDMinHold,Fout]=computePSDReducedRate(obj,x)



    maskTesterAvailable=~isempty(obj.MaskTester);
    if~obj.MaxHoldTrace&&~obj.MinHoldTrace&&~(maskTesterAvailable&&obj.MaskTester.Enabled)


        numSegs=size(x,2);
        if strcmpi(obj.AveragingMethod,'Running')
            spectralAverages=obj.SpectralAverages;
            if numSegs>spectralAverages
                x=x(:,end-spectralAverages+1:end,:);
                Pall=computePeriodogram(obj,x);
                obj.pNumAvgsCounter=spectralAverages;
            else

                Pall=computePeriodogram(obj,x);
                Pall=[obj.pPeriodogramMatrix(:,numSegs+1:end,:),Pall];
                obj.pNumAvgsCounter=min(spectralAverages,obj.pNumAvgsCounter+numSegs);
            end
            Pxx=sum(Pall,2)/obj.pNumAvgsCounter;
        else
            Pall=computePeriodogram(obj,x);
            for i=1:numSegs

                Pxx=computeExponentialAveraging(obj,squeeze(Pall(:,i,:)));
            end
        end
        PSD=convertAndScale(obj,Pxx);

        Fout=obj.pFreqVect;
        PSDMaxHold=[];
        PSDMinHold=[];

        obj.pPeriodogramMatrix=Pall;

        if maskTesterAvailable
            performMaskTest(obj.MaskTester,PSD,Fout);
        end
    else
        numSegs=size(x,2);
        Pall=computePeriodogram(obj,x);
        Fout=obj.pFreqVect;

        for i=1:numSegs
            if strcmpi(obj.AveragingMethod,'Running')



                updatePeriodogramMatrix(obj,Pall,i);

                Pxx(:,:)=getPeriodogramMatrixAverage(obj);
            else

                Pxx=computeExponentialAveraging(obj,squeeze(Pall(:,i,:)));
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
        PSDMaxHold=obj.pMaxHoldPSD;
        PSDMinHold=obj.pMinHoldPSD;
    end
end


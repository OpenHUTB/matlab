function aggregatedSpectra=aggregateSpectrum(this,spectralUpdates,N,Q)








    aggregatedSpectra=zeros(Q,size(spectralUpdates,1));
    cnt=0;
    for idx=1:N:N*Q
        blockOfNUpdates=spectralUpdates(:,idx:idx+N-1);


        partialPowerUpdate=this.LastSpectrumUpdate*this.LastSpectrumPowerWeight;
        this.LastSpectrumUpdate=blockOfNUpdates(:,end);

        cnt=cnt+1;
        aggregatedSpectra(cnt,:)=mean([blockOfNUpdates,partialPowerUpdate],2).';
    end
end

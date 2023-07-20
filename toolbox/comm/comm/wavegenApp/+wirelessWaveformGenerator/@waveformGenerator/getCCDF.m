






function results=getCCDF(wave)


    mode=struct();
    mode.CCDFx=[];
    mode.CCDFy=[];
    mode.AveragePower=[];
    results=struct();
    results.Waveform=mode;
    results.Burst=mode;
    results.BurstMode=false;
    results.LegendChannelName='';

    if any(wave)
        ccdf=comm.CCDF('AveragePowerOutputPort',true);
        ccdf.MaximumPowerLimit=pow2db(max(abs(wave).^2))+30+1;


        [ccdfy,ccdfx,avg]=ccdf(wave);


        [ccdfx,ccdfy]=removeCCDFZeros(ccdfx,ccdfy);



        numPorts=size(wave,2);
        burstWave=mat2cell(wave,size(wave,1),ones(1,numPorts));



        release(ccdf);
        ccdfxBurst=zeros(ccdf.NumPoints+1,numPorts);
        ccdfyBurst=zeros(ccdf.NumPoints+1,numPorts);
        avgBurst=zeros(numPorts,1);
        for p=1:numPorts
            pwave=burstWave{p};






            signalThreshold=db2mag(avg(p)-30-200);
            pwave(abs(pwave)<=signalThreshold)=[];

            ccdf.MaximumPowerLimit=pow2db(max(abs(pwave).^2))+30+1;
            [y,x,avgBurst(p)]=ccdf(pwave);
            [x,y]=removeCCDFZeros(x,y);
            ccdfyBurst(:,p)=y;
            ccdfxBurst(:,p)=x;

            release(ccdf);
        end


        results.Waveform.CCDFx=ccdfx;
        results.Waveform.CCDFy=ccdfy;
        results.Waveform.AveragePower=avg;

        results.Burst.CCDFx=ccdfxBurst;
        results.Burst.CCDFy=ccdfyBurst;
        results.Burst.AveragePower=avgBurst;
    end

end

function[x,y]=removeCCDFZeros(x,y)

    numPorts=size(x,2);
    for p=1:numPorts
        invalidIndex=y(:,p)<=1e-10;
        y(invalidIndex,p)=eps;
        x(invalidIndex,p)=x(find(invalidIndex,1,'first'),p);
    end
end
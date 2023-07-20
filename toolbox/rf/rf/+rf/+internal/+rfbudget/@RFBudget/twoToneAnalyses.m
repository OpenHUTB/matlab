function out=twoToneAnalyses(obj)




    numFreqs=length(obj.InputFrequency);
    numElems=length(obj.Elements);

    inBranch='rin.1';
    inNode='1';
    outBranch='rout.1';
    pi1=zeros(1,numElems);
    po1=zeros(1,numElems);
    po2=zeros(1,numElems);
    poim2=zeros(1,numElems);
    poim3=zeros(1,numElems);
    BW=obj.SignalBandwidth;
    delta=BW/8;
    freqdelta=BW;

    params=rf.internal.rfengine.analyses.parameters;

    sp=[];
    sp.UseLocalSolver=false;
    sp.LocalSolverChoice='NE_BACKWARD_EULER_ADVANCER';
    sp.DoFixedCost=false;
    sp.LocalSolverSampleTime=1/BW;

    inputPwrW=10^((obj.AvailableInputPower-30)/10);
    vin=2*sqrt(50*inputPwrW);
    vthresh=eps(vin)^(3/4);


    RelTol=double(params.RelTol);
    AbsTol=double(params.AbsTol);
    MaxIter=int32(10);





    ErrorEstimationType=int32(2);
    SmallSignalApprox=false;
    AllSimFreqs=true;
    SimFreqs=[];
    additionalParams=struct(...
    'RelTol',RelTol,...
    'AbsTol',AbsTol,...
    'MaxIter',MaxIter,...
    'ErrorEstimationType',ErrorEstimationType,...
    'SmallSignalApprox',SmallSignalApprox,...
    'AllSimFreqs',AllSimFreqs,...
    'SimFreqs',SimFreqs);

    for i=1:numFreqs
        loFreqs=[];
        ckt=[];
        for j=1:numElems

            if j==1
                stageInFreq=obj.InputFrequency(i);
            else
                stageInFreq=obj.OutputFrequency(i,j-1);
            end
            outFreq=obj.OutputFrequency(i,j);





            if isa(obj.Elements(j),'modulator')||isa(obj.Elements(j),'mixerIMT')
                if stageInFreq==0||outFreq==0
                    loFreqs(end+1)=obj.Elements(j).LO-freqdelta;%#ok<AGROW>
                else
                    loFreqs(end+1)=obj.Elements(j).LO;%#ok<AGROW>
                end
            end
            if outFreq==0
                outFreq=freqdelta;
            end


            inFreq1=abs(obj.InputFrequency(i));
            if inFreq1==0
                inFreq1=freqdelta;
            end
            inFreq2=inFreq1+delta;



            outFreq1=abs(outFreq);
            outFreq2=outFreq1+delta;

            im2Freq=delta;
            im3Freq=abs(outFreq1-delta);

            IPfreq=unique([inFreq1,inFreq2,loFreqs]);

            OPfreq=unique([outFreq1,outFreq2,im2Freq,im3Freq]);


            [tones,harmonics]=...
            rf.internal.rfengine.analyses.simrfV2_fundamental_tones(IPfreq,OPfreq);
            if~isempty(obj.HarmonicOrder)
                harmonics=max(obj.HarmonicOrder,3);
            elseif all(harmonics==harmonics(1))
                harmonics=harmonics(1);
            end

            ckt=exportRFEngine(obj,...
            'Analyze',false,...
            'Noise',false,...
            'InputFrequencies',[inFreq1,inFreq2],...
            'Tones',tones,...
            'Harmonics',harmonics,...
            'Length',j,...
            'FreqIdx',i,...
            'Circuit',ckt);
            prepareForAnalysis(ckt)
            [~,~,success]=Execute(ckt.HB,params,sp,additionalParams);
            if~success
                error('Two-tone HB analysis failed')
            end
            s=ckt.HB.Solution;



            vi1=s.v(inNode,inFreq1,vthresh);
            ii1=s.i(inBranch,inFreq1);
            pi1(j)=real(vi1*conj(ii1));

            outNode=num2str(j+1);
            vo1=s.v(outNode,outFreq1,vthresh);
            io1=s.i(outBranch,outFreq1);
            po1(j)=real(vo1*conj(io1));

            vo2=s.v(outNode,outFreq2,vthresh);
            io2=s.i(outBranch,outFreq2);
            po2(j)=real(vo2*conj(io2));

            vim2=s.v(outNode,im2Freq,vthresh);
            iim2=s.i(outBranch,im2Freq);
            poim2(j)=real(vim2*conj(iim2));

            vim3=s.v(outNode,im3Freq,vthresh);
            iim3=s.i(outBranch,im3Freq);
            poim3(j)=real(vim3*conj(iim3));

            if~isempty(obj.WaitBarHandle)

                if getappdata(obj.WaitBarHandle,'canceling')
                    eraseHarmonicBalance(obj)
                    obj.Solver='Friis';
                    return
                else
                    waitbar(0.5+(j+(i-1)*numFreqs)/(2*numFreqs*numElems),...
                    obj.WaitBarHandle)
                end
            end
        end

        pi1dB=real(10*log10(pi1));
        po1dB=real(10*log10(po1));
        po2dB=real(10*log10(po2));
        poim2dB=real(10*log10(poim2));
        poim3dB=real(10*log10(poim3));

        obj.HarmonicBalance.IIP2(i,:)=(pi1dB+(po2dB-poim2dB))+30;
        obj.HarmonicBalance.OIP2(i,:)=(po1dB+(po2dB-poim2dB))+30;
        obj.HarmonicBalance.IIP3(i,:)=(pi1dB+(po2dB-poim3dB)/2)+30;
        obj.HarmonicBalance.OIP3(i,:)=(po1dB+(po2dB-poim3dB)/2)+30;
        ant=arrayfun(@(x)isa(x,'rfantenna'),obj.Elements);
        num=1:numel(ant);
        index=num(ant~=0);
        if~isempty(index)
            if strcmpi(obj.Elements(index).Type,'TransmitReceive')
                obj.HarmonicBalance.OIP3(index)=nan;
                obj.HarmonicBalance.OIP2(index)=nan;
            end
        end

        if isscalar(obj.InputFrequency)
            obj.PrivateTones=tones;
            obj.PrivateHarmonics=harmonics;
        else
            obj.PrivateTones{i,1}=tones;
            obj.PrivateHarmonics{i,1}=harmonics;
        end
    end
    if nargout>0
        out=ckt;
    end
end

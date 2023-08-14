function out=oneToneAnalyses(obj)




    numFreqs=length(obj.InputFrequency);
    numElems=length(obj.Elements);

    outBranch='rout.1';
    po1=zeros(1,numElems);
    BW=obj.SignalBandwidth;
    freqdelta=BW;

    params=rf.internal.rfengine.analyses.parameters;

    sp=[];
    sp.UseLocalSolver=false;
    sp.LocalSolverChoice='NE_BACKWARD_EULER_ADVANCER';
    sp.DoFixedCost=false;
    sp.LocalSolverSampleTime=1/BW;

    snrIn=obj.AvailableInputPower-30-10*log10(obj.kT*obj.SignalBandwidth);
    inputPwrW=10^((obj.AvailableInputPower-30)/10);
    vin=2*sqrt(50*inputPwrW);
    vthresh=eps(vin)^(3/4);


    RelTol=double(params.RelTol);
    AbsTol=double(params.AbsTol);
    MaxIter=int32(10);





    ErrorEstimationType=int32(2);
    SmallSignalApprox=true;
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



            outFreq1=abs(outFreq);


            IPfreq=unique([inFreq1,loFreqs]);

            OPfreq=outFreq1;


            [tones,harmonics]=...
            rf.internal.rfengine.analyses.simrfV2_fundamental_tones(IPfreq,OPfreq);
            if~isempty(obj.HarmonicOrder)
                harmonics=obj.HarmonicOrder;
            elseif all(harmonics==harmonics(1))
                harmonics=harmonics(1);
            end

            ckt=exportRFEngine(obj,...
            'Analyze',false,...
            'Noise',true,...
            'InputFrequencies',inFreq1,...
            'Tones',tones,...
            'Harmonics',harmonics,...
            'Length',j,...
            'FreqIdx',i,...
            'Circuit',ckt);
            prepareForAnalysis(ckt)
            [result,data,success]=Execute(ckt.HB,params,sp,additionalParams);
            if~success
                error('One-tone HB analysis failed')
            end
            s=ckt.HB.Solution;



            outNode=num2str(j+1);
            [vo1,~,rowOut,colOut]=s.v(outNode,outFreq1,vthresh);
            io1=s.i(outBranch,outFreq1);
            po1(j)=real(vo1*conj(io1));

            result=rf.internal.rfengine.rfsolver.MainDae('SOLVE',data,...
            'CIC_MODE',result);%#ok<NASGU> 

            H=data.solver.Jfull\data.solver.B;






            D=data.noiseFactor.^2;
            iD=1:numel(D);


            Suu=BW*sparse(iD,iD,D(:));
            Sxx=H*Suu*H';


            diagSxx=diag(Sxx);

            timeDomain=data.solver.Dae.VariableInfo.Time;
            numStates=sum(timeDomain);
            Qoffset=(data.nFreqs-1)*numStates;

            rowOut2=rowOut-sum(~timeDomain(1:rowOut));
            colOut2=data.OutputMap.freqIndex{colOut};
            varOut=0;
            for idx=1:length(colOut2)
                idxOut2=rowOut2+(colOut2(idx)-1)*numStates;
                idxOutQ=idxOut2+Qoffset;
                varOut=varOut+(diagSxx(idxOut2)+diagSxx(idxOutQ))/2;
            end

            if abs(vo1)==0
                obj.HarmonicBalance.SNR(i,j)=-Inf;
            else
                obj.HarmonicBalance.SNR(i,j)=10*log10((vo1*vo1')/varOut);
            end

            obj.HarmonicBalance.NF(i,j)=snrIn-obj.HarmonicBalance.SNR(i,j);

            if~isempty(obj.WaitBarHandle)

                if getappdata(obj.WaitBarHandle,'canceling')
                    eraseHarmonicBalance(obj)
                    obj.Solver='Friis';
                    return
                else
                    waitbar((j+(i-1)*numFreqs)/(2*numFreqs*numElems),...
                    obj.WaitBarHandle)
                end
            end
        end

        po1dB=real(10*log10(po1));
        obj.HarmonicBalance.OutputPower(i,:)=po1dB+30;
        obj.HarmonicBalance.TransducerGain(i,:)=...
        po1dB-(obj.AvailableInputPower-30);

        ant=arrayfun(@(x)isa(x,'rfantenna'),obj.Elements);
        num=1:numel(ant);
        index=num(ant~=0);
        if~isempty(index)
            if strcmpi(obj.Elements(index).Type,'TransmitReceive')
                obj.Elements(index).TxEIRP=obj.EIRP;
                obj.Elements(index).RxP=obj.Elements(index).TxEIRP-...
                obj.Elements(index).PathLoss+obj.Elements(index).Gain(2);
                snrInUpdated=obj.Elements(index).RxP-30-10*log10(obj.kT*obj.SignalBandwidth);
                obj.HarmonicBalance.TransducerGain=obj.Friis.TransducerGain;
                obj.HarmonicBalance.SNR(index+1:end)=snrInUpdated-obj.HarmonicBalance.NF(index+1:end);
                obj.HarmonicBalance.OutputPower(index+1:end)=obj.Elements(index).RxP...
                +obj.HarmonicBalance.TransducerGain(index+1:end);
                if index>1
                    obj.HarmonicBalance.OutputPower(index)=obj.HarmonicBalance.OutputPower(index-1)...
                    +obj.HarmonicBalance.TransducerGain(index);
                end
                obj.HarmonicBalance.NF=obj.Friis.NF;
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

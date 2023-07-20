function computeBudget(obj,varargin)




    narginchk(1,3)
    p=inputParser;
    p.CaseSensitive=false;
    p.addParameter('WaitBar',true);
    p.parse(varargin{:});
    args=p.Results;
    validateattributes(args.WaitBar,{'logical','numeric'},...
    {'nonempty','scalar'},'','WaitBar')

    eraseResults(obj)
    if~obj.Computable
        return
    end

    setupFrequencies(obj)
    friis(obj)
    if strcmpi(obj.Solver,'HarmonicBalance')
        if any(0<abs(obj.InputFrequency)&abs(obj.InputFrequency)<obj.SignalBandwidth)||...
            any(0<abs(obj.OutputFrequency)&abs(obj.OutputFrequency)<obj.SignalBandwidth,'all')
            error(message('rf:rfbudget:BadHBInOutFreq'))
        end

        if obj.WaitBar&&args.WaitBar
            try
                obj.WaitBarHandle=waitbar(0,'Solving RF budget harmonic balance...',...
                'Name','computeBudget',...
                'CreateCancelBtn','setappdata(gcbf,''canceling'',true)');
                setappdata(obj.WaitBarHandle,'canceling',false)
                oneToneAnalyses(obj)
                if getappdata(obj.WaitBarHandle,'canceling')

                    eraseHarmonicBalance(obj)
                    obj.Solver='Friis';
                else
                    twoToneAnalyses(obj)
                end
            catch
                eraseHarmonicBalance(obj)
                obj.Solver='Friis';
            end
            if ishghandle(obj.WaitBarHandle)
                delete(obj.WaitBarHandle)
                obj.WaitBarHandle=[];
            end
        else
            oneToneAnalyses(obj)
            twoToneAnalyses(obj)
        end
    end
end

function setupFrequencies(obj)


    numFreq=numel(obj.InputFrequency);
    numElem=numel(obj.Elements);
    obj.OutputFrequency=zeros(numFreq,numElem);
    for i=1:numFreq
        freq=obj.InputFrequency(i);
        tol=eps(freq);
        for j=1:numElem
            elem=obj.Elements(j);
            if isa(elem,'modulator')||isa(elem,'mixerIMT')
                tol=max(tol,eps(max(freq,elem.LO)));
                if isa(elem,'mixerIMT')
                    if elem.UseDataFile
                        if numFreq<=1
                            read(elem,elem.FileName,freq);
                        end
                    end
                end
                switch elem.ConverterType
                case 'Down'
                    freq=abs(freq-elem.LO);
                    if abs(freq)<=tol
                        freq=0;
                    end
                case 'Up'
                    freq=freq+elem.LO;
                end
            end
            obj.OutputFrequency(i,j)=freq;
        end
    end
end

function stageS=getStageS(elem,freq,zs)


    if isa(elem,'rfantenna')
        stageS=sparameters(elem,freq,zs,true);
    else
        stageS=sparameters(elem,freq,zs);
    end




    if stageS.Parameters(2,1)==0


        s11=stageS.Parameters(1,1);
        s12=stageS.Parameters(1,2);
        s21=stageS.Parameters(2,1);
        s22=stageS.Parameters(2,2);
        Z0=stageS.Impedance;
        Y0=1/Z0;

        Zp=1e12;
        Yp=1/Zp;

        Yresistor=[Yp,-Yp;
        -Yp,Yp];
        if s22==-1&&s11~=-1





            Rseries=1e-12;
            YA=[(1-s11)/(Z0*(1+s11)),0;
            0,1/Rseries];
        elseif s11==-1&&s22~=-1





            Rseries=1e-12;
            YA=[1/Rseries,0;
            0,(1-s22)/(Z0*(1+s22))];
        elseif s22==-1&&s11==-1





            Rseries=1e-12;
            YA=[1,0;0,1]/Rseries;
        else

            alpha=((1-s11)*(1+s22))+(s12*s21);
            beta=((1+s11)*(1+s22))-(s12*s21);
            gamma=((1+s11)*(1-s22))+(s12*s21);
            YA=[alpha*Y0/beta,-2*s12*Y0/beta;
            -2*s21*Y0/beta,gamma*Y0/beta];
        end

        Yc=YA+Yresistor;
        stageS=sparameters(y2s(Yc),freq,zs);
    end
end

function friis(obj)
    numFreq=numel(obj.InputFrequency);
    numElem=numel(obj.Elements);
    zs=50;
    zvect=[1,zs];
    denomZ=4*obj.kT*zs;
    IPn=Inf(1,numElem);
    cascadePowerGain=zeros(numFreq,numElem);
    snrIn=obj.AvailableInputPower-30-10*log10(obj.kT*obj.SignalBandwidth);
    obj.CascadeS=sparameters.empty;
    for i=1:numFreq
        freq=abs(obj.InputFrequency(i));
        for j=1:numElem
            elem=obj.Elements(j);

            stageS=getStageS(elem,freq,zs);

            Ca=getCa(elem,freq,stageS);
            if isa(elem,'rfantenna')
                if strcmpi(elem.Type,'Receiver')
                    obj.StageAvailableGain(i,j)=elem.Gain;
                elseif strcmpi(elem.Type,'TransmitReceive')
                    obj.StageAvailableGain(i,j)=elem.Gain(1)+elem.Gain(2);
                else
                    obj.StageAvailableGain(i,j)=getGain(elem,stageS);
                end
            else
                obj.StageAvailableGain(i,j)=getGain(elem,stageS);
            end
            obj.StageNF(i,j)=getNF(elem,Ca);
            obj.StageOIP3(i,j)=getOIP3(elem);


            stageABCD=abcdparameters(stageS);
            if j==1
                cascadeABCD=stageABCD;
                cascadeS=stageS;
                cascadeCA=Ca;
                obj.Friis.NF(i,j)=obj.StageNF(i,j);
                if isa(elem,'rfantenna')
                    if strcmpi(elem.Type,'TransmitReceive')
                        obj.TxRxIdx=j;
                    end
                end
            else
                if isa(elem,'rfantenna')
                    if strcmpi(elem.Type,'TransmitReceive')
                        prevA=cascadeABCD.Parameters;
                        cascadeABCD=abcdparameters(prevA*stageABCD.Parameters,freq);
                        cascadeS(j)=sparameters(cascadeABCD);
                        cascadeCA=real(prevA*Ca*prevA')+cascadeCA;
                        obj.Friis.NF(i,j)=obj.StageNF(i,j);
                        obj.TxRxIdx=j;
                    else
                        prevA=cascadeABCD.Parameters;
                        cascadeABCD=abcdparameters(prevA*stageABCD.Parameters,freq);
                        cascadeS(j)=sparameters(cascadeABCD);
                        cascadeCA=real(prevA*Ca*prevA')+cascadeCA;
                        obj.Friis.NF(i,j)=10*log10(1+real(zvect*cascadeCA*zvect')/denomZ);
                    end
                else
                    if obj.TxRxIdx==j-1
                        cascadeABCD=stageABCD;
                        cascadeS(j)=stageS;
                        cascadeCA=Ca;
                        obj.Friis.NF(i,j)=obj.StageNF(i,j);
                    else
                        prevA=cascadeABCD.Parameters;
                        cascadeABCD=abcdparameters(prevA*stageABCD.Parameters,freq);
                        cascadeS(j)=sparameters(cascadeABCD);
                        cascadeCA=real(prevA*Ca*prevA')+cascadeCA;
                        obj.Friis.NF(i,j)=10*log10(1+real(zvect*cascadeCA*zvect')/denomZ);
                    end
                end

            end
            Sc=cascadeS(j).Parameters;
            obj.Friis.TransducerGain(i,j)=20*log10(abs(Sc(2,1)));




            cascadePowerGain(i,j)=10*log10(abs(Sc(2,1))^2/(1-abs(Sc(1,1))^2));
            oip3=getOIP3(elem);
            if isinf(cascadePowerGain(i,j))&&isinf(oip3)
                obj.Friis.IIP3(i,j)=oip3;
                obj.Friis.OIP3(i,j)=oip3;
            elseif imag(cascadePowerGain(i,j))
                obj.Friis.IIP3(i,j)=NaN;
                obj.Friis.OIP3(i,j)=NaN;
            else
                IPn(j)=oip3-cascadePowerGain(i,j);
                IPinput=1/sum(1./10.^(IPn(1:j)/10));
                obj.Friis.IIP3(i,j)=10*log10(IPinput);
                obj.Friis.OIP3(i,j)=obj.Friis.IIP3(i,j)+cascadePowerGain(i,j);
            end

            freq=abs(obj.OutputFrequency(i,j));
            Rx=0;
            if isa(elem,'rfantenna')
                if strcmpi(elem.Type,'Receiver')
                    obj.AvailableInputPower=elem.RxP;
                    Rx=1;
                    obj.AutoUpdate=true;
                end
            end
        end
        obj.CascadeS(i,:)=cascadeS;
    end


    obj.Friis.SNR=snrIn-obj.Friis.NF;


    obj.Friis.OutputPower=obj.AvailableInputPower+obj.Friis.TransducerGain;

    ant=arrayfun(@(x)isa(x,'rfantenna'),obj.Elements);
    num=1:numel(ant);
    index=num(ant~=0);
    if~isempty(index)
        if strcmpi(obj.Elements(index).Type,'TransmitReceive')



            if isrow(obj.OutputFrequency)
                freq=obj.OutputFrequency(1,index);
            end
            calculateEIRPandDirectivity(obj,index,freq);
            obj.Elements(index).TxEIRP=obj.EIRP;
            obj.Elements(index).RxP=obj.Elements(index).TxEIRP-...
            obj.Elements(index).PathLoss+obj.Elements(index).Gain(2);
            snrInUpdated=obj.Elements(index).RxP-30-10*log10(obj.kT*obj.SignalBandwidth);
            obj.Friis.SNR(index+1:end)=snrInUpdated-obj.Friis.NF(index+1:end);
            obj.Friis.OutputPower(index+1:end)=obj.Elements(index).RxP+obj.Friis.TransducerGain(index+1:end);
            obj.Friis.TransducerGain(index)=obj.Friis.TransducerGain(index)...
            +obj.Elements(index).Gain(1)+obj.Elements(index).Gain(2)...
            -obj.Elements(index).PathLoss;
            if index>1
                obj.Friis.OutputPower(index)=obj.Friis.OutputPower(index-1)+obj.Friis.TransducerGain(index);
            end
            obj.Friis.NF(index)=nan;
            obj.Friis.OIP3(index)=nan;
        end
    end
    if any(ant)&&~Rx
        calculateEIRPandDirectivity(obj,index,freq);
    end

end
function calculateEIRPandDirectivity(obj,index,freq)
    varType=[];
    if~isempty(obj.Elements(index).AntennaDesign)
        varType='AntennaDesign';
    else
        if iscell(obj.Elements(index).AntennaObject)
            if~isempty(obj.Elements(index).AntennaObject)&&...
                (isa(obj.Elements(index).AntennaObject{1},'em.Antenna')||...
                isa(obj.Elements(index).AntennaObject{2},'em.Antenna'))
                varType='AntennaObject';
            end
        elseif~isempty(obj.Elements(index).AntennaObject)&&...
            isa(obj.Elements(index).AntennaObject,'em.Antenna')
            varType='AntennaObject';
        end

    end
    if~isempty(varType)
        if strcmpi(obj.Elements(index).Type,'Transmitter')
            obj.Elements(index).Z=impedance(obj.Elements(index).(varType),freq);
            obj.Elements(index).Gain=pattern(obj.Elements(index).(varType),freq,...
            obj.Elements(index).DirectionAngles(1),...
            obj.Elements(index).DirectionAngles(2));
        elseif strcmpi(obj.Elements(index).Type,'TransmitReceive')&&~isempty(obj.Elements(index).(varType){1})
            obj.Elements(index).Z(1)=impedance(obj.Elements(index).(varType){1},freq);
            obj.Elements(index).Gain(1)=pattern(obj.Elements(index).(varType){1},freq,...
            obj.Elements(index).DirectionAngles(1),...
            obj.Elements(index).DirectionAngles(2));
        end
    end
    obj.EIRP(index)=obj.Friis.OutputPower(index)+obj.Elements(index).Gain(1);
    obj.Directivity(index)=obj.Elements(index).Gain(1);
    obj.EIRP(1:index-1)=[];
    obj.Directivity(1:index-1)=[];

end

function monteCarlo(ckt,result,data,idxIn,idxOut,inFreq1,outFreq1,vs1,vsOut,outNode,varIn,varOut,sOut,P)%#ok<DEFNU>
    tol=1e-7;
    vn1=[];
    vnOut=[];
    snrOut=[];
    h=data.sp.LocalSolverSampleTime;
    numFreqs=length(ckt.HB.UniqueFreqs);
    for k=1:2
        result.T=result.T+h;
        result=rf.internal.rfengine.rfsolver.MainDae('SOLVE',data,...
        'CIC_MODE',result);
    end
    for k=1:100000
        result.T=result.T+h;
        result=rf.internal.rfengine.rfsolver.MainDae('SOLVE',data,'CIC_MODE',result);
        if isempty(P)
            y=rf.internal.rfengine.rfsolver.MainDae('METHOD',data,'Y',result);
            Ytri=reshape(y,2*numFreqs,[]);
            Y=complex(Ytri(1:end/2,:),Ytri(end/2+1:end,:)).';
            ns=rf.internal.rfengine.analyses.solution(ckt,Y,ckt.HB.UniqueFreqs);
            vn1(k)=ns.v('1',inFreq1)-vs1;%#ok<AGROW>
            vnOut(k)=ns.v(outNode,outFreq1)-vsOut;%#ok<AGROW>
        else
            y=P*result.D;
            Ytri=reshape(y,2*numFreqs,[]);
            Y=complex(Ytri(1:end/2,:),Ytri(end/2+1:end,:)).';
            vn1(k)=Y(idxIn);%#ok<AGROW>
            vnOut(k)=Y(idxOut);%#ok<AGROW>
        end
        varIn2=(vn1*vn1')/(2*k);
        varOut2=(vnOut*vnOut')/(2*k);

        snrOut(k)=10*log10(sOut/varOut2);%#ok<AGROW>
        if k>=3&&...
            abs(snrOut(k)-snrOut(k-1))<tol*snrOut(k)&&...
            abs(snrOut(k-1)-snrOut(k-2))<tol*snrOut(k)
            break
        end
    end
    snrIn2=10*log10((vs1*vs1')/varIn2);
    fprintf('varIn=%g varIn2=%g (varIn-varIn2)/varIn=%g\n',varIn,varIn2,(varIn-varIn2)/varIn)
    fprintf('varOut=%g varOut2=%g (varOut-varOut2)/varOut = %g\n',varOut,varOut2,(varOut-varOut2)/varOut)
    fprintf('snr=%g\n',snrOut(end))
    fprintf('nf=%g\n',snrIn2-snrOut(end))
end

function res=MainDae(mode,varargin)



    try

        switch mode
        case 'DATA'

            [dae,sp,~,tones,harmonics,additionalLocalSolverParams,doNoise,sepStream,noiseSeed,spf,inputData,outputData]=varargin{:};

            sanity_check(dae,sp);


            count=1;
            sizes=cellfun(@(x)prod(x.Dimension),inputData);
            inputDataTemp=repmat(inputData(1),sum(sizes),1);
            for ind=1:numel(inputData)
                inputDataTemp(count:count+sizes(ind)-1)=inputData(ind);
                count=count+sizes(ind);
            end
            inputData=[inputDataTemp{:}];
            outputData=[outputData{:}];

            params=rfsolver.EnvelopeParameters(...
            'RelTol',additionalLocalSolverParams.RelTol,...
            'AbsTol',additionalLocalSolverParams.AbsTol,...
            'HbMaxIters',additionalLocalSolverParams.MaxIter,...
            'ErrorEstimationType',additionalLocalSolverParams.ErrorEstimationType,...
            'SmallSignalApprox',additionalLocalSolverParams.SmallSignalApprox,...
            'AllSimFreqs',additionalLocalSolverParams.AllSimFreqs,...
            'SimFreqs',additionalLocalSolverParams.SimFreqs);


            switch sp.LocalSolverChoice
            case 'NE_BACKWARD_EULER_ADVANCER'
                params.HbIntegrationMethod='be';
            case 'NE_TRAPEZOIDAL_ADVANCER'
                params.HbIntegrationMethod='trap';
            case 'NE_NDF2_ADVANCER'
                params.HbIntegrationMethod='ndf2';
            otherwise
                assert(0,'incorrect integration method');
            end


            generalized_dae=rfsolver.GeneralizedDae(dae);

            if generalized_dae.IsLinear

                allFreqs=initialize_freqs(inputData,outputData,dae);


                solver=rfsolver.LinearEnvelopeSolver(generalized_dae,allFreqs,params);

                FreqHarmonics=ones(size(allFreqs));


                params.SmallSignalApprox=false;

            else
                harmonics=double(harmonics);
                assert(all(harmonics(tones>0)>0),'harmonics should be positive');
                harmonics(tones==0)=0;
                assert(prod(harmonics)<1000,'too many carriers; reduce the number of harmonics');






                if~params.SmallSignalApprox
                    solver=rfsolver.EnvelopeSolver(generalized_dae,tones,harmonics,params);
                else
                    solver=rfsolver.SmallSignalEnvelopeSolver(generalized_dae,tones,harmonics,params);
                end

                allFreqs=solver.freqs;
                FreqHarmonics=solver.Transform.FreqHarmonics;
            end

            C=generalized_dae.TimeDomainMatrix('DXY');
            D=generalized_dae.TimeDomainMatrix('DUY');

            EQBBcompatible=sp.DoFixedCost;


            [InputMap,nU]=map_simulink_freqs(inputData,allFreqs,FreqHarmonics,true,spf);
            [OutputMap,nY]=map_simulink_freqs(outputData,allFreqs,FreqHarmonics,false,spf);

            Y0=generalized_dae.Dae.Y(generalized_dae.Dae.inputs);




            time_step=sp.LocalSolverSampleTime/spf;
            [delayed_variables,delays]=generalized_dae.HistoryVariables;
            history=rfsolver.History(time_step,length(allFreqs),delayed_variables,delays);
            generalized_dae.History=history;




            if(~sepStream)
                rStream=RandStream.getGlobalStream;
            else
                rStream=RandStream('mt19937ar','Seed',double(int32(noiseSeed)));
            end




            [noiseFactor,isNoiseInd,isPhNoiseInd,isColPhNoiseInd,isWhPhNoiseInd,phNoiseResponse]=process_noise(allFreqs,FreqHarmonics,time_step,inputData);






            phNoiseHistoryVec=cell(1,length(isColPhNoiseInd));
            for PhNoiseInputInd=1:length(isColPhNoiseInd)
                phNoiseHistory=rfsolver.History(time_step,length(allFreqs),1,...
                size(phNoiseResponse{PhNoiseInputInd},3)*time_step);
                phNoiseHistoryVec{PhNoiseInputInd}=phNoiseHistory;
            end






            per_state=2*length(allFreqs)-1;



            num_history_states=2;






            nDiscreteStates=solver.nSavedStates+(dae.NumInputs+solver.NumStates)*per_state+num_history_states;

            data={'dae',dae
            'sp',sp
            'C',C
            'D',D
            'Y0',Y0
            'tones',tones
            'harmonics',harmonics
            'allFreqs',allFreqs
            'doNoise',doNoise
            'noiseFactor',noiseFactor
            'isNoiseInd',isNoiseInd
            'isPhNoiseInd',isPhNoiseInd
            'isColPhNoiseInd',isColPhNoiseInd
            'isWhPhNoiseInd',isWhPhNoiseInd
            'phNoiseResponse',{phNoiseResponse}
            'RandStream',rStream
            'InputMap',InputMap
            'OutputMap',OutputMap
            'nU',nU
            'nY',nY
            'nFreqs',length(allFreqs)
            'params',params
            'solver',solver
            'EQBBcompatible',EQBBcompatible
            'history',history
            'phNoiseHistoryVec',{phNoiseHistoryVec}
            'frameSize',spf
            'nDiscreteStates',nDiscreteStates}';

            res=struct(data{:});

        case 'FIELD'
            [data,id]=varargin{:};

            dae=data.dae;
            sp=data.sp;
            switch id
            case 'IsContinuousLti'

                res=false;
            case{'NumStates'
'NumDifferentialStates'
'NumMassMatrixNzMax'
'NumTrimResiduals'
'NumLinJacobianNzMax'
'NumZcs'
'NumDxfNzMax'
'NumDufNzMax'
'NumDtfNzMax'
'NumDxyNzMax'
'NumDxmNzMax'
                'NumDumNzMax'}

                res=0;
            case 'NumDiscreteStates'

                per_state=2*data.nFreqs-1;



                num_history_states=2;
                res=data.solver.nSavedStates+(data.dae.NumInputs+data.solver.NumStates)*per_state+num_history_states+data.nY;
            case 'NumInputs'
                res=data.nU;
            case 'NumOutputs'
                res=data.nY;
            case{'NumDuyNzMax','NumTDuyNzMax'}
                res=data.nU*data.nY;
            case 'FundamentalSampleTime'

                res=sp.LocalSolverSampleTime;
            case 'RefCount'
                res=1;
            case 'IsDyAnalytic'
                res=0;
            otherwise
                res=dae.(id);
            end

            res=double(res);
        case 'METHOD'
            [data,id,in]=varargin{:};

            switch id
            case{'DUF_P','DUM_P'}
                res=logical(sparse(0,data.nU));
            case{'DTF_P'}
                res=logical(sparse(0,1));
            case{'DXF_P','DXM_P','M_P'}
                res=logical(sparse(0,0));
            case{'DXY_P'}
                res=logical(sparse(data.nY,0));
            case{'DUF','DUM','DXF','DXM','DTF','DXY','F','M','XP0','ZC'}
                res=[];
            case{'ASSERT'
'DELAYS'
'SO'
'SP'
                'MODE'}
                in0=data.dae.inputs;
                res=data.dae.(id)(in0);
            case 'UDOT_REQ'
                res=int32(zeros(1,data.nU));
            case 'Y'
                res=in.D(data.nDiscreteStates+(1:data.nY));
            case 'DUY'
                res=[];
                assert(0,'Should never be called');
            case{'DUY_P','TDUY_P'}
                res=logical(sparse(ones(data.nY,data.nU)));
            case{'DXF_V_X','DUF_V_X'}
                res=int32(zeros(1,0));
            otherwise
                assert(0,'unknown METHOD');
            end
        case 'SOLVE'
            [data,id,in]=varargin{:};
            nPorts=numel(data.InputMap.isTimeDomain);
            Y=zeros(data.nY,1);
            for frameInd=1:data.frameSize



                inU=zeros(nPorts,1);
                nextPortDataStartInd=1;
                for portInd=1:nPorts
                    if data.InputMap.isTimeDomain(portInd)
                        inU(portInd)=in.U(nextPortDataStartInd);
                        nextPortDataStartInd=nextPortDataStartInd+1;
                    else
                        inU(portInd)=in.U(nextPortDataStartInd+frameInd-1);
                        nextPortDataStartInd=nextPortDataStartInd+data.frameSize;
                    end
                end
                switch id
                case{'CIC'
'CONSAT'
'NUDGE'
                    'RESET'}

                case{'IC_MODE'}

















                    [X_prev,~,discrete]=ExtractStates(in.D,data);
                    data.history.initialize;

                    U=system_input(data,inU,data.EQBBcompatible);
                    U(data.isNoiseInd,:)=0;

                    if(data.RandStream~=RandStream.getGlobalStream)
                        data.RandStream.reset;
                    end

                    for PhNoiseInputInd=1:length(data.phNoiseHistoryVec)
                        wNoise=randn(data.RandStream,[size(data.noiseFactor),size(data.phNoiseResponse{PhNoiseInputInd},3)/2]);
                        wNoise(data.isColPhNoiseInd,[1,(end+1)/2+1:end],:)=0;
                        data.phNoiseHistoryVec{PhNoiseInputInd}.initialize;
                        data.phNoiseHistoryVec{PhNoiseInputInd}.initialize(wNoise(data.isColPhNoiseInd,:,:));
                    end
                    data.solver.resetInternalVars;
                    U_prev=U;

                    h=max(100*data.solver.Dae.MaxDelay,0.01);
                    while h<1e9
                        ssc_rf_log(1,sprintf('\n    DC, step %g',h));

                        isSteadyState=true;
                        [X,discrete,success]=data.solver.TakeStep(U,X_prev,U_prev,discrete,h,'be',isSteadyState);
                        assert(success,'Solver failed at DC',in.T);

                        if norm(X-X_prev)<data.params.RelTol*norm(X)+data.params.AbsTol
                            break;
                        end

                        X_prev=X;
                        h=h*2.395026619987486;
                    end

                    data.history.initialize(X);


                    in.D=StoreStates(in.D,data,X,U,...
                    discrete,data.history.StartingIndex,0);



                    data.solver.Dae.Convolution=[];




                    tmpY=computeY(in,data,inU,frameInd);
                    Y(frameInd:data.frameSize:end)=tmpY;

                    id='CIC_MODE';

                case{'CIC_MODE'}

                    h=data.sp.LocalSolverSampleTime/data.frameSize;

                    inT=in.T+(frameInd-1)*h;
                    ssc_rf_log(1,sprintf('\n    time %g',inT));

                    U=system_input(data,inU,data.EQBBcompatible);

                    integration_method=data.params.HbIntegrationMethod;
                    if inT<2.000001*h
                        integration_method='be';
                        U(data.isNoiseInd,:)=0;
                    else
                        if data.doNoise

                            wNoise=randn(data.RandStream,size(data.noiseFactor));
                            wNoise(data.isNoiseInd,:)=bsxfun(@times,wNoise(data.isNoiseInd,:),U(data.isNoiseInd,1));
                            U(data.isNoiseInd,:)=data.noiseFactor(data.isNoiseInd,:)/sqrt(h).*wNoise(data.isNoiseInd,:);


                            if(~isempty(data.isPhNoiseInd))
                                wNoise(data.isColPhNoiseInd,[1,(end+1)/2+1:end])=0;
                                phNoiseExp=(wNoise(data.isWhPhNoiseInd,2:(end+1)/2).*data.noiseFactor(data.isWhPhNoiseInd,2:(end+1)/2))/sqrt(h);
                                phNoiseI=cos(phNoiseExp);
                                phNoiseQ=sin(phNoiseExp);
                                U(data.isWhPhNoiseInd,2:end)=[(U(data.isWhPhNoiseInd,2:(end+1)/2).*phNoiseI-U(data.isWhPhNoiseInd,(end+1)/2+1:end).*phNoiseQ)...
                                ,(U(data.isWhPhNoiseInd,2:(end+1)/2).*phNoiseQ+U(data.isWhPhNoiseInd,(end+1)/2+1:end).*phNoiseI)];


                                for PhNoiseInputInd=1:length(data.isColPhNoiseInd)
                                    isColPhNoiseIndVal=data.isColPhNoiseInd(PhNoiseInputInd);
                                    phNoiseResp=data.phNoiseResponse{PhNoiseInputInd};
                                    phNoiseExp=(wNoise(isColPhNoiseIndVal,1:(end+1)/2).*phNoiseResp(1,:,1)...
                                    +data.phNoiseHistoryVec{PhNoiseInputInd}.convolve(phNoiseResp))/sqrt(h);
                                    data.phNoiseHistoryVec{PhNoiseInputInd}.push_back(wNoise(isColPhNoiseIndVal,:));
                                    phNoiseI=cos(phNoiseExp(2:end));
                                    phNoiseQ=sin(phNoiseExp(2:end));
                                    U(isColPhNoiseIndVal,2:end)=[(U(isColPhNoiseIndVal,2:(end+1)/2).*phNoiseI-U(isColPhNoiseIndVal,(end+1)/2+1:end).*phNoiseQ)...
                                    ,(U(isColPhNoiseIndVal,2:(end+1)/2).*phNoiseQ+U(isColPhNoiseIndVal,(end+1)/2+1:end).*phNoiseI)];
                                end
                            end
                        else
                            U(data.isNoiseInd,:)=0;
                        end
                    end


                    [X_prev,U_prev,discrete,history_index,convolution_index]=ExtractStates(in.D,data);
                    data.history.StartingIndex=history_index;


                    dae=data.solver.Dae;
                    if isempty(dae.Convolution)
                        dae.Convolution=rfsolver.Convolution(h,data.allFreqs,dae,X_prev);
                    else
                        dae.Convolution.History.StartingIndex=convolution_index;
                    end


                    isSteadyState=false;
                    [X,discrete,success]=data.solver.TakeStep(U,X_prev,U_prev,discrete,h,integration_method,isSteadyState);

                    data.history.push_back(X);
                    dae.Convolution.History.push_back(X);


                    in.D=StoreStates(in.D,data,X,U,...
                    discrete,data.history.StartingIndex,...
                    dae.Convolution.History.StartingIndex);

                    assert(success,'Solver failed at time %f',inT);

                    tmpY=computeY(in,data,inU,frameInd);
                    Y(frameInd:data.frameSize:end)=tmpY;

                otherwise
                    pm_assert(0);
                end

            end
            in.D(data.nDiscreteStates+(1:data.nY))=Y;
            res=in;
        end

    catch me
        me.getReport('extended')
        me.rethrow;
    end

end

function sanity_check(dae,sp)
    assert(~sp.UseLocalSolver,'turn off the "local solver" option at Simscape Solver Configuration dialog');
    assert(dae.IsDae,'dae.IsDae is false');
    assert(dae.NumInputs>0,'system does not have inputs');
    assert(dae.NumOutputs>0,'system does not have outputs');
    assert(dae.IsMConstant,'mass matrix is not constant; dae.IsMConstant is false');
    assert(dae.IsYLinear,'output is not linear; dae.IsYLinear is false');
    assert(dae.InputOrder==1,'no input derivatives (index reduction) is not allowed; dae.InputOrder ~= 1');
    in=dae.inputs;
    assert(isempty(in.Q),'dae.inputs.Q is non-empty');
    assert(isempty(in.E),'dae.inputs.E is non-empty');
    assert(isempty(in.CR),'dae.inputs.CR is non-empty');
    assert(isempty(in.CI),'dae.inputs.CI is non-empty');
    assert(isempty(in.D),'model has discrete states');
    assert(dae.IsDyAnalytic,'model is not analytic');
end

function U=system_input(data,U,EQBBcompatible)

    nNonPeriodicInputPorts=sum(data.InputMap.isTimeDomain);
    assert(length(U)==((data.nU-nNonPeriodicInputPorts)/data.frameSize)+nNonPeriodicInputPorts);


    Ureal=U.*data.InputMap.isReal;
    sign=data.InputMap.isSameSign-~data.InputMap.isSameSign;
    Uimag=U.*~data.InputMap.isReal.*sign;
    Uvalues=Ureal+1j*Uimag;


    U=full(sparse(data.InputMap.daeUYindex,data.InputMap.freqIndex,Uvalues,...
    data.dae.NumInputs,data.nFreqs));

    if EQBBcompatible
        U(:,2:end)=U(:,2:end)*sqrt(2);
    end

    U=[real(U),imag(U(:,2:end))];
end

function freqs=initialize_freqs(inputData,outputData,dae)







    freqs=0;
    for i=1:length(inputData)
        freqs=[freqs;inputData(i).Frequencies(:)];%#ok<AGROW>
    end
    for i=1:length(outputData)
        freqs=[freqs;outputData(i).Frequencies(:)];%#ok<AGROW>
    end
    freqs=unique(freqs);




    assert(all(freqs>=0));


    assert(sum(arrayfun(@(x)prod(x.Dimension),dae.Input))==length(inputData));
    assert(length(dae.Output)==length(outputData));
end

function[map,nSimulinkSamples]=map_simulink_freqs(portData,allFreqs,freqHarmonics,is_input_map,spf)




    pseudoPeriodic=[portData.PseudoPeriodic];
    fh=@(x)(length(x.Frequencies));
    nSimulinkData=2*sum(arrayfun(fh,portData(pseudoPeriodic)))+...
    length(find(~pseudoPeriodic));
    nSimulinkSamples=2*sum(arrayfun(fh,portData(pseudoPeriodic)))*spf+...
    length(find(~pseudoPeriodic));

    freqHarmonics=sum(abs(freqHarmonics),2);



    map.daeUYindex=zeros(nSimulinkData,1);
    map.freqIndex=ones(nSimulinkData,1);
    map.isReal=ones(nSimulinkData,1);
    map.isSameSign=ones(nSimulinkData,1);
    map.isTimeDomain=zeros(nSimulinkData,1);

    if~is_input_map
        map.freqIndex=num2cell(map.freqIndex);
        map.isSameSign=num2cell(map.isSameSign);
    end

    count=0;
    for i=1:length(portData)
        nW=length(portData(i).Frequencies);
        if~portData(i).PseudoPeriodic
            count=count+1;
            map.daeUYindex(count)=i;
            map.isTimeDomain(count)=1;
            if~is_input_map
                if nW==0
                    freq_indices=1:length(allFreqs);
                else
                    freq_indices=[];
                    for j=1:nW
                        freq=portData(i).Frequencies(j);
                        index=find_freq(freq,allFreqs,freqHarmonics,false);
                        freq_indices=[freq_indices,reshape(index,1,[])];%#ok<AGROW>
                    end
                end
                map.freqIndex{count}=unique(freq_indices);
            end
        else
            for j=1:nW
                count=count+1;
                freq=portData(i).Frequencies(j);
                [index,isSameSign]=find_freq(freq,allFreqs,freqHarmonics,is_input_map);
                assert(all(index>0)&&~isempty(index));
                map.daeUYindex(count+[0,nW])=i;

                if is_input_map
                    map.freqIndex(count+[0,nW])=index;
                    map.isSameSign(count+[0,nW])=isSameSign;
                else
                    map.freqIndex{count}=index;
                    map.freqIndex{count+nW}=index;
                    map.isSameSign{count}=isSameSign;
                    map.isSameSign{count+nW}=isSameSign;
                end

                map.isReal(count+nW)=0;
            end
            count=count+nW;
        end
    end
    assert(count==nSimulinkData);

end





function[index,isSameSign]=find_freq(freq,allFreqs,harmonics,only_smallest)

    match=find(abs(abs(allFreqs)-abs(freq))<1e-8*abs(allFreqs)+1e-8);
    assert(~isempty(match),sprintf('Frequency %g is not found in the carrier list. Check inports/outports and simulation setup',freq));

    if only_smallest
        [~,best]=min(harmonics(match));
        match=match(best);
    end

    index=match;
    isSameSign=sign(allFreqs(match))==sign(freq);

    if length(index)>1
        str=sprintf('Frequency %g has multiple matches for the following harmonics',freq);
        ssc_rf_log(2,str,index);
    end
end








function[noise_factor,isNoiseInd,isPhNoiseInd,isColPhNoiseInd,isWhPhNoiseInd,phNoise_resp]=process_noise(freqs,freqHarmonics,step,inputData)
    NONE=1;
    WHITE=2;
    PWL=3;
    PHASE=4;
    WRONG=5;

    freqHarmonics=sum(abs(freqHarmonics),2);

    distribution=[inputData.NoiseDistribution];
    n_params=arrayfun(@(x)(length(x.NoiseParameters)),inputData);


    distribution((distribution==WHITE)&(n_params>1))=PHASE;
    assert(all(distribution>0)&&all(distribution<WRONG),'wrong distribution');

    isNoise=((distribution~=NONE)&(distribution~=PHASE));
    isPhNoise=(distribution==PHASE);
    isColPhNoiseInput=isPhNoise;

    n_portFreqs_noDC=arrayfun(@(x)(length(x.Frequencies(x.Frequencies>0))),inputData);

    is_scalar_input=[inputData.PseudoPeriodic]==0;
    assert(all(is_scalar_input(isNoise)),'noise inputs should be scalar, switch PseudoPeriodic flag off');


    n_ports=length(inputData);
    freqs=freqs(:)';
    n_intFreqs=length(freqs);
    noise_factor=zeros(n_ports,2*n_intFreqs-1);

    assert(all(mod(n_params(isPhNoise),n_portFreqs_noDC(isPhNoise))==0),'wrong length of noise parameters');
    PhNoiseInputInd=1;
    phNoise_resp={};

    for i=find(distribution~=NONE)
        params=inputData(i).NoiseParameters;
        if(isPhNoise(i))


            params=reshape(params,[],n_portFreqs_noDC(i)).';
            portFreqs=sort(inputData(i).Frequencies);

            assert(all(portFreqs(portFreqs>0)==params(:,1)),'port carriers and noise parameters carriers do not match');
            assert(mod(size(params,2)-1,2)==0,'wrong length of noise parameters');
            phNoiseDensitys=params(:,1+((end-1)/2+1):end);
            assert(all(phNoiseDensitys(:)>=0),'phase noise density is negative');
            if(all(std(phNoiseDensitys,[],2)<=1e-8*mean(phNoiseDensitys,2)))
                isColPhNoiseInput(i)=false;
                for phCarrInd=1:size(params,1)
                    carr_val=params(phCarrInd,1);
                    if(carr_val~=0)
                        noise_factor(i,find_freq(params(phCarrInd,1),freqs,freqHarmonics,true))=sqrt(mean(phNoiseDensitys(phCarrInd,:)));
                    end
                end
            else
                num_samples=2^ceil(log2((size(params,2)-1)/2));
                ifftlen=num_samples;
                freq_range=((-ifftlen/2):(ifftlen/2-1))/(ifftlen*step);
                max_freq_range=freq_range(end)+2/(ifftlen*step);
                phNoiseRes=zeros(1,n_intFreqs,num_samples);
                for phCarrInd=1:size(params,1)
                    carr_val=params(phCarrInd,1);
                    if(carr_val~=0)
                        phNoise_freqs=params(phCarrInd,1+(1:(size(params,2)-1)/2));
                        phNoiseDensity=phNoiseDensitys(phCarrInd,:);
                        phNoiseDensityInt=interp1([-max_freq_range,phNoise_freqs,max_freq_range],...
                        [phNoiseDensity(1),phNoiseDensity,phNoiseDensity(end)],freq_range);



                        phNoiseRes(1,find_freq(params(phCarrInd,1),freqs,freqHarmonics,true),:)=...
                        rfsolver.ImpulseResponse(step,num_samples,0,freq_range,sqrt(phNoiseDensityInt),2);
                        assert(isreal(phNoiseRes(1,find_freq(params(phCarrInd,1),freqs,freqHarmonics,true),:)),'Impulse response for phase noise is not real');
                    end
                end
                phNoise_resp{PhNoiseInputInd}=phNoiseRes;%#ok<AGROW>
                PhNoiseInputInd=PhNoiseInputInd+1;
            end
        else
            switch distribution(i)
            case WHITE
                noise_freqs=0;
                if n_params(i)>1
                    assert(n_params(i)==1,'wrong length of noise parameters');
                    noise_density=reshape(params,258,[]);
                else
                    noise_density=params(1);
                end
            case PWL
                assert(mod(n_params(i),2)==0&&n_params(i)>0,'wrong length of noise parameters');
                n_noise_freqs=n_params(i)/2;
                noise_freqs=params(1:n_noise_freqs);
                noise_density=params(n_noise_freqs+1:end);
            case NONE
            otherwise
                assert(false,'wrong noise type');
            end
            assert(all(noise_density>=0),'noise density is negative');
            assert(all(noise_freqs>=0),'noise frequencies should be non-negative');
            assert(issorted(noise_freqs),'noise frequencies are not sorted');
            assert(noise_freqs(1)==0,'DC noise frequency is not provided');


            if length(noise_freqs)==1
                noise_freqs(end+1)=noise_freqs+1;%#ok<AGROW>
                noise_density(end+1)=noise_density;%#ok<AGROW>
            end


            density=interp1(noise_freqs,noise_density,abs(freqs),'linear');
            density(abs(freqs)<=noise_freqs(1))=noise_density(1);
            density(abs(freqs)>=noise_freqs(end))=noise_density(end);
            uniqueFreqInd=arrayfun(@(x)find_freq(x,freqs,freqHarmonics,true),freqs);
            density(~ismember(1:length(freqs),uniqueFreqInd))=0;

            density(:,1)=density(:,1)/2;
            factor=sqrt(density);


            noise_factor(i,:)=[factor,factor(2:end)];
        end
    end
    isNoiseInd=find(isNoise);
    isPhNoiseInd=find(isPhNoise);
    isColPhNoiseInd=find(isColPhNoiseInput);
    isWhPhNoiseInput=(isPhNoise)&(~isColPhNoiseInput);
    isWhPhNoiseInd=find(isWhPhNoiseInput);
end


function SavedStates=StoreStates(SavedStates,data,X,U,rest,history_index,convolution_index)
    per_state=2*length(data.allFreqs)-1;

    nX=data.solver.NumStates*per_state;
    SavedStates(1:nX)=X(:);

    nU=data.dae.NumInputs*per_state;
    SavedStates(nX+(1:nU))=U(:);

    SavedStates((nX+nU)+1:data.nDiscreteStates-2)=rest(:);


    SavedStates(data.nDiscreteStates-1)=history_index;
    SavedStates(data.nDiscreteStates)=convolution_index;
end



function[X,U,rest,history_index,convolution_index]=ExtractStates(SavedStates,data)
    per_state=2*length(data.allFreqs)-1;

    nX=data.solver.NumStates*per_state;
    X=reshape(SavedStates(1:nX),data.solver.NumStates,per_state);

    nU=data.dae.NumInputs*per_state;
    U=reshape(SavedStates(nX+(1:nU)),data.dae.NumInputs,per_state);

    rest=SavedStates((nX+nU)+1:data.nDiscreteStates-2);
    history_index=SavedStates(data.nDiscreteStates-1);
    convolution_index=SavedStates(data.nDiscreteStates);
end

function res=computeY(in,data,inU,frameInd)
    nOutput=data.nY/data.frameSize;

    res=zeros(nOutput,1);
    inT=in.T+(frameInd-1)*data.sp.LocalSolverSampleTime/data.frameSize;
    U=system_input(data,inU,data.EQBBcompatible);
    [X,U_solved]=ExtractStates(in.D,data);




    U(data.isNoiseInd,:)=U_solved(data.isNoiseInd,:);
    U(data.isPhNoiseInd,:)=U_solved(data.isPhNoiseInd,:);
    if data.params.SmallSignalApprox&&(~isempty(data.solver.isSteadyState)&&~data.solver.isSteadyState)
        X=X+data.solver.XSS;
    end
    Y=data.C*X+data.D*U;
    Y=[Y(:,1),Y(:,2:data.nFreqs)+1j*Y(:,data.nFreqs+1:end)];
    Y(:,1)=Y(:,1)+data.Y0;

    for i=1:nOutput
        indices=data.OutputMap.freqIndex{i};
        y=Y(data.OutputMap.daeUYindex(i),indices);
        if data.OutputMap.isTimeDomain(i)
            res(i)=real(y*exp(2*pi*1j*data.allFreqs(indices)*inT));
        else
            is_dc=indices(1)==1;

            scale=1;
            if~is_dc&&data.EQBBcompatible
                scale=1/sqrt(2);
            end

            if data.OutputMap.isReal(i)
                res(i)=scale*sum(real(y));
            elseif~is_dc
                sign=data.OutputMap.isSameSign{i}*2-1;
                res(i)=scale*sum(sign'.*imag(y));
            end
        end
    end
end

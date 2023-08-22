function jx=jac_s(net,P,PD,BZ,IWZ,LWZ,N,Ac,T,EW,Q,TS,hints)

    numLayerDelays=net.numLayerDelays;
    BC=cell(1,net.numLayers);
    for i=find(net.biasConnect)'
        BC{i}=i;
    end
    ICF=hints.inputConnectFrom;
    LCF=hints.layerConnectFrom;
    LCT=hints.layerConnectTo;

    S=hints.totalOutputSize;
    QS=Q*S;
    gE=nndata(nn.output_sizes(net),Q,TS,-1);
    gE=remove_dont_care_errors(gE,T);

    gE=gmultiply(gE,gsqrt(EW));
    gE=nn_performance_fcn.normalize_error(net,gE,hints.perform.param);

    gE=stretch(gE);
    gE=outputs2layersE(net,gE,hints);

    A=cell(net.numLayers,TS);
    for i=hints.outputInd
        for ts=1:TS
            A{i,ts}=repcolint(Ac{i,numLayerDelays+ts},S);
        end
    end
    gE=nn7.dperf(net,A,gE,QS,hints);

    expandIndices=floor((0:(QS-1))/S)+1;
    for i=find(net.biasConnect)'
        BZ{i}=BZ{i}(:,expandIndices);
    end
    for ts=1:TS
        for i=1:net.numLayers
            for j=find(net.inputConnect(i,:))
                IWZ{i,j,ts}=IWZ{i,j,ts}(:,expandIndices);
            end
        end
        for i=1:net.numLayers
            for j=find(net.layerConnect(i,:))
                LWZ{i,j,ts}=LWZ{i,j,ts}(:,expandIndices);
            end
        end
        for i=1:net.numLayers
            N{i,ts}=N{i,ts}(:,expandIndices);
        end
    end
    for ts=1:TS+numLayerDelays;
        for i=1:net.numLayers
            Ac{i,ts}=Ac{i,ts}(:,expandIndices);
        end
    end

    Q=QS;

    gA=cell(net.numLayers,TS);
    gN=cell(net.numLayers,TS);
    gBZ=cell(net.numLayers,TS);
    gIWZ=cell(net.numLayers,net.numInputs,TS);
    gLWZ=cell(net.numLayers,net.numLayers,TS);
    gB=gBZ;
    gIW=gIWZ;
    gLW=gIWZ;

    for ts=TS:-1:1
        for i=hints.bpLayerOrder

            if net.outputConnect(i)
                gA{i,ts}=gE{i,ts};
            else
                gA{i,ts}=zeros(net.layers{i}.size,Q);
            end

            for k=LCT{i}
                if(any(net.layerWeights{k,i}.delays==0))
                    ZeroDelayW=net.LW{k,i}(:,1:net.layerWeights{k,i}.size(2));
                    weightFcn=hints.layerWeights(k,i).weight;
                    temp=weightFcn.dz_dp(ZeroDelayW,Ac{i,ts+numLayerDelays},LWZ{k,i,ts},weightFcn.param);
                    if iscell(temp)
                        for qq=1:Q,
                            gA{i,ts}(:,qq)=gA{i,ts}(:,qq)+temp{qq}'*gLWZ{k,i,ts}(:,qq);
                        end
                    else
                        gA{i,ts}=gA{i,ts}+temp'*gLWZ{k,i,ts};
                    end
                end
            end
            transferFcn=hints.layers(i).transfer;
            Fdot=transferFcn.da_dn(N{i,ts},Ac{i,ts+numLayerDelays},transferFcn.param);
            if iscell(Fdot)
                gN{i,ts}=zeros(net.layers{i}.size,Q);
                for qq=1:Q
                    gN{i,ts}(:,qq)=Fdot{qq}'*gA{i,ts}(:,qq);
                end
            else
                gN{i,ts}=Fdot.*gA{i,ts};
            end
            netFcn=hints.layers(i).netInput;
            Z=[BZ(BC{i}),IWZ(i,ICF{i},ts),LWZ(i,LCF{i},ts)];
            jjj=0;

            if net.biasConnect(i)
                jjj=jjj+1;
                gBZ{i,ts}=netFcn.dn_dzj(jjj,Z,N{i,ts},netFcn.param).*gN{i,ts};
            end

            for j=ICF{i}
                jjj=jjj+1;
                fcn=hints.layers(i).netInput;
                gIWZ{i,j,ts}=fcn.dn_dzj(jjj,Z,N{i,ts},fcn.param).*gN{i,ts};
            end

            for j=LCF{i}
                jjj=jjj+1;
                fcn=hints.layers(i).netInput;
                gLWZ{i,j,ts}=fcn.dn_dzj(jjj,Z,N{i,ts},fcn.param).*gN{i,ts};
            end
        end
    end
    inputWeightCols=hints.inputWeightCols;
    layerWeightCols=hints.layerWeightCols;

    for ts=1:TS
        for i=1:net.numLayers

            gB{i,ts}=gBZ{i,ts};

            for j=ICF{i}
                pd=nn7.delayed_inputs(net,P,PD,i,j,ts);
                pd=pd(:,expandIndices);
                weightFcn=hints.inputWeights(i,j).weight;
                sW=weightFcn.dz_dw(net.IW{i,j},pd,IWZ{i,j,ts},weightFcn.param);

                if iscell(sW)
                    temp=zeros(0,Q);
                    for jjj=1:inputWeightCols(i,j)
                        for ss=1:size(net.IW{i,j},1)
                            temp=[temp;sW{ss}(jjj,:)];
                        end
                    end
                    gIW{i,j,ts}=reprow(gIWZ{i,j,ts},inputWeightCols(i,j)).*temp;
                elseif weightFcn.weightDerivType==2,
                    temp=[];
                    for ss=1:size(net.IW{i,j},1)
                        temp=[temp;sum(reshape(sW(:,ss,:),[net.layers{i}.size(1),Q]).*gIWZ{i,j,ts},1)];
                    end
                    gIW{i,j,ts}=temp;
                else
                    gIW{i,j,ts}=reprow(gIWZ{i,j,ts},inputWeightCols(i,j)).*...
                    reprowint(sW,net.inputWeights{i,j}.size(1));
                end

            end

            for j=LCF{i}
                Ad=cell2mat(Ac(j,ts+numLayerDelays-net.layerWeights{i,j}.delays)');
                weightFcn=hints.layerWeights(i,j).weight;
                sW=weightFcn.dz_dw(net.LW{i,j},Ad,LWZ{i,j,ts},weightFcn.param);
                if iscell(sW)
                    temp=zeros(0,Q);
                    for jjj=1:layerWeightCols(i,j)
                        for ss=1:size(net.LW{i,j},1)
                            temp=[temp;sW{ss}(jjj,:)];
                        end
                    end
                    gLW{i,j,ts}=reprow(gLWZ{i,j,ts},layerWeightCols(i,j)).*temp;
                elseif weightFcn.weightDerivType==2,
                    temp=[];
                    for ss=1:size(net.LW{i,j},1)
                        temp=[temp;sum(reshape(sW(:,ss,:),[net.layers{i}.size(1),Q]).*gLWZ{i,j,ts},1)];
                    end
                    gLW{i,j,ts}=temp;
                else
                    gLW{i,j,ts}=reprow(gLWZ{i,j,ts},layerWeightCols(i,j)).*...
                    reprowint(sW,net.layers{i}.size);
                end
            end
        end
    end

    inputLearn=hints.inputLearn;
    layerLearn=hints.layerLearn;
    biasLearn=hints.biasLearn;
    inputWeightInd=hints.inputWeightInd;
    layerWeightInd=hints.layerWeightInd;
    biasInd=hints.biasInd;

    jx=zeros(hints.xLen,QS*TS);
    for i=1:net.numLayers
        for j=find(inputLearn(i,:))
            if~isempty(inputWeightInd{i,j})
                jx(inputWeightInd{i,j},:)=[gIW{i,j,:}];
            end
        end
        for j=find(layerLearn(i,:))
            if~isempty(layerWeightInd{i,j})
                jx(layerWeightInd{i,j},:)=[gLW{i,j,:}];
            end
        end
        if biasLearn(i)
            jx(biasInd{i},:)=[gB{i,:}];
        end
    end


    function gE=remove_dont_care_errors(gE,T)

        for i=1:numel(gE)
            gei=gE{i};
            gei(isnan(T{i}))=0;
            gE{i}=gei;
        end


        function gE2=stretch(gE1)

            [N,Q,TS]=nnfast.nnsize(gE1);
            S=sum(N);
            QS=Q*S;
            gE2=cell(length(N),TS);
            inputPos=0;
            for i=1:length(N)
                ni=N(i);
                for ts=1:TS
                    ge1=gE1{i,ts};
                    ge2=zeros(ni,QS);
                    for q=1:Q
                        ge2(:,(q-1)*S+inputPos+(1:ni))=diag(ge1(:,q));
                    end
                    gE2{i,ts}=ge2;
                end
                inputPos=inputPos+ni;
            end


            function e2=outputs2layersE(net,e1,hints)
                e2=cell(net.numLayers,size(e1,2));
                e2(hints.outputInd,:)=e1;


                function m=repcolint(m,n)

                    mcols=size(m,2);
                    m=m(:,floor((0:(mcols*n-1))/n)+1);


                    function m=reprow(m,n)

                        mrows=size(m,1);
                        m=m(rem(0:(mrows*n-1),mrows)+1,:);


                        function m=reprowint(m,n)

                            mrows=size(m,1);
                            m=m(floor((0:(mrows*n-1))/n)+1,:);




function[gB,gIW,gLW]=grad_btt(net,P,PD,BZ,IWZ,LWZ,N,Ac,gE,Q,TS,hints,time_base)

    if nargin<13,time_base=0;end

    numLayers=net.numLayers;
    numInputs=net.numInputs;
    biases=net.biases;
    layerWeights=net.layerWeights;
    inputWeights=net.inputWeights;
    layers=net.layers;
    bpLayerOrder=hints.bpLayerOrder;
    numLayerDelays=net.numLayerDelays;
    outputConnect=net.outputConnect;
    biasConnect=net.biasConnect;
    ICF=hints.inputConnectFrom;
    LCF=hints.layerConnectFrom;
    LCT=hints.layerConnectTo;
    LCTOZD=hints.layerConnectToOZD;
    IW=net.IW;
    LW=net.LW;
    layerDelays=hints.layerDelays;

    LCTWD=cell(numLayers);
    for i=1:numLayers
        LCTWD{i}=setxor(LCT{i},LCTOZD{i},'legacy');
    end

    Ad=cell(numLayers,numLayers,TS);
    for i=1:numLayers
        for j=LCF{i}
            for ts=1:TS
                Ad{i,j,ts}=nnfast.tapdelay(Ac,j,ts+numLayerDelays,layerDelays{i,j});
            end
        end
    end

    Ae=cell(numLayers,1);
    for i=1:numLayers
        Ae{i}=[Ac{i,(1+numLayerDelays):end}];
    end

    gBZ=[];
    gIWZ=cell(numLayers,numInputs);
    gLWZ=cell(numLayers,numLayers);
    geIW=cell(numLayers,numInputs,Q,TS);
    geLW=cell(numLayers,numLayers,Q,TS);
    SS=hints.totalOutputSize;
    gTa=cell(numLayers,Q,TS+1+numLayerDelays,TS+1+numLayerDelays,SS);
    gTa_safe=~isempty(gTa);
    QS=Q*SS;

    if time_base
        gB=cell(numLayers,TS*QS);
        gIW=cell(numLayers,net.numInputs,TS*QS);
        gLW=cell(numLayers,numLayers,TS*QS);
    else
        gB=cell(numLayers,1);
        gIW=cell(numLayers,net.numInputs);
        gLW=cell(numLayers,numLayers);
    end
    S=cell(numLayers,numLayers);

    Uprime=[];

    ES=cell(1,numLayers);

    for i=bpLayerOrder
        for u=Uprime
            fcn=hints.layers(i).transfer;
            S_temp=nnprop.da_dn(i,fcn,1:TS,Q,Ae,numLayerDelays,N,1,net.layers{i}.size);

            for k=LCTOZD{i}
                if size(S{u,k},1)>0

                    if size(S{u,i},1)==0
                        S{u,i}=zeros(layers{u}.size,layers{i}.size,Q,TS);
                    end
                    fcn=hints.layerWeights(k,i).weight;

                    if fcn.is_dotprod
                        for qq=1:Q
                            for ts=1:TS
                                S{u,i}(:,:,qq,ts)=S{u,i}(:,:,qq,ts)+((gLWZ{k,i,u}(:,:,qq,ts)'.*S{u,k}(:,:,qq,ts))*LW{k,i}*S_temp(:,:,qq,ts));
                            end
                        end
                    else
                        for ts=1:TS
                            for qq=1:Q

                                dp=fcn.dz_dp(LW{k,i},Ae{i}(:,(ts-1)*Q+qq),LWZ{k,i,ts}(:,qq),fcn.param);

                                if iscell(dp)
                                    S{u,i}(:,:,qq,ts)=S{u,i}(:,:,qq,ts)+((gLWZ{k,i,u}(:,:,qq,ts)'.*S{u,k}(:,:,qq,ts))*dp{1}*S_temp(:,:,qq,ts));
                                else
                                    S{u,i}(:,:,qq,ts)=S{u,i}(:,:,qq,ts)+((gLWZ{k,i,u}(:,:,qq,ts)'.*S{u,k}(:,:,qq,ts))*dp*S_temp(:,:,qq,ts));
                                end
                            end
                        end
                    end

                    for ts=TS+1:TS+1+numLayerDelays
                        S{u,i}(:,:,qq,ts)=zeros(layers{u}.size,layers{i}.size);
                    end
                end
            end
        end

        if outputConnect(i)||size(LCTWD{i},1)~=0
            fcn=hints.layers(i).transfer;
            S{i,i}=nnprop.da_dn(i,fcn,1:TS,Q,Ae,numLayerDelays,N,1,net.layers{i}.size);

            Uprime=[Uprime,i];

            ES{i}=[ES{i},i];
        end

        netFcn=hints.layers(i).netInput;
        jjj=0;
        if netFcn.is_netsum
            dz=ones(net.layers{i}.size,Q);
        end

        if biasConnect(i)
            jjj=jjj+1;
            for ts=1:TS
                if~netFcn.is_netsum
                    Z=[BZ(i,biasConnect(i)),IWZ(i,ICF{i},ts),LWZ(i,LCF{i},ts)];
                    dz=netFcn.dn_dzj(jjj,Z,N{i,ts},netFcn.param);
                end
                for qq=1:Q

                    for k=Uprime
                        gBZ{i,k}(:,:,qq,ts)=dz(:,qq+zeros(1,layers{k}.size));
                    end
                end
            end

            if time_base
                [gB{i,1:TS*QS}]=deal(zeros(biases{i}.size,1));
            else
                gB{i}=zeros(biases{i}.size,1);
            end
        end

        for j=ICF{i}
            jjj=jjj+1;
            for ts=1:TS

                if~netFcn.is_netsum
                    Z=[BZ(i,biasConnect(i)),IWZ(i,ICF{i},ts),LWZ(i,LCF{i},ts)];
                    dz=netFcn.dn_dzj(jjj,Z,N{i,ts},netFcn.param);
                end

                for k=Uprime
                    layerSize=layers{k}.size;
                    for qq=1:Q
                        gIWZ{i,j,k}(:,:,qq,ts)=dz(:,qq+zeros(1,layerSize));
                    end
                end
                weightFcn=hints.inputWeights(i,j).weight;
                for qq=1:Q
                    pd=nntraining.pd(net,Q,P,PD,i,j,ts,qq);
                    if weightFcn.is_dotprod
                        geIW{i,j,qq,ts}=pd';
                    else
                        geIW{i,j,qq,ts}=weightFcn.dz_dw(...
                        IW{i,j},pd,IWZ{i,j,ts}(:,qq),weightFcn.param)';
                    end
                end
            end

            for ts=TS+(1:numLayerDelays)
                for qq=1:Q
                    for k=Uprime
                        gIWZ{i,j,k}(:,:,qq,ts)=zeros(size(gIWZ{i,j,k}(:,:,1,1)));
                    end
                end
            end

            if time_base
                [gIW{i,j,1:TS*QS}]=deal(zeros(inputWeights{i,j}.size));
            else
                gIW{i,j}=zeros(inputWeights{i,j}.size);
            end
        end

        for j=LCF{i}
            jjj=jjj+1;
            for ts=1:TS

                if~netFcn.is_netsum
                    Z=[BZ(i,biasConnect(i)),IWZ(i,ICF{i},ts),LWZ(i,LCF{i},ts)];
                    dz=netFcn.dn_dzj(jjj,Z,N{i,ts},netFcn.param);
                end

                for qq=1:Q

                    for k=Uprime
                        gLWZ{i,j,k}(:,:,qq,ts)=dz(:,qq+zeros(1,layers{k}.size));
                    end
                end
                weightFcn=hints.layerWeights(i,j).weight;
                for qq=1:Q
                    if weightFcn.is_dotprod
                        geLW{i,j,qq,ts}=Ad{i,j,ts}(:,qq)';
                    else
                        geLW{i,j,qq,ts}=weightFcn.dz_dw(...
                        LW{i,j},Ad{i,j,ts}(:,qq),LWZ{i,j,ts}(:,qq),weightFcn.param)';
                    end
                end
            end

            for ts=TS+1:TS+1+numLayerDelays
                for qq=1:Q
                    for k=Uprime
                        gLWZ{i,j,k}(:,:,qq,ts)=zeros(size(gLWZ{i,j,k}(:,:,1,1)));
                    end
                end
            end

            if time_base
                [gLW{i,j,1:TS*QS}]=deal(zeros(layerWeights{i,j}.size));
            else
                gLW{i,j}=zeros(layerWeights{i,j}.size);
            end
        end
    end

    if gTa_safe
        if time_base
            for jz=fliplr(Uprime)
                zzeros=zeros(layers{jz}.size,1);
                for qq=1:Q,
                    for tt1=1:TS+1+numLayerDelays,
                        for tt2=1:TS+1+numLayerDelays,
                            for ss=1:SS,
                                gTa{jz,qq,tt1,tt2,ss}=zzeros;
                            end
                        end
                    end
                end

                if outputConnect(jz)
                    for ts=1:TS
                        for qq=1:Q
                            for ss=1:SS
                                gTa{jz,qq,ts,ts,ss}=gE{jz,ts}(:,(qq-1)*SS+ss);
                            end
                        end
                    end
                end
            end
        else
            for jz=fliplr(Uprime)

                [gTa{jz,1:Q,1:TS+1+numLayerDelays}]=deal(zeros(layers{jz}.size,1));

                if outputConnect(jz)
                    for ts=1:TS
                        for qq=1:Q
                            gTa{jz,qq,ts}=gE{jz,ts}(:,qq);
                        end
                    end
                end
            end
        end
    end

    for ts=TS:-1:1
        if time_base
            for ss=1:SS
                for ts2=ts:-1:1
                    for jj=Uprime
                        for qq=1:Q
                            for xx=LCTWD{jj}
                                fcn=hints.layerWeights(xx,jj).weight;
                                for u2=Uprime
                                    if size([gTa{ES{u2},qq,ts,ts,ss}],2)~=0&&size(S{ES{u2},xx},2)~=0
                                        if fcn.is_dotprod
                                            gLWc=LW{xx,jj};
                                        else
                                            gLWc=fcn.dz_dp(LW{xx,jj},[Ad{xx,jj,:}],[LWZ{xx,jj,:}],fcn.param);
                                        end
                                        for k1=1:size(layerWeights{xx,jj}.delays,2)
                                            k2=layerWeights{xx,jj}.delays(k1);
                                            if iscell(gLWc)
                                                if(ts2+k2)<=TS
                                                    gTa{jj,qq,ts,ts2,ss}=gTa{jj,qq,ts,ts2,ss}...
                                                    +gLWc{(ts2-1)*Q+qq+k2*Q}(:,1+(k1-1)*layers{jj}.size:k1*layers{jj}.size)'...
                                                    *(gLWZ{xx,jj,ES{u2}}(:,:,qq,ts2+k2)...
                                                    .*S{ES{u2},xx}(:,:,qq,ts2+k2)')*[gTa{ES{u2},qq,ts,ts2+k2,ss}];
                                                end
                                            else
                                                gTa{jj,qq,ts,ts2,ss}=gTa{jj,qq,ts,ts2,ss}...
                                                +gLWc(:,1+(k1-1)*layers{jj}.size:k1*layers{jj}.size)'...
                                                *(gLWZ{xx,jj,ES{u2}}(:,:,qq,ts2+k2)...
                                                .*S{ES{u2},xx}(:,:,qq,ts2+k2)')*[gTa{ES{u2},qq,ts,ts2+k2,ss}];
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        else
            for jj=Uprime
                for qq=1:Q
                    for xx=LCTWD{jj}
                        fcn=hints.layerWeights(xx,jj).weight;
                        for u2=Uprime
                            if~isempty(gTa)&&(size([gTa{ES{u2},qq,ts}],2)~=0)&&(size(S{ES{u2},xx},2)~=0)
                                if fcn.is_dotprod
                                    gLWc=LW{xx,jj};
                                else
                                    gLWc=fcn.dz_dp(LW{xx,jj},[Ad{xx,jj,:}],[LWZ{xx,jj,:}],fcn.param);
                                end
                                for k1=1:size(layerWeights{xx,jj}.delays,2)
                                    k2=layerWeights{xx,jj}.delays(k1);
                                    if iscell(gLWc)
                                        if(ts+k2)<=TS
                                            gTa{jj,qq,ts}=gTa{jj,qq,ts}...
                                            +gLWc{(ts-1)*Q+qq+k2*Q}(:,1+(k1-1)*layers{jj}.size:k1*layers{jj}.size)'...
                                            *(gLWZ{xx,jj,ES{u2}}(:,:,qq,ts+k2)...
                                            .*S{ES{u2},xx}(:,:,qq,ts+k2)')*[gTa{ES{u2},qq,ts+k2}];
                                        end
                                    else
                                        gTa{jj,qq,ts}=gTa{jj,qq,ts}...
                                        +gLWc(:,1+(k1-1)*layers{jj}.size:k1*layers{jj}.size)'...
                                        *(gLWZ{xx,jj,ES{u2}}(:,:,qq,ts+k2)...
                                        .*S{ES{u2},xx}(:,:,qq,ts+k2)')*[gTa{ES{u2},qq,ts+k2}];
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        for i=bpLayerOrder
            for u2=Uprime
                if gTa_safe&&(size([gTa{ES{u2},qq,ts}],2)~=0)&&(size(S{ES{u2},i},2)~=0)

                    if biasConnect(i)
                        for qq=1:Q
                            if time_base
                                for ss=1:SS
                                    for ts2=ts:-1:1
                                        gB{i,(ts-1)*QS+(qq-1)*SS+ss}=gB{i,(ts-1)*QS+(qq-1)*SS+ss}+...
                                        (gBZ{i,ES{u2}}(:,:,qq,ts2).*S{ES{u2},i}(:,:,qq,ts2)')*gTa{ES{u2},qq,ts,ts2,ss};
                                    end
                                end
                            else
                                gB{i}=gB{i}+(gBZ{i,ES{u2}}(:,:,qq,ts).*S{ES{u2},i}(:,:,qq,ts)')*gTa{ES{u2},qq,ts};
                            end
                        end
                    end

                    for j=ICF{i}
                        fcn=hints.inputWeights(i,j).weight;
                        for qq=1:Q
                            if iscell(geIW{i,j,qq,ts})
                                if time_base
                                    for ss=1:SS
                                        for ts2=ts:-1:1
                                            temp=[];
                                            for k=1:layers{i}.size
                                                temp=[temp;(gIWZ{i,j,ES{u2}}(k,:,qq,ts2).*S{ES{u2},i}(:,k,qq,ts2)')*...
                                                gTa{ES{u2},qq,ts,ts2,ss}*geIW{i,j,qq,ts2}{k}'];
                                            end
                                            gIW{i,j,(ts-1)*QS+(qq-1)*SS+ss}=gIW{i,j,(ts-1)*QS+(qq-1)*SS+ss}+temp;
                                        end
                                    end
                                else
                                    temp=[];
                                    for k=1:layers{i}.size
                                        temp=[temp;(gIWZ{i,j,ES{u2}}(k,:,qq,ts).*S{ES{u2},i}(:,k,qq,ts)')*...
                                        gTa{ES{u2},qq,ts}*geIW{i,j,qq,ts}{k}'];
                                    end
                                    gIW{i,j}=gIW{i,j}+temp;
                                end
                            elseif fcn.w_deriv==2
                                if time_base
                                    for ss=1:SS
                                        for ts2=ts:-1:1
                                            gIW{i,j,(ts-1)*QS+(qq-1)*SS+ss}=gIW{i,j,(ts-1)*QS+(qq-1)*SS+ss}+...
                                            geIW{i,j,qq,ts2}*(gIWZ{i,j,ES{u2}}(:,:,qq,ts2).*S{ES{u2},i}(:,:,qq,ts2)')*gTa{ES{u2},qq,ts,ts2,ss};
                                        end
                                    end
                                else
                                    gIW{i,j}=gIW{i,j}+geIW{i,j,qq,ts}*...
                                    (gIWZ{i,j,ES{u2}}(:,:,qq,ts).*S{ES{u2},i}(:,:,qq,ts)')*gTa{ES{u2},qq,ts};
                                end
                            else
                                if time_base
                                    for ss=1:SS
                                        for ts2=ts:-1:1
                                            gIW{i,j,(ts-1)*QS+(qq-1)*SS+ss}=gIW{i,j,(ts-1)*QS+(qq-1)*SS+ss}+...
                                            (gIWZ{i,j,ES{u2}}(:,:,qq,ts2).*S{ES{u2},i}(:,:,qq,ts2)')*gTa{ES{u2},qq,ts,ts2,ss}*geIW{i,j,qq,ts2};
                                        end
                                    end
                                else
                                    gIW{i,j}=gIW{i,j}+(gIWZ{i,j,ES{u2}}(:,:,qq,ts).*S{ES{u2},i}(:,:,qq,ts)')*...
                                    gTa{ES{u2},qq,ts}*geIW{i,j,qq,ts};
                                end
                            end
                        end
                    end

                    for j=LCF{i}
                        fcn=hints.layerWeights(i,j).weight;
                        for qq=1:Q
                            if iscell(geLW{i,j,qq,ts})
                                if time_base
                                    for ss=1:SS
                                        for ts2=ts:-1:1
                                            temp=[];
                                            for k=1:layers{i}.size
                                                temp=[temp;(gLWZ{i,j,ES{u2}}(k,:,qq,ts2).*S{ES{u2},i}(:,k,qq,ts2)')*...
                                                gTa{ES{u2},qq,ts,ts2,ss}*geLW{i,j,qq,ts2}{k}'];
                                            end
                                            gLW{i,j,(ts-1)*QS+(qq-1)*SS+ss}=gLW{i,j,(ts-1)*QS+(qq-1)*SS+ss}+temp;
                                        end
                                    end
                                else
                                    temp=[];
                                    for k=1:net.layers{i}.size
                                        temp=[temp;(gLWZ{i,j,ES{u2}}(k,:,qq,ts).*S{ES{u2},i}(:,k,qq,ts)')*...
                                        gTa{ES{u2},qq,ts}*geLW{i,j,qq,ts}{k}'];
                                    end
                                    gLW{i,j}=gLW{i,j}+temp;
                                end
                            elseif fcn.w_deriv==2
                                if time_base
                                    for ss=1:SS
                                        for ts2=ts:-1:1
                                            gLW{i,j,(ts-1)*QS+(qq-1)*SS+ss}=gLW{i,j,(ts-1)*QS+(qq-1)*SS+ss}+...
                                            geLW{i,j,qq,ts2}*(gLWZ{i,j,ES{u2}}(:,:,qq,ts2).*S{ES{u2},i}(:,:,qq,ts2)')*gTa{ES{u2},qq,ts,ts2,ss};
                                        end
                                    end
                                else
                                    gLW{i,j}=gLW{i,j}+geLW{i,j,qq,ts}*(gLWZ{i,j,ES{u2}}(:,:,qq,ts).*S{ES{u2},i}(:,:,qq,ts)')*gTa{ES{u2},qq,ts};
                                end
                            else
                                if time_base
                                    for ss=1:SS
                                        for ts2=ts:-1:1
                                            gLW{i,j,(ts-1)*QS+(qq-1)*SS+ss}=gLW{i,j,(ts-1)*QS+(qq-1)*SS+ss}+...
                                            (gLWZ{i,j,ES{u2}}(:,:,qq,ts2).*S{ES{u2},i}(:,:,qq,ts2)')*gTa{ES{u2},qq,ts,ts2,ss}*geLW{i,j,qq,ts2};
                                        end
                                    end
                                else
                                    gLW{i,j}=gLW{i,j}+(gLWZ{i,j,ES{u2}}(:,:,qq,ts).*S{ES{u2},i}(:,:,qq,ts)')*gTa{ES{u2},qq,ts}*geLW{i,j,qq,ts};
                                end
                            end
                        end
                    end
                end
            end
        end
    end



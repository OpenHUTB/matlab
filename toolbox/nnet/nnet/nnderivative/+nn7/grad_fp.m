function[gB,gIW,gLW]=grad_fp(net,P,PD,BZ,IWZ,LWZ,N,Ac,gE,Q,TS,hints,time_base)

    if nargin<13,time_base=0;end

    numLayers=net.numLayers;
    numInputs=net.numInputs;
    numLayerDelays=net.numLayerDelays;
    layerWeights=net.layerWeights;
    bpLayerOrder=hints.bpLayerOrder;
    outputConnect=net.outputConnect;
    biasConnect=net.biasConnect;
    biases=net.biases;
    inputWeights=net.inputWeights;
    layers=net.layers;
    simLayerOrder=hints.simLayerOrder;
    inputConnect=net.inputConnect;
    ICF=hints.inputConnectFrom;
    LCF=hints.layerConnectFrom;
    LCT=hints.layerConnectTo;
    LCTOZD=hints.layerConnectToOZD;
    layerDelays=hints.layerDelays;
    IW=net.IW;
    LW=net.LW;

    LWsize1=zeros(numLayers,numLayers);
    LWsize2=zeros(numLayers,numLayers);
    IWsize1=zeros(numLayers,numInputs);
    IWsize2=zeros(numLayers,numInputs);
    for i=1:numLayers
        for j=ICF{i}
            IWsize1(i,j)=inputWeights{i,j}.size(1);
            IWsize2(i,j)=inputWeights{i,j}.size(2);
        end
        for j=LCF{i}
            LWsize1(i,j)=layerWeights{i,j}.size(1);
            LWsize2(i,j)=layerWeights{i,j}.size(2);
        end
    end

    SS=hints.totalOutputSize;
    QS=Q*SS;
    forw_redun_order=[];

    LCTWD=cell(numLayers);
    LCFWD=cell(numLayers);
    for i=simLayerOrder
        LCTWD{i}=setxor(LCT{i},LCTOZD{i});
        LCFWD{i}=[];
        for j=LCF{i}
            if any(layerWeights{i,j}.delays~=0)
                LCFWD{i}=[LCFWD{i},j];
            end
        end
        if outputConnect(i)||size(LCTWD{i},1)~=0
            forw_redun_order=[forw_redun_order,i];
        end
    end
    gLWZ=cell(numLayers,numLayers,numLayers);
    gyB=cell(numLayers,numLayers,numLayerDelays+1,Q);
    gyIW=cell(numLayers,net.numInputs,numLayers,numLayerDelays+1,Q);
    gyLW=cell(numLayers,numLayers,numLayers,numLayerDelays+1,Q);

    if time_base
        gB=cell(numLayers,TS*QS);
        gIW=cell(numLayers,net.numInputs,TS*QS);
        gLW=cell(numLayers,numLayers,TS*QS);
    else
        gB=cell(numLayers,1);
        gIW=cell(numLayers,net.numInputs);
        gLW=cell(numLayers,numLayers);
    end
    input_delays=cell(numLayers,numLayers);

    S=cell(numLayers,numLayers);

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

    ES=cell(1,numLayers);

    ESx=cell(1,numLayers);

    for i=bpLayerOrder

        if biasConnect(i)
            if time_base
                [gB{i,1:TS*QS}]=deal(zeros(biases{i}.size,1));
            else
                gB{i}=zeros(biases{i}.size,1);
            end
            if numLayerDelays
                for jz2=forw_redun_order
                    [gyB{i,jz2,1:numLayerDelays,1:Q}]=deal(zeros(biases{i}.size,layers{jz2}.size));
                end
            end
        end

        for j=ICF{i}
            if time_base
                [gIW{i,j,1:TS*QS}]=deal(zeros(inputWeights{i,j}.size));
            else
                gIW{i,j}=zeros(inputWeights{i,j}.size);
            end
            if numLayerDelays
                for jz2=forw_redun_order
                    [gyIW{i,j,jz2,1:numLayerDelays,1:Q}]=deal(zeros(layers{jz2}.size,...
                    IWsize1(i,j)*IWsize2(i,j)));
                end
            end
        end

        for j=LCF{i}
            if time_base
                [gLW{i,j,1:TS*QS}]=deal(zeros(layerWeights{i,j}.size));
            else
                gLW{i,j}=zeros(layerWeights{i,j}.size);
            end
            if numLayerDelays
                for jz2=forw_redun_order
                    [gyLW{i,j,jz2,1:numLayerDelays,1:Q}]=deal(zeros(layers{jz2}.size,...
                    LWsize1(i,j)*LWsize2(i,j)));
                end
            end

            input_delays{i,j}=layerWeights{i,j}.delays;
        end
    end

    for ts=1:TS

        for i=bpLayerOrder

            if biasConnect(i)
                for jz2=forw_redun_order
                    [gyB{i,jz2,numLayerDelays+1,1:Q}]=deal(zeros(biases{i}.size,layers{jz2}.size));
                end
            end

            for j=ICF{i}
                for jz2=forw_redun_order
                    [gyIW{i,j,jz2,numLayerDelays+1,1:Q}]=deal(zeros(layers{jz2}.size,...
                    IWsize1(i,j)*IWsize2(i,j)));
                end
            end

            for j=LCF{i}
                for jz2=forw_redun_order
                    for qq=1:Q
                        gyLW{i,j,jz2,numLayerDelays+1,qq}=zeros(layers{jz2}.size,...
                        LWsize1(i,j)*LWsize2(i,j));
                    end
                end
            end
        end

        Uprime=[];

        for i=bpLayerOrder

            for u=Uprime
                transferFcn=hints.layers(i).transfer;
                S_temp=nnprop.da_dn(i,transferFcn,ts,Q,Ae,numLayerDelays,N,0,layers{i}.size);


                for k=LCTOZD{i}
                    if size(S{u,k},1)>0&&size(S{u,k},4)>=ts&&size(gLWZ{k,i,u},4)>=ts

                        if size(S{u,i},1)==0
                            S{u,i}=zeros(layers{u}.size,layers{i}.size,Q,TS);
                        end

                        fcn=hints.layerWeights(k,i).weight;
                        if fcn.is_dotprod
                            for qq=1:Q
                                S{u,i}(:,:,qq,ts)=S{u,i}(:,:,qq,ts)+...
                                ((gLWZ{k,i,u}(:,:,qq,ts)'.*S{u,k}(:,:,qq,ts))*LW{k,i}*S_temp(:,:,qq,ts));
                            end
                        else
                            for qq=1:Q
                                temp=fcn.dz_dp(LW{k,i},Ae{i}(:,(ts-1)*Q+qq),LWZ{k,i,ts}(:,qq),fcn.param);

                                if iscell(temp)
                                    S{u,i}(:,:,qq,ts)=S{u,i}(:,:,qq,ts)+((gLWZ{k,i,u}(:,:,qq,ts)'.*S{u,k}(:,:,qq,ts))*temp{1}*S_temp(:,:,qq,ts));
                                else
                                    S{u,i}(:,:,qq,ts)=S{u,i}(:,:,qq,ts)+((gLWZ{k,i,u}(:,:,qq,ts)'.*S{u,k}(:,:,qq,ts))*temp*S_temp(:,:,qq,ts));
                                end
                            end
                        end

                        ES{i}=nnunion(ES{i},i);

                        if any(inputConnect(i,:))||any(LCFWD{i})
                            ESx{u}=nnunion(ESx{u},i);
                        end
                    end
                end
            end

            if outputConnect(i)||size(LCTWD{i},1)~=0
                transferFcn=hints.layers(i).transfer;
                S{i,i}=nnprop.da_dn(i,transferFcn,ts,Q,Ae,numLayerDelays,N,0,layers{i}.size);

                Uprime=nnunion(Uprime,i);

                ES{i}=nnunion(ES{i},i);

                if any(inputConnect(i,:))||any(LCFWD{i})
                    ESx{i}=nnunion(ESx{i},i);
                end
            end
            netFcn=hints.layers(i).netInput;
            if netFcn.is_netsum
                dz=ones(size(N{i,ts}));
            else
                Z=[BZ(i,biasConnect(i)),IWZ(i,ICF{i},ts),LWZ(i,LCF{i},ts)];
            end
            jjj=0;

            if biasConnect(i)
                jjj=jjj+1;
                if~netFcn.is_netsum
                    dz=netFcn.dn_dzj(jjj,Z,N{i,ts},netFcn.param);
                end
                for k=Uprime
                    if size(S{k,i},1)>0

                        for qq=1:Q

                            gyB{i,k,numLayerDelays+1,qq}=(S{k,i}(:,:,qq,ts)*diag(dz(:,qq)))';
                        end
                    end
                end
            end

            for j=ICF{i}
                jjj=jjj+1;

                if~netFcn.is_netsum
                    dz=netFcn.dn_dzj(jjj,Z,N{i,ts},netFcn.param);
                end
                weightFcn=hints.inputWeights(i,j).weight;
                for k=Uprime
                    if size(S{k,i},1)>0

                        for qq=1:Q

                            gIWZ=S{k,i}(:,:,qq,ts)*diag(dz(:,qq));

                            pd=nntraining.pd(net,Q,P,PD,i,j,ts,qq);
                            if weightFcn.is_dotprod
                                temp=pd';
                            else
                                temp=weightFcn.dz_dw(IW{i,j},pd,IWZ{i,j,ts}(:,qq),weightFcn.param)';
                            end

                            if iscell(temp)
                                numTemp2=size(gIWZ,2);
                                temp2=cell(1,numTemp2);

                                for jj=1:numTemp2
                                    numTemp3=size(gIWZ,1);
                                    temp3=cell(1,numTemp3);
                                    for ii=1:numTemp3
                                        temp3{ii}=[temp{jj}]'*gIWZ(ii,jj);
                                    end
                                    temp3=cat(1,temp3{:});
                                    temp2{jj}=temp3;
                                end
                                temp2=cat(2,temp2{:});

                            elseif weightFcn.w_deriv==2
                                temp2=gIWZ*temp';
                            else
                                temp2=kron(gIWZ,temp);
                            end

                            if~isempty(temp2)
                                gyIW{i,j,k,numLayerDelays+1,qq}=temp2;
                            end
                        end
                    end
                end
            end

            for j=LCF{i}
                jjj=jjj+1;
                if~netFcn.is_netsum
                    dz=netFcn.dn_dzj(jjj,Z,N{i,ts},netFcn.param);
                end
                weightFcn=hints.layerWeights(i,j).weight;
                for k=Uprime
                    if size(S{k,i},1)>0

                        for qq=1:Q

                            gLWZ{i,j,k}(:,:,qq,ts)=kron(dz(:,qq),ones(1,layers{k}.size));

                            if weightFcn.is_dotprod
                                temp=Ad{i,j,ts}(:,qq)';
                            else
                                temp=weightFcn.dz_dw(LW{i,j},Ad{i,j,ts}(:,qq),LWZ{i,j,ts}(:,qq),weightFcn.param)';
                            end

                            if iscell(temp)
                                numTemp2=size(gLWZ{i,j,k}(:,:,qq,ts),1);
                                temp2=cell(1,numTemp2);
                                for jj=1:numTemp2
                                    numTemp3=size(gLWZ{i,j,k}(:,:,qq,ts),2);
                                    temp3=cell(1,numTemp3);
                                    for ii=1:numTemp3
                                        temp4=gLWZ{i,j,k}(jj,ii,qq,ts)*S{k,i}(ii,jj,qq,ts);
                                        temp3{ii}=[temp{jj}]'*temp4;
                                    end
                                    temp3=cat(1,temp3{:});
                                    temp2{jj}=temp3;
                                end
                                temp2=cat(2,temp2{:});

                            elseif weightFcn.w_deriv==2
                                temp3=gLWZ{i,j,k}(:,:,qq,ts)'.*S{k,i}(:,:,qq,ts);
                                temp2=temp3*temp';
                            else
                                temp3=gLWZ{i,j,k}(:,:,qq,ts)'.*S{k,i}(:,:,qq,ts);
                                temp2=kron(temp3,temp);
                            end

                            gyLW{i,j,k,numLayerDelays+1,qq}=temp2;
                        end
                    end
                end
            end
        end

        for jz=simLayerOrder

            for jj=ESx{jz}

                for xx=LCFWD{jj}

                    if size(S{jz,jj},2)~=0

                        weightFcn=hints.layerWeights(jj,xx).weight;
                        if weightFcn.is_dotprod
                            gLWc=LW{jj,xx};
                        else
                            gLWc=weightFcn.dz_dp(LW{jj,xx},[Ad{jj,xx,ts}],LWZ{jj,xx,ts},weightFcn.param);
                        end

                        for i=simLayerOrder

                            if biasConnect(i)
                                for qq=1:Q

                                    numTemp=size(input_delays{jj,xx},2);
                                    temp=cell(1,numTemp);
                                    for nx=1:numTemp
                                        nd=input_delays{jj,xx}(nx);
                                        temp{nx}=gyB{i,xx,numLayerDelays+1-nd,qq};
                                    end
                                    temp=cat(2,temp{:});
                                    if~isempty(temp)

                                        if iscell(gLWc)
                                            gyB{i,jz,numLayerDelays+1,qq}=gyB{i,jz,numLayerDelays+1,qq}+...
                                            ((S{jz,jj}(:,:,qq,ts).*gLWZ{jj,xx,jz}(:,:,qq,ts)')*gLWc{qq}*temp')';
                                        else
                                            gyB{i,jz,numLayerDelays+1,qq}=gyB{i,jz,numLayerDelays+1,qq}+...
                                            ((S{jz,jj}(:,:,qq,ts).*gLWZ{jj,xx,jz}(:,:,qq,ts)')*gLWc*temp')';
                                        end
                                    end
                                end
                            end

                            for j=ICF{i}
                                for qq=1:Q

                                    numTemp=size(input_delays{jj,xx},2);
                                    temp=cell(1,numTemp);
                                    for nx=1:numTemp
                                        nd=input_delays{jj,xx}(nx);
                                        temp{nx}=gyIW{i,j,xx,numLayerDelays+1-nd,qq};
                                    end
                                    temp=cat(1,temp{:});

                                    if~isempty(temp)
                                        if iscell(gLWc)
                                            gyIW{i,j,jz,numLayerDelays+1,qq}=gyIW{i,j,jz,numLayerDelays+1,qq}+...
                                            (S{jz,jj}(:,:,qq,ts).*gLWZ{jj,xx,jz}(:,:,qq,ts)')*gLWc{qq}*temp;
                                        else
                                            gyIW{i,j,jz,numLayerDelays+1,qq}=gyIW{i,j,jz,numLayerDelays+1,qq}+...
                                            (S{jz,jj}(:,:,qq,ts).*gLWZ{jj,xx,jz}(:,:,qq,ts)')*gLWc*temp;
                                        end
                                    end
                                end
                            end

                            for j=LCF{i}
                                for qq=1:Q

                                    numTemp=size(input_delays{jj,xx},2);
                                    temp=cell(1,numTemp);
                                    for nx=1:numTemp
                                        nd=input_delays{jj,xx}(nx);
                                        temp{nx}=gyLW{i,j,xx,numLayerDelays+1-nd,qq};
                                    end
                                    temp=cat(1,temp{:});
                                    if~isempty(temp)
                                        if iscell(gLWc)
                                            gyLW{i,j,jz,numLayerDelays+1,qq}=gyLW{i,j,jz,numLayerDelays+1,qq}+...
                                            (S{jz,jj}(:,:,qq,ts).*gLWZ{jj,xx,jz}(:,:,qq,ts)')*gLWc{qq}*temp;
                                        else
                                            gyLW{i,j,jz,numLayerDelays+1,qq}=gyLW{i,j,jz,numLayerDelays+1,qq}+...
                                            (S{jz,jj}(:,:,qq,ts).*gLWZ{jj,xx,jz}(:,:,qq,ts)')*gLWc*temp;
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end

        for jz=find(outputConnect)

            gEE=gE{jz,ts};

            for i=bpLayerOrder

                for qq=1:Q

                    if biasConnect(i)

                        if time_base
                            for ss=1:SS
                                gB{i,(ts-1)*QS+(qq-1)*SS+ss}=gB{i,(ts-1)*QS+(qq-1)*SS+ss}+gyB{i,jz,numLayerDelays+1,qq}*gEE(:,(qq-1)*SS+ss);
                            end
                        else
                            gB{i}=gB{i}+gyB{i,jz,numLayerDelays+1,qq}*gEE(:,qq);
                        end
                    end

                    for j=ICF{i}

                        if time_base
                            for ss=1:SS
                                temp=gEE(:,(qq-1)*SS+ss)'*gyIW{i,j,jz,numLayerDelays+1,qq};
                                numTemp2=IWsize1(i,j);
                                temp2=cell(1,numTemp2);
                                for zzz=1:numTemp2
                                    temp2{zzz}=temp((1:IWsize2(i,j))+(zzz-1)*IWsize2(i,j));
                                end
                                temp2=cat(1,temp2{:});
                                if~isempty(temp2)
                                    gIW{i,j,(ts-1)*QS+(qq-1)*SS+ss}=gIW{i,j,(ts-1)*QS+(qq-1)*SS+ss}+temp2;
                                end
                            end
                        else
                            temp=gEE(:,qq)'*gyIW{i,j,jz,numLayerDelays+1,qq};
                            numTemp2=IWsize1(i,j);
                            temp2=cell(1,numTemp2);
                            for zzz=1:numTemp2
                                temp2{zzz}=temp((1:IWsize2(i,j))+(zzz-1)*IWsize2(i,j));
                            end
                            temp2=cat(1,temp2{:});
                            if~isempty(temp2)
                                gIW{i,j}=gIW{i,j}+temp2;
                            end
                        end
                    end

                    for j=LCF{i}

                        if size(gyLW{i,j,jz,numLayerDelays+1,qq})

                            if time_base
                                for ss=1:SS
                                    temp=gEE(:,(qq-1)*SS+ss)'*gyLW{i,j,jz,numLayerDelays+1,qq};
                                    numTemp2=LWsize1(i,j);
                                    temp2=cell(1,numTemp2);
                                    for zzz=1:numTemp2
                                        temp2{zzz}=temp((1:LWsize2(i,j))+(zzz-1)*LWsize2(i,j));
                                    end
                                    temp2=cat(1,temp2{:});
                                    if~isempty(temp2)
                                        gLW{i,j,(ts-1)*QS+(qq-1)*SS+ss}=gLW{i,j,(ts-1)*QS+(qq-1)*SS+ss}+temp2;
                                    end
                                end
                            else
                                temp=gEE(:,qq)'*gyLW{i,j,jz,numLayerDelays+1,qq};
                                numTemp2=LWsize1(i,j);
                                temp2=cell(1,numTemp2);
                                for zzz=1:numTemp2
                                    temp2{zzz}=temp((1:LWsize2(i,j))+(zzz-1)*LWsize2(i,j));
                                end
                                temp2=cat(1,temp2{:});
                                if~isempty(temp2)
                                    gLW{i,j}=gLW{i,j}+temp2;
                                end
                            end
                        end
                    end
                end
            end
        end

        for i=bpLayerOrder
            if numLayerDelays
                if biasConnect(i)
                    [gyB{i,forw_redun_order,1:numLayerDelays,1:Q}]=deal(gyB{i,forw_redun_order,(1:numLayerDelays)+1,1:Q});
                end
                for j=ICF{i}
                    [gyIW{i,j,forw_redun_order,1:numLayerDelays,1:Q}]=deal(gyIW{i,j,forw_redun_order,(1:numLayerDelays)+1,1:Q});
                end
                for j=LCF{i}
                    [gyLW{i,j,forw_redun_order,1:numLayerDelays,1:Q}]=deal(gyLW{i,j,forw_redun_order,(1:numLayerDelays)+1,1:Q});
                end
            end
        end
    end


    function u=nnunion(u,i)
        if~any(u==i),u=[u,i];end

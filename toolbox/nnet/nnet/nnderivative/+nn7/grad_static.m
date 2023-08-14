function[gB,gIW,gLW,gA]=grad_static(net,P,PD,BZ,IWZ,LWZ,N,Ac,gE,Q,TS,hints)














    numLayers=net.numLayers;
    numInputs=net.numInputs;
    numLayerDelays=net.numLayerDelays;
    layerWeights=net.layerWeights;
    inputWeights=net.inputWeights;
    ICF=hints.inputConnectFrom;
    LCF=hints.layerConnectFrom;
    IW=net.IW;
    LW=net.LW;
    layerDelays=hints.layerDelays;
    TSall=1:TS;
    Qall=1:Q;
    BC=net.biasConnect;


    Ae=cell(numLayers,1);
    for i=1:numLayers
        Ae{i}=[Ac{i,(1+numLayerDelays):end}];
    end
    IWZe=cell(numLayers,numInputs);
    LWZe=cell(numLayers,numLayers);
    BZe=cell(numLayers,1);
    QTS=Q*TS;
    QTSones=ones(1,QTS);
    for i=1:numLayers
        for j=LCF{i}
            LWZe{i,j}=[LWZ{i,j,:}];
        end
        for j=ICF{i}
            IWZe{i,j}=[IWZ{i,j,:}];
        end
        if BC(i)
            BZe{i}=net.b{i}(:,QTSones);
        end
    end


    gA=cell(numLayers,1);
    gN=cell(numLayers,1);
    gLWZ=cell(numLayers,numLayers);
    gB=cell(numLayers,1);
    gIW=cell(numLayers,numInputs);
    gLW=cell(numLayers,numLayers);


    for i=hints.bpLayerOrder


        if net.outputConnect(i)
            gA{i}=[gE{i,:}];
        else
            gA{i}=zeros(net.layers{i}.size,QTS);
        end


        Ne=[N{i,:}];
        for k=find(net.layerConnect(:,i)')
            delays=net.layerWeights{k,i}.delays;
            if(length(delays)>=1)&&(delays(1)==0)
                if length(delays)==1
                    ZeroDelayW=LW{k,i};
                else
                    ZeroDelayW=LW{k,i}(:,1:net.layers{i}.size);
                end
                weightFcn=hints.layerWeights(k,i).weight;
                if weightFcn.is_dotprod
                    LWderivP=ZeroDelayW;
                else
                    LWderivP=weightFcn.dz_dp(ZeroDelayW,Ae{i},LWZe{k,i},weightFcn.param);
                end
                if iscell(LWderivP)
                    for qq=1:QTS
                        gA{i}(:,qq)=gA{i}(:,qq)+LWderivP{qq}'*gLWZ{k,i}(:,qq);
                    end
                else
                    gA{i}=gA{i}+LWderivP'*gLWZ{k,i};
                end
            end
        end


        transferFcn=hints.layers(i).transfer;
        Fdot=transferFcn.da_dn(Ne,Ae{i},transferFcn.param);
        if transferFcn.isScalar
            gN{i}=Fdot.*gA{i};
        else
            gNi=zeros(net.layers{i}.size,QTS);
            for qq=1:QTS
                gNi(:,qq)=Fdot{qq}'*gA{i}(:,qq);
            end
            gN{i}=gNi;
        end


        netFcn=hints.layers(i).netInput;
        if netFcn.is_netsum
            NderivZ=ones(size(Ne));
        else

            Z=[BZe(i,BC(i)),IWZe(i,ICF{i}),LWZe(i,LCF{i})];
        end
        jjj=0;


        if net.biasConnect(i)
            jjj=jjj+1;
            if~netFcn.is_netsum
                NderivZ=netFcn.dn_dzj(jjj,Z,Ne,netFcn.param);
            end
            gB{i}=sum(NderivZ.*gN{i},2);
        end


        for j=ICF{i}
            jjj=jjj+1;


            if~netFcn.is_netsum
                NderivZ=netFcn.dn_dzj(jjj,Z,Ne,netFcn.param);
            end
            temp1=NderivZ.*gN{i};


            pd=nntraining.pd(net,Q,P,PD,i,j,TSall);
            weightFcn=hints.inputWeights(i,j).weight;
            if weightFcn.is_dotprod
                IWderivW=pd;
            else
                IWderivW=weightFcn.dz_dw(IW{i,j},pd,IWZe{i,j},weightFcn.param);
            end
            if iscell(IWderivW)
                gIW{i,j}=zeros(inputWeights{i,j}.size);
                for ss=1:size(gN{i},1)
                    gIW{i,j}(ss,:)=temp1(ss,:)*IWderivW{ss}';
                end
            elseif weightFcn.w_deriv==2,
                gIW{i,j}=zeros(inputWeights{i,j}.size);
                for qq=1:QTS,
                    gIW{i,j}=gIW{i,j}+IWderivW(:,:,qq)'*temp1(:,qq);
                end
            else
                gIW{i,j}=temp1*IWderivW';
            end
        end


        for j=LCF{i}
            jjj=jjj+1;


            if~netFcn.is_netsum
                NderivZ=netFcn.dn_dzj(jjj,Z,Ne,netFcn.param);
            end
            gLWZ{i,j}=NderivZ.*gN{i};


            numDelays=length(layerDelays{i,j});
            if numDelays==0
                Ad=zeros(0,QTS);
            elseif numDelays==1
                Ad=[Ac{j,TSall+numLayerDelays-layerDelays{i,j}}];
            else
                Ad=zeros(numDelays*net.layers{j}.size,QTS);
                for ts=1:TS
                    Ad(:,Qall+((ts-1)*Q))=cell2mat(Ac(j,ts+numLayerDelays-layerDelays{i,j})');
                end
            end
            weightFcn=hints.layerWeights(i,j).weight;
            if weightFcn.is_dotprod
                LWderivW=Ad;
            else
                LWderivW=weightFcn.dz_dw(LW{i,j},Ad,LWZe{i,j},weightFcn.param);
            end

            if iscell(LWderivW)
                gLW{i,j}=zeros(layerWeights{i,j}.size);
                for ss=1:size(gLWZ{i,j},1)
                    gLW{i,j}(ss,:)=gLWZ{i,j}(ss,:)*LWderivW{ss}';
                end
            elseif weightFcn.w_deriv==2
                gLW{i,j}=zeros(layerWeights{i,j}.size);
                for qq=1:QTS,
                    gLW{i,j}=gLW{i,j}+LWderivW(:,:,qq)'*gLWZ{i,j}(:,qq);
                end
            else
                gLW{i,j}=gLWZ{i,j}*LWderivW';
            end
        end
    end


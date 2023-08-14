function[JE,JJ,Perfs,PerfN]=bj(net,X,Xi,Pc,Pd,Ai,T,EW,masks,Q,TS,hints)




    if nargin>1
        if isstring(X)
            X=cellstr(X);
        end
    end

    if nargin>2
        if isstring(Xi)
            Xi=cellstr(Xi);
        end
    end

    if nargin>3
        if isstring(Pc)
            Pc=cellstr(Pc);
        end
    end

    if nargin>4
        if isstring(Pd)
            Pd=cellstr(Pd);
        end
    end

    if nargin>5
        if isstring(Ai)
            Ai=cellstr(Ai);
        end
    end

    numMasks=numel(masks);
    Perfs=zeros(1,numMasks);
    PerfN=zeros(1,numMasks);
    if(Q*TS==0)
        JE=zeros(net.numWeightElements,1);
        JJ=zeros(net.numWeightElements);
        return;
    end

    doDelayedInputs=isempty(Pd);
    doProcessInputs=isempty(Pc)&&isempty(Pd);
    EWts=size(EW,2)~=1;
    EWii=size(EW,1)~=1;
    dB=cell(net.numLayers,1);
    dIW=cell(net.numLayers,net.numInputs);
    dLW=cell(net.numLayers,net.numLayers);
    for i=1:net.numLayers
        if net.biasConnect(i)
            dB{i}=zeros(net.layers{i}.size,Q,hints.numOutputElements*TS);
        end
        for j=1:net.numInputs
            if net.inputConnect(i,j)
                wsize=net.inputWeights{i,j}.size;
                dIW{i,j}=zeros(wsize(1),wsize(2),Q,hints.numOutputElements*TS);
            end
        end
        for j=1:net.numLayers
            if net.layerConnect(i,j)
                wsize=net.layerWeights{i,j}.size;
                dLW{i,j}=zeros(wsize(1),wsize(2),Q,hints.numOutputElements*TS);
            end
        end
    end
    E=cell(net.numOutputs,TS);
    Yp=cell(1,hints.maxOutProc);
    Ac=[Ai,cell(net.numLayers,TS)];
    N=cell(net.numLayers,TS);
    Z=cell(net.numLayers,hints.maxZ,TS);
    dA=cell(net.numLayers,TS);
    for i=1:net.numLayers
        dA(i,:)={zeros(net.layers{i}.size,Q,hints.numOutputElements*TS)};
    end
    bz=cell(net.numLayers,1);
    bq=ones(1,Q);
    for i=1:net.numLayers
        if net.biasConnect(i)
            bz{i}=net.b{i}(:,bq);
        end
    end


    if doProcessInputs
        Pc=cell(net.numInputs,net.numInputDelays+TS);
        for ts=1:net.numInputDelays
            for i=1:net.numInputs
                pi=Xi{i,ts};
                for j=1:hints.numInpProc(i)
                    pi=hints.inp(i).procApply{j}(pi,hints.inp(i).procSet{j});
                end
                Pc{i,ts}=pi;
            end
        end
    end


    for ts=1:TS


        if doProcessInputs
            for i=1:net.numInputs
                pi=X{i,ts};
                for j=1:hints.numInpProc(i)
                    pi=hints.inp(i).procApply{j}(pi,hints.inp(i).procSet{j});
                end
                Pc{i,net.numInputDelays+ts}=pi;
            end
        end


        for i=hints.layerOrder


            if net.biasConnect(i)
                Z{i,1,ts}=bz{i};
            end
            for j=1:net.numInputs
                if net.inputConnect(i,j)
                    if doDelayedInputs
                        p_ts=(net.numInputDelays+ts)-net.inputWeights{i,j}.delays;
                        pd=cat(1,Pc{j,p_ts});
                    else
                        pd=Pd{i,j,ts};
                    end
                    Z{i,hints.iwzInd(i,j),ts}=hints.iwApply{i,j}(net.IW{i,j},pd,hints.iwParam{i,j});
                end
            end
            for j=1:net.numLayers
                if net.layerConnect(i,j)
                    a_ts=(net.numLayerDelays+ts)-net.layerWeights{i,j}.delays;
                    ad=cat(1,Ac{j,a_ts});
                    Z{i,hints.lwzInd(i,j),ts}=hints.lwApply{i,j}(net.LW{i,j},ad,hints.lwParam{i,j});
                end
            end


            N{i,ts}=hints.netApply{i}(Z(i,1:hints.numZ(i),ts),net.layers{i}.size,Q,hints.netParam{i});
            Ac{i,net.numLayerDelays+ts}=hints.tfApply{i}(N{i,ts},hints.tfParam{i});
        end
    end


    for ts=TS:-1:1
        for i=fliplr(hints.layerOrder)


            if net.outputConnect(i)
                yi=Ac{i,net.numLayerDelays+ts};
                ii=hints.layer2Output(i);
                Yp{hints.numOutProc(ii)+1}=yi;
                for j=hints.numOutProc(ii):-1:1
                    yi=hints.out(ii).procRev{j}(yi,hints.out(ii).procSet{j});
                    Yp{j}=yi;
                end


                e=T{ii,ts}-yi;
                if hints.doErrNorm(ii)
                    e=bsxfun(@times,e,hints.errNorm{ii});
                end


                perf=e.*e;




                if hints.doEW
                    ew=EW{(EWii*(ii-1))+1,EWts*(ts-1)+1};
                    perf=bsxfun(@times,perf,ew);
                    sqrtew=sqrt(ew);
                    e=bsxfun(@times,e,sqrtew);
                end


                for k=1:numMasks
                    perfk=perf.*masks{k}{ii,ts};
                    indk=find(isnan(perfk));
                    PerfN(k)=PerfN(k)+numel(perfk)-length(indk);
                    perfk(indk)=0;
                    Perfs(k)=Perfs(k)+sum(sum(perfk));

                    if(k==1)
                        e(indk)=0;
                        E{ii,ts}=e;
                        dy=-ones(net.outputs{i}.size,Q);
                        if hints.doEW
                            dy=bsxfun(@times,dy,sqrtew);
                        end
                        if hints.doErrNorm(ii)
                            dy=bsxfun(@times,dy,hints.errNorm{ii});
                        end
                        dy(indk)=0;
                        dy_expanded=zeros(net.outputs{i}.size,Q,net.outputs{i}.size);
                        for s=1:net.outputs{i}.size;
                            dy_expanded(s,:,s)=dy(s,:);
                        end
                        dy=dy_expanded;

                        for j=1:hints.numOutProc(ii)
                            dy=hints.out(ii).procBPrev{j}(dy,Yp{j},Yp{j+1},hints.out(ii).procSet{j});
                        end

                        extra_ind=(ts-1)*hints.numOutputElements+hints.outInd{ii};
                        dA{i,ts}(:,:,extra_ind)=dA{i,ts}(:,:,extra_ind)+dy;
                    end
                end
            end


            dn=hints.tfBP{i}(dA{i,ts},N{i,ts},Ac{i,net.numLayerDelays+ts},hints.tfParam{i});
            dA(i,ts)={[]};
            Zi=Z(i,1:hints.numZ(i),ts);


            for j=net.numLayers:-1:1
                if net.layerConnect(i,j)
                    ii=hints.lwzInd(i,j);
                    dz=hints.netBP{i}(dn,ii,Zi,N{i,ts},hints.netParam{i});

                    a_ts=(net.numLayerDelays+ts)-net.layerWeights{i,j}.delays;
                    ad=cat(1,Ac{j,a_ts});
                    if hints.lwInclude(i,j)
                        dLW{i,j}=dLW{i,j}+hints.lwBSP{i,j}(dz,net.LW{i,j},ad,Z{i,ii,ts},hints.lwParam{i,j});
                    end

                    dad=hints.lwBP{i,j}(dz,net.LW{i,j},ad,Z{i,ii,ts},hints.lwParam{i,j});
                    delays=ts-net.layerWeights{i,j}.delays;
                    numDelays=numel(delays);
                    wsize=size(dad,1)/numDelays;
                    for k=1:numDelays
                        ts_k=delays(k);
                        if(ts_k>0)
                            dA{j,ts_k}=dA{j,ts_k}+dad((wsize*(k-1))+(1:wsize),:,:);
                        end
                    end
                end
            end


            for j=net.numInputs:-1:1
                if net.inputConnect(i,j)
                    ii=hints.iwzInd(i,j);
                    dz=hints.netBP{i}(dn,ii,Zi,N{i,ts},hints.netParam{i});

                    if hints.iwInclude(i,j)
                        if doDelayedInputs
                            p_ts=(net.numInputDelays+ts)-net.inputWeights{i,j}.delays;
                            pd=cat(1,Pc{j,p_ts});
                        else
                            pd=Pd{i,j,ts};
                        end
                        dIW{i,j}=dIW{i,j}+hints.iwBSP{i,j}(dz,net.IW{i,j},pd,Z{i,ii,ts},hints.iwParam{i,j});
                    end
                end
            end


            if hints.bInclude(i)
                dB{i}=dB{i}+hints.netBP{i}(dn,1,Zi,N{i,ts},hints.netParam{i});
            end
        end
    end


    numCol=Q*hints.numOutputElements*TS;
    J=zeros(net.numWeightElements,numCol);
    for i=1:net.numLayers
        if hints.bInclude(i)
            dB{i}=reshape(dB{i},numel(net.b{i}),numCol);
            J(hints.bInd{i},:)=dB{i};
        end
        for j=find(hints.iwInclude(i,:))
            dIW{i,j}=reshape(dIW{i,j},numel(net.IW{i,j}),numCol);
            J(hints.iwInd{i,j},:)=dIW{i,j};
        end
        for j=find(hints.lwInclude(i,:))
            dLW{i,j}=reshape(dLW{i,j},numel(net.LW{i,j}),numCol);
            J(hints.lwInd{i,j},:)=dLW{i,j};
        end
    end

    E2=zeros(numCol,1);
    pos=0;
    for i=1:numel(E)
        e=E{i}';
        E2(pos+(1:numel(e)))=e(:);
        pos=pos+numel(e);
    end
    E=E2;
    J(isnan(J))=0;
    JE=J*E;
    JJ=J*J';

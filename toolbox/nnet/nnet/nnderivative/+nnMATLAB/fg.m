function[gWB,Perfs,PerfN]=fg(net,X,Xi,Pc,Pd,Ai,T,EW,masks,Q,TS,hints)

    gWB=zeros(net.numWeightElements,1);
    numMasks=numel(masks);
    Perfs=zeros(1,numMasks);
    PerfN=zeros(1,numMasks);
    if(Q*TS==0)
        return
    end

    doDelayedInputs=isempty(Pd);
    doProcessInputs=isempty(Pc)&&isempty(Pd);
    EWts=size(EW,2)~=1;
    EWii=size(EW,1)~=1;
    A=[Ai,cell(net.numLayers,1)];
    dA=cell(net.numLayers,net.numLayerDelays+1);
    for i=1:net.numLayers
        dA(i,1:net.numLayerDelays)={zeros(net.layers{i}.size,Q,net.numWeightElements)};
    end
    Z=cell(1,hints.maxZ);
    dZ=cell(1,hints.maxZ);
    bz=cell(net.numLayers,1);
    bq=ones(1,Q);
    dZB=cell(net.numLayers,1);
    for i=1:net.numLayers
        if net.biasConnect(i)
            bz{i}=net.b{i}(:,bq);
            dzb=zeros(net.layers{i}.size,Q,net.layers{i}.size);
            for j=1:net.layers{i}.size
                dzb(j,:,j)=1;
            end
            dZB{i}=dzb;
        end
    end

    if doProcessInputs
        Pc=cell(net.numInputs,net.numInputDelays+1);
        for ts=1:net.numInputDelays
            for i=1:net.numInputs
                pi=Xi{i,ts};
                for j=1:hints.numInpProc(i)
                    if hints.inp(i).procMapminmax(j)
                        settings=hints.inp(i).procSet{j};
                        pi=bsxfun(@minus,pi,settings.xoffset);
                        pi=bsxfun(@times,pi,settings.gain);
                        pi=bsxfun(@plus,pi,settings.ymin);
                    else
                        pi=hints.inp(i).procApply{j}(pi,hints.inp(i).procSet{j});
                    end
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
                    if hints.inp(i).procMapminmax(j)
                        settings=hints.inp(i).procSet{j};
                        pi=bsxfun(@minus,pi,settings.xoffset);
                        pi=bsxfun(@times,pi,settings.gain);
                        pi=bsxfun(@plus,pi,settings.ymin);
                    else
                        pi=hints.inp(i).procApply{j}(pi,hints.inp(i).procSet{j});
                    end
                end
                p_ts=rem(net.numInputDelays-1+ts,net.numInputDelays+1)+1;
                Pc{i,p_ts}=pi;
            end
        end

        for i=hints.layerOrder

            if net.biasConnect(i)
                if hints.netNetsum(i)
                    n=bz{i};
                else
                    Z{1}=bz{i};
                end

                if hints.bInclude(i)
                    dZ{1}=zeros(net.layers{i}.size,Q,net.numWeightElements);
                    dZ{1}(:,:,hints.bInd{i})=dZB{i};
                end
            elseif hints.netNetsum(i)
                n=zeros(hints.layerSizes(i),Q);
            end

            for j=1:net.numInputs
                if net.inputConnect(i,j)
                    ii=hints.iwzInd(i,j);
                    if doDelayedInputs
                        if doProcessInputs
                            p_ts=rem(((net.numInputDelays-1+ts)-net.inputWeights{i,j}.delays),net.numInputDelays+1)+1;
                        else
                            p_ts=(net.numInputDelays+ts)-net.inputWeights{i,j}.delays;
                        end
                        pd=cat(1,Pc{j,p_ts});
                    else
                        pd=Pd{i,j,ts};
                    end
                    if hints.iwDotprod(i,j)
                        zi=net.IW{i,j}*pd;
                    else
                        zi=hints.iwApply{i,j}(net.IW{i,j},pd,hints.iwParam{i,j});
                    end
                    if hints.netNetsum(i)
                        n=n+zi;
                    else
                        Z{ii}=zi;
                    end

                    if hints.iwInclude(i,j)
                        dzw=hints.iwFS{i,j}(net.IW{i,j},pd,zi,hints.iwParam{i,j});
                        dZ{ii}=zeros(net.layers{i}.size,Q,net.numWeightElements);
                        dZ{ii}(:,:,hints.iwInd{i,j})=dzw(:,:,:);
                    end
                end
            end

            for j=1:net.numLayers
                if net.layerConnect(i,j)
                    ii=hints.lwzInd(i,j);
                    a_ts=rem(((net.numLayerDelays-1+ts)-net.layerWeights{i,j}.delays),net.numLayerDelays+1)+1;
                    ad=cat(1,A{j,a_ts});
                    if hints.lwDotprod(i,j)
                        zi=net.LW{i,j}*ad;
                    else
                        zi=hints.lwApply{i,j}(net.LW{i,j},ad,hints.lwParam{i,j});
                    end
                    if hints.netNetsum(i)
                        n=n+zi;
                    else
                        Z{ii}=zi;
                    end
                    dAd=cat(1,dA{j,a_ts});
                    dzw1=hints.lwFP{i,j}(dAd,net.LW{i,j},ad,zi,hints.lwParam{i,j});
                    if hints.lwInclude(i,j)
                        dzw2=hints.lwFS{i,j}(net.LW{i,j},ad,zi,hints.lwParam{i,j});
                        dzw1(:,:,hints.lwInd{i,j})=dzw1(:,:,hints.lwInd{i,j})+dzw2(:,:,:);
                    end
                    dZ{ii}=dzw1;
                end
            end

            if hints.netNetsum(i)
                N=n;
            else
                Zi=Z(1:hints.numZ(i));
                N=hints.netApply{i}(Zi,net.layers{i}.size,Q,hints.netParam{i});
            end
            dN=zeros(net.layers{i}.size,Q,net.numWeightElements);
            for j=1:net.numLayers
                if net.layerConnect(i,j)
                    ii=hints.lwzInd(i,j);
                    if hints.netNetsum(i)
                        dN=dN+dZ{ii};
                    else
                        dN=dN+hints.netFP{i}(dZ{ii},ii,Zi,N,hints.netParam{i});
                    end
                end
            end
            for j=1:net.numInputs
                if hints.iwInclude(i,j)
                    ii=hints.iwzInd(i,j);
                    if hints.netNetsum(i)
                        dN=dN+dZ{ii};
                    else
                        dN=dN+hints.netFP{i}(dZ{ii},ii,Zi,N,hints.netParam{i});
                    end
                end
            end
            if hints.bInclude(i)
                if hints.netNetsum(i)
                    dN=dN+dZ{1};
                else
                    dN=dN+hints.netFP{i}(dZ{1},1,Zi,N,hints.netParam{i});
                end
            end
            a_ts=rem(net.numLayerDelays+ts-1,net.numLayerDelays+1)+1;
            if hints.tfPurelin(i)
                A{i,a_ts}=N;
            elseif hints.tfTansig(i)
                A{i,a_ts}=2./(1+exp(-2*N))-1;
            else
                A{i,a_ts}=hints.tfApply{i}(N,hints.tfParam{i});
            end

            if hints.tfPurelin(i)
                dA{i,a_ts}=dN;
            elseif hints.tfTansig(i)
                dA{i,a_ts}=bsxfun(@times,dN,1-(A{i,a_ts}.*A{i,a_ts}));
            else
                dA{i,a_ts}=hints.tfFP{i}(dN,N,A{i,a_ts},hints.tfParam{i});
            end

            if net.outputConnect(i)
                yi=A{i,a_ts};
                dY=dA{i,a_ts};
                ii=hints.layer2Output(i);
                for j=hints.numOutProc(ii):-1:1
                    xi=yi;
                    if hints.out(ii).procMapminmax(j)
                        settings=hints.out(ii).procSet{j};
                        yi=bsxfun(@minus,yi,settings.ymin);
                        yi=bsxfun(@rdivide,yi,settings.gain);
                        yi=bsxfun(@plus,yi,settings.xoffset);
                    else
                        yi=hints.out(ii).procRev{j}(xi,hints.out(ii).procSet{j});
                    end

                    if hints.out(ii).procMapminmax(j)
                        dY=bsxfun(@rdivide,dY,hints.out(ii).procSet{j}.gain);
                    else
                        dY=hints.out(ii).procFPrev{j}(dY,yi,xi,hints.out(ii).procSet{j});
                    end
                end

                e=T{ii,ts}-yi;
                if hints.doErrNorm(ii)
                    e=bsxfun(@times,e,hints.errNorm{ii});
                end

                if hints.perfMSE
                    perf=e.*e;
                else
                    perf=hints.perfApply(T{ii,ts},yi,e,hints.perfParam);
                end
                if hints.doEW
                    ew=EW{(EWii*(ii-1))+1,EWts*(ts-1)+1};
                    perf=bsxfun(@times,perf,ew);
                end

                for k=1:numMasks
                    perfk=perf.*masks{k}{ii,ts};
                    indk=find(isnan(perfk));
                    PerfN(k)=PerfN(k)+numel(perfk)-length(indk);
                    perfk(indk)=0;
                    Perfs(k)=Perfs(k)+sum(sum(perfk));

                    if(k==1)
                        e(indk)=0;
                        if hints.perfMSE
                            dperf=-bsxfun(@times,dY,-2*e);
                        else
                            dperf=-hints.perfFP(dY,T{ii,ts},yi,e,hints.perfParam);
                        end
                        if hints.doEW
                            dperf=bsxfun(@times,dperf,ew);
                        end
                        if hints.doErrNorm(ii)
                            dperf=bsxfun(@times,dperf,hints.errNorm{ii});
                        end
                        dperf=sum(dperf,2);
                        dperf=sum(dperf,1);
                        dperf=shiftdim(dperf,2);
                        gWB=gWB+dperf;
                    end
                end
            end
        end
    end

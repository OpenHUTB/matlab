function[Perfs,PerfN]=perfs(net,data,masks,hints)

    Q=data.Q;
    TS=data.TS;
    numMasks=numel(masks);

    Perfs=zeros(1,numMasks);
    PerfN=zeros(1,numMasks);
    EWts=size(data.EW,2)~=1;
    EWii=size(data.EW,1)~=1;
    Ac=[data.Ai,cell(net.numLayers,1)];
    Z=cell(1,hints.maxZ);
    bz=cell(net.numLayers,1);
    bq=ones(1,Q);
    for i=1:net.numLayers
        if net.biasConnect(i)
            bz{i}=net.b{i}(:,bq);
        end
    end

    if hints.doProcessInputs
        Pc=cell(net.numInputs,net.numInputDelays+1);
        for ts=1:net.numInputDelays
            for i=1:net.numInputs
                pi=data.Xi{i,ts};
                for j=1:hints.numInpProc(i)
                    pi=hints.inp(i).procApply{j}(pi,hints.inp(i).procSet{j});
                end
                Pc{i,ts}=pi;
            end
        end
    else
        Pc=data.Pc;
    end

    for ts=1:TS
        if hints.doProcessInputs
            for i=1:net.numInputs
                if hints.doProcessInputs
                    pi=data.X{i,ts};
                    for j=1:hints.numInpProc(i)
                        pi=hints.inp(i).procApply{j}(pi,hints.inp(i).procSet{j});
                    end
                    p_ts=rem(net.numInputDelays-1+ts,net.numInputDelays+1)+1;
                    Pc{i,p_ts}=pi;
                end
            end
        end

        for i=hints.layerOrder
            if net.biasConnect(i)
                Z{1}=bz{i};
            end

            for j=1:net.numInputs
                if net.inputConnect(i,j)
                    if hints.doDelayedInputs
                        if hints.doProcessInputs
                            p_ts=rem(((net.numInputDelays-1+ts)-net.inputWeights{i,j}.delays),net.numInputDelays+1)+1;
                        else
                            p_ts=(net.numInputDelays+ts)-net.inputWeights{i,j}.delays;
                        end
                        pd=cat(1,Pc{j,p_ts});
                    else
                        pd=data.Pd{i,j,ts};
                    end
                    Z{hints.iwzInd(i,j)}=hints.iwApply{i,j}(net.IW{i,j},pd,hints.iwParam{i,j});
                end
            end

            for j=1:net.numLayers
                if net.layerConnect(i,j)
                    a_ts=rem((net.numLayerDelays-net.layerWeights{i,j}.delays)-1+ts,net.numLayerDelays+1)+1;
                    ad=cat(1,Ac{j,a_ts});
                    Z{hints.lwzInd(i,j)}=hints.lwApply{i,j}(net.LW{i,j},ad,hints.lwParam{i,j});
                end
            end

            N=hints.netApply{i}(Z(1:hints.numZ(i)),net.layers{i}.size,Q,hints.netParam{i});
            a_ts=rem(net.numLayerDelays+ts-1,net.numLayerDelays+1)+1;
            Ac{i,a_ts}=hints.tfApply{i}(N,hints.tfParam{i});

            if net.outputConnect(i)
                yi=Ac{i,a_ts};
                ii=hints.layer2Output(i);
                for j=hints.numOutProc(ii):-1:1
                    yi=hints.out(ii).procRev{j}(yi,hints.out(ii).procSet{j});
                end

                e=data.T{ii,ts}-yi;
                e=bsxfun(@times,e,hints.errNorm{ii});
                perf=hints.perfApply(data.T{ii,ts},yi,e,hints.perfParam);
                ew=data.EW{(EWii*(ii-1))+1,EWts*(ts-1)+1};
                perf=bsxfun(@times,perf,ew);

                for k=1:numMasks
                    perfk=perf.*masks{k}{ii,ts};
                    ind=find(isnan(perfk));
                    PerfN(k)=PerfN(k)+numel(perfk)-length(ind);
                    perfk(ind)=0;
                    Perfs(k)=Perfs(k)+sum(sum(perfk));
                end
            end
        end
    end



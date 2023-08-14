function[JE,JJ,Perfs,PerfN]=fj(net,X,Xi,Pc,Pd,Ai,T,EW,masks,Q,TS,hints)




    JE=zeros(net.numWeightElements,1);
    JJ=zeros(net.numWeightElements,net.numWeightElements);

    numMasks=numel(masks);
    Perfs=zeros(1,numMasks);
    PerfN=zeros(1,numMasks);
    if(Q*TS==0)
        return
    end

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


    if hints.doProcessInputs
        Pc=cell(net.numInputs,net.numInputDelays+1);
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


        if hints.doProcessInputs
            for i=1:net.numInputs
                pi=X{i,ts};
                for j=1:hints.numInpProc(i)
                    pi=hints.inp(i).procApply{j}(pi,hints.inp(i).procSet{j});
                end
                p_ts=rem(net.numInputDelays-1+ts,net.numInputDelays+1)+1;
                Pc{i,p_ts}=pi;
            end
        end


        for i=hints.layerOrder


            if net.biasConnect(i)
                Z{1}=bz{i};

                if hints.bInclude(i)
                    dZ{1}=zeros(net.layers{i}.size,Q,net.numWeightElements);
                    dZ{1}(:,:,hints.bInd{i})=dZB{i};
                end
            end


            for j=1:net.numInputs
                if net.inputConnect(i,j)
                    ii=hints.iwzInd(i,j);
                    if hints.doDelayedInputs
                        if hints.doProcessInputs
                            p_ts=rem(((net.numInputDelays-1+ts)-net.inputWeights{i,j}.delays),net.numInputDelays+1)+1;
                        else
                            p_ts=(net.numInputDelays+ts)-net.inputWeights{i,j}.delays;
                        end
                        pd=cat(1,Pc{j,p_ts});
                    else
                        pd=Pd{i,j,ts};
                    end
                    Z{ii}=hints.iwApply{i,j}(net.IW{i,j},pd,hints.iwParam{i,j});

                    if hints.iwInclude(i,j)
                        dzw=hints.iwFS{i,j}(net.IW{i,j},pd,Z{ii},hints.iwParam{i,j});
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
                    Z{ii}=hints.lwApply{i,j}(net.LW{i,j},ad,hints.lwParam{i,j});

                    dAd=cat(1,dA{j,a_ts});
                    dzw1=hints.lwFP{i,j}(dAd,net.LW{i,j},ad,Z{ii},hints.lwParam{i,j});
                    if hints.lwInclude(i,j)
                        dzw2=hints.lwFS{i,j}(net.LW{i,j},ad,Z{ii},hints.lwParam{i,j});
                        dzw1(:,:,hints.lwInd{i,j})=dzw1(:,:,hints.lwInd{i,j})+dzw2(:,:,:);
                    end
                    dZ{ii}=dzw1;
                end
            end


            Zi=Z(1:hints.numZ(i));
            N=hints.netApply{i}(Zi,net.layers{i}.size,Q,hints.netParam{i});

            dN=zeros(net.layers{i}.size,Q,net.numWeightElements);
            for j=1:net.numLayers
                if net.layerConnect(i,j)
                    ii=hints.lwzInd(i,j);
                    dN=dN+hints.netFP{i}(dZ{ii},ii,Zi,N,hints.netParam{i});
                end
            end
            for j=1:net.numInputs
                if hints.iwInclude(i,j)
                    ii=hints.iwzInd(i,j);
                    dN=dN+hints.netFP{i}(dZ{ii},ii,Zi,N,hints.netParam{i});
                end
            end
            if hints.bInclude(i)
                dN=dN+hints.netFP{i}(dZ{1},1,Zi,N,hints.netParam{i});
            end


            a_ts=rem(net.numLayerDelays+ts-1,net.numLayerDelays+1)+1;
            A{i,a_ts}=hints.tfApply{i}(N,hints.tfParam{i});

            dA{i,a_ts}=hints.tfFP{i}(dN,N,A{i,a_ts},hints.tfParam{i});


            if net.outputConnect(i)
                yi=A{i,a_ts};
                dY=dA{i,a_ts};
                ii=hints.layer2Output(i);
                for j=hints.numOutProc(ii):-1:1
                    xi=yi;
                    yi=hints.out(ii).procRev{j}(xi,hints.out(ii).procSet{j});

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


                perf=e.*e;
                if hints.doEW
                    ew=EW{(EWii*(ii-1))+1,EWts*(ts-1)+1};
                    perf=bsxfun(@times,perf,ew);
                end


                for k=1:numMasks
                    if isempty(masks{k})
                        PerfN(k)=0;
                        Perfs(k)=NaN;
                    else
                        perfk=perf.*masks{k}{ii,ts};
                        indk=find(isnan(perfk));
                        PerfN(k)=PerfN(k)+numel(perfk)-length(indk);
                        perfk(indk)=0;
                        Perfs(k)=Perfs(k)+sum(sum(perfk));

                        if(k==1)
                            e(indk)=0;
                            if hints.doEW
                                sqrtew=sqrt(ew);
                                e=bsxfun(@times,e,sqrtew);
                                dY=bsxfun(@times,dY,sqrtew);
                            end
                            if hints.doErrNorm(ii)
                                dY=bsxfun(@times,dY,hints.errNorm{ii});
                            end
                            J=reshape(dY,hints.outputSizes(ii)*Q,net.numWeightElements);
                            J(indk,:)=0;
                            E=reshape(e,1,hints.outputSizes(ii)*Q);
                            JJ=JJ+J'*J;
                            JE=JE-(E*J)';
                        end
                    end
                end
            end
        end
    end


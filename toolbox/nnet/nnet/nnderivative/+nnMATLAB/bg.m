function[gWB,Perfs,PerfN]=bg(net,X,Xi,Pc,Pd,Ai,T,EW,masks,Q,TS,hints)

    numMasks=numel(masks);
    Perfs=zeros(1,numMasks);
    PerfN=zeros(1,numMasks);
    if(Q*TS==0)
        gWB=zeros(hints.wbLen,1);
        return
    end

    doDelayedInputs=isempty(Pd);
    doProcessInputs=isempty(Pc)&&isempty(Pd);
    dB=cell(net.numLayers,1);
    dIW=cell(net.numLayers,net.numInputs);
    dLW=cell(net.numLayers,net.numLayers);
    for i=1:net.numLayers
        if net.biasConnect(i)
            dB{i}=zeros(net.layers{i}.size,1);
        end
        for j=1:net.numInputs
            if net.inputConnect(i,j)
                dIW{i,j}=zeros(net.inputWeights{i,j}.size);
            end
        end
        for j=1:net.numLayers
            if net.layerConnect(i,j)
                dLW{i,j}=zeros(net.layerWeights{i,j}.size);
            end
        end
    end
    Yp=cell(1,hints.maxOutProc);
    Ac=[Ai,cell(net.numLayers,TS)];
    N=cell(net.numLayers,TS);
    Z=cell(net.numLayers,hints.maxZ,TS);
    dA=cell(net.numLayers,TS);
    for i=1:net.numLayers
        dA(i,:)={zeros(net.layers{i}.size,Q)};
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
                Pc{i,net.numInputDelays+ts}=pi;
            end
        end

        for i=hints.layerOrder

            if net.biasConnect(i)
                Z{i,1,ts}=bz{i};
                if hints.netNetsum(i)
                    n=bz{i};
                end
            else
                n=zeros(hints.layerSizes(i),Q);
            end

            for j=1:net.numInputs
                if net.inputConnect(i,j)
                    if doDelayedInputs
                        if hints.iwUnitDelay(i,j)
                            p_ts=net.numInputDelays+ts;
                            pd=Pc{j,p_ts};
                        else
                            p_ts=(net.numInputDelays+ts)-net.inputWeights{i,j}.delays;
                            pd=cat(1,Pc{j,p_ts});
                        end
                    else
                        pd=Pd{i,j,ts};
                    end
                    if hints.iwDotprod(i,j)
                        zi=net.IW{i,j}*pd;
                    else
                        zi=hints.iwApply{i,j}(net.IW{i,j},pd,hints.iwParam{i,j});
                    end
                    Z{i,hints.iwzInd(i,j),ts}=zi;
                    if hints.netNetsum(i)
                        n=n+zi;
                    end
                end
            end

            for j=1:net.numLayers
                if net.layerConnect(i,j)
                    if hints.lwUnitDelay(i,j)
                        a_ts=net.numLayerDelays+ts;
                        ad=Ac{j,a_ts};
                    else
                        a_ts=(net.numLayerDelays+ts)-net.layerWeights{i,j}.delays;
                        ad=cat(1,Ac{j,a_ts});
                    end
                    if hints.lwDotprod(i,j)
                        zi=net.LW{i,j}*ad;
                    else
                        zi=hints.lwApply{i,j}(net.LW{i,j},ad,hints.lwParam{i,j});
                    end
                    Z{i,hints.lwzInd(i,j),ts}=zi;
                    if hints.netNetsum(i)
                        n=n+zi;
                    end
                end
            end

            if hints.netNetsum(i)
                N{i,ts}=n;
            else
                N{i,ts}=hints.netApply{i}(Z(i,1:hints.numZ(i),ts),net.layers{i}.size,Q,hints.netParam{i});
            end
            a_ts=net.numLayerDelays+ts;
            if hints.tfPurelin(i)
                Ac{i,a_ts}=N{i,ts};
            elseif hints.tfTansig(i)
                Ac{i,a_ts}=2./(1+exp(-2*N{i,ts}))-1;
            else
                Ac{i,a_ts}=hints.tfApply{i}(N{i,ts},hints.tfParam{i});
            end
        end
    end

    a_ind=net.numLayerDelays+(1:TS);
    for i=1:net.numLayers
        if net.outputConnect(i)
            ii=hints.layer2Output(i);
            yi=[Ac{i,a_ind}];
            Yp{hints.numOutProc(ii)+1}=yi;
            for j=hints.numOutProc(ii):-1:1
                if hints.out(ii).procMapminmax(j)
                    settings=hints.out(ii).procSet{j};
                    yi=bsxfun(@minus,yi,settings.ymin);
                    yi=bsxfun(@rdivide,yi,settings.gain);
                    yi=bsxfun(@plus,yi,settings.xoffset);
                else
                    yi=hints.out(ii).procRev{j}(yi,hints.out(ii).procSet{j});
                end
                Yp{j}=yi;
            end

            ti=[T{ii,:}];
            e=ti-yi;
            if hints.doErrNorm(ii)
                e=bsxfun(@times,e,hints.errNorm{ii});
            end

            if hints.perfMSE
                perf=e.*e;
            else
                perf=hints.perfApply(ti,yi,e,hints.perfParam);
            end
            if hints.doEW
                if(hints.M_EW==1),ewii=1;else ewii=ii;end
                ew=[EW{ewii,:}];
                perf=bsxfun(@times,perf,ew);
            end

            for k=1:numMasks
                perfk=perf.*[masks{k}{ii,:}];
                indk=find(isnan(perfk));
                PerfN(k)=PerfN(k)+numel(perfk)-length(indk);
                perfk(indk)=0;
                Perfs(k)=Perfs(k)+sum(sum(perfk));

                if(k==1)
                    if hints.perfMSE
                        dy=2*e;
                    else
                        dy=-hints.perfBP(ti,yi,e,hints.perfParam);
                    end
                    if hints.doErrNorm(ii)
                        dy=bsxfun(@times,dy,hints.errNorm{ii});
                    end
                    if hints.doEW
                        dy=bsxfun(@times,dy,ew);
                    end
                    dy(indk)=0;
                    for j=1:hints.numOutProc(ii)
                        if hints.out(ii).procMapminmax(j)
                            dy=bsxfun(@rdivide,dy,hints.out(ii).procSet{j}.gain);
                        else
                            dy=hints.out(ii).procBPrev{j}(dy,Yp{j},Yp{j+1},hints.out(ii).procSet{j});
                        end
                    end
                    dA(i,:)=fast_mat2cell(dy,Q,TS);
                end
            end
        end
    end

    for ts=TS:-1:1
        for i=hints.layerOrderReverse

            a_ts=net.numLayerDelays+ts;
            if hints.tfPurelin(i)
                dn=dA{i,ts};
            elseif hints.tfTansig(i)
                dn=(1-(Ac{i,a_ts}.*Ac{i,a_ts})).*dA{i,ts};
            else
                dn=hints.tfBP{i}(dA{i,ts},N{i,ts},Ac{i,a_ts},hints.tfParam{i});
            end
            dA(i,ts)={[]};
            Zi=Z(i,1:hints.numZ(i),ts);

            for j=net.numLayers:-1:1
                if net.layerConnect(i,j)
                    ii=hints.lwzInd(i,j);
                    if hints.netNetsum(i)
                        dz=dn;
                    else
                        dz=hints.netBP{i}(dn,ii,Zi,N{i,ts},hints.netParam{i});
                    end
                    if hints.lwUnitDelay(i,j)
                        a_ts=net.numLayerDelays+ts;
                        ad=Ac{j,a_ts};
                    else
                        a_ts=(net.numLayerDelays+ts)-net.layerWeights{i,j}.delays;
                        ad=cat(1,Ac{j,a_ts});
                    end
                    if hints.lwInclude(i,j)
                        if hints.lwDotprod(i,j)
                            dLW{i,j}=dLW{i,j}+dz*ad';
                        else
                            dLW{i,j}=dLW{i,j}+hints.lwBS{i,j}(dz,net.LW{i,j},ad,Z{i,ii,ts},hints.lwParam{i,j});
                        end
                    end

                    if hints.lwDotprod(i,j)
                        dad=net.LW{i,j}'*dz;
                    else
                        dad=hints.lwBP{i,j}(dz,net.LW{i,j},ad,Z{i,ii,ts},hints.lwParam{i,j});
                    end
                    delays=ts-net.layerWeights{i,j}.delays;
                    numDelays=numel(delays);
                    wsize=size(dad,1)/numDelays;
                    for k=1:numDelays
                        ts_k=delays(k);
                        if(ts_k>0)
                            dA{j,ts_k}=dA{j,ts_k}+dad((wsize*(k-1))+(1:wsize),:);
                        end
                    end
                end
            end

            for j=net.numInputs:-1:1
                if net.inputConnect(i,j)
                    ii=hints.iwzInd(i,j);
                    if hints.netNetsum(i)
                        dz=dn;
                    else
                        dz=hints.netBP{i}(dn,ii,Zi,N{i,ts},hints.netParam{i});
                    end

                    if hints.iwInclude(i,j)
                        if doDelayedInputs
                            if hints.iwUnitDelay(i,j)
                                p_ts=net.numInputDelays+ts;
                                pd=Pc{j,p_ts};
                            else
                                p_ts=(net.numInputDelays+ts)-net.inputWeights{i,j}.delays;
                                pd=cat(1,Pc{j,p_ts});
                            end
                        else
                            pd=Pd{i,j,ts};
                        end
                        if hints.iwDotprod(i,j)
                            dIW{i,j}=dIW{i,j}+dz*pd';
                        else
                            dIW{i,j}=dIW{i,j}+hints.iwBS{i,j}(dz,net.IW{i,j},pd,Z{i,ii,ts},hints.iwParam{i,j});
                        end
                    end
                end
            end

            if hints.bInclude(i)
                if hints.netNetsum(i)
                    dB{i}=dB{i}+sum(dn,2);
                else
                    dB{i}=dB{i}+sum(hints.netBP{i}(dn,1,Zi,N{i,ts},hints.netParam{i}),2);
                end
            end
        end
    end

    gWB=formwb(net,dB,dIW,dLW,hints);


    function c=fast_mat2cell(m,colSize,cols)
        c=cell(1,cols);
        colStart=0;
        for j=1:cols
            c{1,j}=m(:,colStart+(1:colSize));
            colStart=colStart+colSize;
        end

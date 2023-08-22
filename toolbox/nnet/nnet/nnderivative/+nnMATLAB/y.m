function[Y,Af]=y(net,data,hints)

    Q=data.Q;
    TS=data.TS;

    if(TS==0)
        Y=cell(net.numOutputs,0);
        if nargout>1
            Af=data.Ai;
        end
        return
    end

    Ac=[data.Ai,cell(net.numLayers,TS)];
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
    else
        Pc=data.Pc;
    end

    for ts=1:TS
        if hints.doProcessInputs
            for i=1:net.numInputs
                if hints.doProcessInputs
                    pi=data.X{i,ts};
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
        end

        for i=hints.layerOrder
            if net.biasConnect(i)
                if hints.netNetsum(i)
                    n=bz{i};
                else
                    Z{1}=bz{i};
                end
            elseif hints.netNetsum(i)
                n=zeros(hints.layerSizes(i),Q);
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
                    if hints.iwDotprod(i,j)
                        zi=net.IW{i,j}*pd;
                    else
                        zi=hints.iwApply{i,j}(net.IW{i,j},pd,hints.iwParam{i,j});
                    end
                    if hints.netNetsum(i)
                        n=n+zi;
                    else
                        Z{hints.iwzInd(i,j)}=zi;
                    end
                end
            end

            for j=1:net.numLayers
                if net.layerConnect(i,j)
                    a_ts=net.numLayerDelays+ts-net.layerWeights{i,j}.delays;
                    ad=cat(1,Ac{j,a_ts});
                    if hints.lwDotprod(i,j)
                        zi=net.LW{i,j}*ad;
                    else
                        zi=hints.lwApply{i,j}(net.LW{i,j},ad,hints.lwParam{i,j});
                    end
                    if hints.netNetsum(i)
                        n=n+zi;
                    else
                        Z{hints.lwzInd(i,j)}=zi;
                    end
                end
            end

            if hints.netNetsum(i)
                N=n;
            else
                N=hints.netApply{i}(Z(1:hints.numZ(i)),net.layers{i}.size,Q,hints.netParam{i});
            end
            a_ts=net.numLayerDelays+ts;
            if hints.tfPurelin(i)
                Ac{i,a_ts}=N;
            elseif hints.tfTansig(i)
                Ac{i,a_ts}=2./(1+exp(-2*N))-1;
            else
                Ac{i,a_ts}=hints.tfApply{i}(N,hints.tfParam{i});
            end
        end
    end

    Y=cell(net.numOutputs,TS);
    a_ind=net.numLayerDelays+(1:TS);
    for i=1:net.numLayers
        if net.outputConnect(i)
            ii=hints.layer2Output(i);
            yi=[Ac{i,a_ind}];
            for j=hints.numOutProc(ii):-1:1
                if hints.out(ii).procMapminmax(j)
                    settings=hints.out(ii).procSet{j};
                    yi=bsxfun(@minus,yi,settings.ymin);
                    yi=bsxfun(@rdivide,yi,settings.gain);
                    yi=bsxfun(@plus,yi,settings.xoffset);
                else
                    yi=hints.out(ii).procRev{j}(yi,hints.out(ii).procSet{j});
                end
            end
            Y(ii,:)=fast_mat2cell(yi,Q,TS);
        end
    end

    if nargout>1
        a_ts=TS+(1:net.numLayerDelays);
        Af=Ac(:,a_ts);
    end


    function c=fast_mat2cell(m,colSize,cols)
        c=cell(1,cols);
        colStart=0;
        for j=1:cols
            c{1,j}=m(:,colStart+(1:colSize));
            colStart=colStart+colSize;
        end

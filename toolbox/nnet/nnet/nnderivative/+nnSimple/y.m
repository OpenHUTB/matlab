function[Y,Af]=y(net,data,hints)




    Q=data.Q;
    TS=data.TS;

    Ac=[data.Ai,cell(net.numLayers,1)];
    Z=cell(1,hints.maxZ);
    bz=cell(net.numLayers,1);
    bq=ones(1,Q);
    for i=1:net.numLayers
        if net.biasConnect(i)
            bz{i}=net.b{i}(:,bq);
        end
    end

    Y=cell(net.numOutputs,TS);


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
                    a_ts=rem((net.numLayerDelays-1+ts)-net.layerWeights{i,j}.delays,net.numLayerDelays+1)+1;
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
                Y{ii,ts}=yi;
            end
        end
    end


    if nargout>1
        a_ts=rem((TS-1)+(1:net.numLayerDelays),net.numLayerDelays+1)+1;
        Af=Ac(:,a_ts);
    end


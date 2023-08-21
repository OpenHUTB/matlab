function signals=y_all(net,signals,hints)

    IW=net.IW;
    LW=net.LW;
    Q=signals.Q;
    Zb=nntraining.bz(net,signals.Q,hints);
    TS=signals.TS;
    Zi=cell(net.numLayers,net.numInputs,TS);
    Zl=cell(net.numLayers,net.numLayers,TS);
    N=cell(net.numLayers,TS);
    Ac=[signals.Ai,cell(net.numLayers,TS)];
    Yp=cell(net.numOutputs,TS);
    Y=cell(net.numOutputs,TS);

    for ts=1:TS
        for i=hints.simLayerOrder
            ts2=net.numLayerDelays+ts;
            layer=net.layers{i};
            inputInds=hints.inputConnectFrom{i};
            for j=inputInds
                pd=calc_pd(net,signals.Q,signals.Pc,signals.Pd,i,j,ts);
                weightFcn=hints.inputWeights(i,j).weight;
                Zi{i,j,ts}=weightFcn.apply(IW{i,j},pd,weightFcn.param);
            end
            layerInds=hints.layerConnectFrom{i};
            for j=layerInds
                lw=net.layerWeights{i,j};
                if hints.layerConnectOZD(i,j);
                    Ad=Ac{j,ts2};
                else
                    Ad=nnfast.tapdelay(Ac,j,ts2,lw.delays);
                end
                weightFcn=hints.layerWeights(i,j).weight;
                Zl{i,j,ts}=weightFcn.apply(LW{i,j},Ad,weightFcn.param);
            end
            Z=[Zi(i,inputInds,ts),Zl(i,layerInds,ts),Zb(i,net.biasConnect(i))];
            netFcn=hints.layers(i).netInput;
            n=netFcn.apply(Z,net.layers{i}.size,Q,netFcn.param);
            if isempty(Z),n=zeros(net.layers{i}.size,signals.Q)+n;end
            N{i,ts}=n;

            fcn=hints.layers(i).transfer;
            Ac{i,ts2}=fcn.apply(N{i,ts},fcn.param);

            if net.outputConnect(i)

                ii=hints.layer2output(i);
                numSteps=length(hints.outputs(ii).process);
                y=Ac{i,ts2};
                Yp{ii,ts}=cell(1,numSteps);
                for j=numSteps:-1:1
                    fcn=hints.outputs(ii).process(j);
                    if~fcn.settings.no_change
                        y=fcn.reverse(y,fcn.settings);
                    end
                    Yp{ii,ts}{j}=y;
                end

                Y{ii,ts}=y;
            end
        end
    end

    signals.Zb=Zb;
    signals.Zl=Zl;
    signals.Zi=Zi;
    signals.N=N;
    signals.Ac=Ac;
    signals.Y=Y;
    signals.Yp=Yp;


    function pd=calc_pd(net,Q,P,PD,i,j,ts,qq)

        numTS=length(ts);
        delays=net.inputWeights{i,j}.delays;
        if isempty(delays)
            if nargin<8
                pd=zeros(0,Q);
            else
                pd=zeros(0,length(qq));
            end
            return
        end

        if nargin<8

            if isempty(PD)
                if numTS==1
                    pd=nnfast.tapdelay(P,j,ts+net.numInputDelays,delays);
                else
                    pd=cell(1,numTS);
                    for k=1:numTS
                        pd{k}=nnfast.tapdelay(P,j,ts(k)+net.numInputDelays,delays);
                    end
                    pd=[pd{:}];
                end
            else
                if numTS==1
                    pd=PD{i,j,ts};
                else
                    pd=[PD{i,j,ts}];
                end
            end
        else
            numTS=length(ts);
            if isempty(PD)
                if numTS==1
                    pd=nnfast.tapdelay(P,j,ts+net.numInputDelays,delays,qq);
                else
                    pd=cell(1,numTS);
                    for k=1:numTS
                        pd{k}=nnfast.tapdelay(P,j,ts(k)+net.numInputDelays,delays,qq);
                    end
                    pd=[pd{:}];
                end
            else
                if numTS==1
                    pd=PD{i,j,ts}(:,qq);
                else
                    pd=cell(1,ts);
                    for tsi=ts,pd{tsi}=PD{i,j,tsi}(:,qq);end
                    pd=[pd{:}];
                end
            end

        end

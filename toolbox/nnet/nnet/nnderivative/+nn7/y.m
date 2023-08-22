function[Y,Af]=y(net,data,hints)

    Ai=data.Ai;
    Q=data.Q;
    TS=data.TS;

    if hints.doProcessInputs
        Pc=nn7.pc(net,data.X,data.Xi,Q,TS,hints);
    else
        Pc=data.Pc;
    end
    if hints.doDelayedInputs
        Pd=nn7.pd(net,Pc);
    else
        Pd=data.Pd;
    end

    if(Q==0)||(TS==0)||(net.numLayers==0)
        Ac=cell(net.numLayers,net.numLayerDelays+TS);
        Ac(:,1:net.numLayerDelays)=data.Ai;
        for i=1:net.numLayers
            Ac(i,(net.numLayerDelays+1):end)={zeros(net.layers{i}.size,Q)};
        end
    elseif(net.numLayerDelays==0)&&(TS>1)
        Pd=nncalc.seq2con3(Pd);
        Ac=calca(net,Pd,Ai,Q*TS,1,hints);
        Ac=con2seq(Ac,TS);
    else
        Ac=calca(net,Pd,Ai,Q,TS,hints);
    end

    A=Ac(:,net.numLayerDelays+(1:TS));
    Y=A(hints.outputInd,:);
    Y=post_outputs(hints,Y);

    Af=Ac(:,TS+(1:net.numLayerDelays));
    function[Ac,N,LWZ,IWZ,BZ]=calca(net,PD,Ai,Q,TS,hints)

        BZ=cell(net.numLayers,1);
        ones1xQ=ones(1,Q);
        for i=1:net.numLayers
            if net.biasConnect(i)
                BZ{i}=net.b{i}(:,ones1xQ);
            end
        end
        IWZ=cell(net.numLayers,net.numInputs,TS);
        LWZ=cell(net.numLayers,net.numLayers,TS);
        Ac=[Ai,cell(net.numLayers,TS)];
        N=cell(net.numLayers,TS);
        numLayerDelays=net.numLayerDelays;
        inputConnectFrom=hints.inputConnectFrom;
        layerConnectFrom=hints.layerConnectFrom;
        layerDelays=hints.layerDelays;
        layerHasNoDelays=hints.layerConnectOZD;
        IW=net.IW;
        LW=net.LW;

        for ts=1:TS
            for i=hints.simLayerOrder
                ts2=numLayerDelays+ts;
                inputInds=inputConnectFrom{i};
                for j=inputInds
                    weightFcn=hints.inputWeights(i,j).weight;
                    IWZ{i,j,ts}=weightFcn.apply(IW{i,j},PD{i,j,ts},weightFcn.param);
                end
                layerInds=layerConnectFrom{i};
                for j=layerInds
                    if layerHasNoDelays(i,j);
                        Ad=Ac{j,ts2};
                    else
                        Ad=nnfast.tapdelay(Ac,j,ts2,layerDelays{i,j});
                    end
                    weightFcn=hints.layerWeights(i,j).weight;
                    LWZ{i,j,ts}=weightFcn.apply(LW{i,j},Ad,weightFcn.param);
                end
                Z=[IWZ(i,inputInds,ts),LWZ(i,layerInds,ts),BZ(i,net.biasConnect(i))];
                netFcn=hints.layers(i).netInput;
                n=netFcn.apply(Z,net.layers{i}.size,Q,netFcn.param);
                if isempty(Z),n=zeros(net.layers{i}.size,Q)+n;end
                N{i,ts}=n;
                transferFcn=hints.layers(i).transfer;
                Ac{i,ts2}=transferFcn.apply(N{i,ts},transferFcn.param);
            end
        end


        function y=post_outputs(hints,y)

            for i=1:size(y,1)
                y(i,:)=reverse_process(hints.outputs(i).process,y(i,:));
            end


            function x=reverse_process(fcns,x)

                fcns=active_fcns(fcns);
                [rows,cols]=size(x);
                functionOrder=length(fcns):-1:1;
                for i=1:rows
                    for j=1:cols
                        xij=x{i,j};
                        for k=functionOrder
                            fcn=fcns(k);
                            xij=fcn.reverse(xij,fcn.settings);
                        end
                        x{i,j}=xij;
                    end
                end
                function[fcns,active]=active_fcns(fcns)

                    numFcns=length(fcns);
                    active=false(1,numFcns);
                    for i=1:numFcns
                        active(i)=~fcns(i).settings.no_change;
                    end
                    fcns=fcns(active);


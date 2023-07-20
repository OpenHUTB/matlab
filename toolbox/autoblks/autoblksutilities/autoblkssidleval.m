







function y=autoblkssidleval(x,u,params)

%#codegen
    coder.allowpcode('plain');


    dxdt=[x;u];


    actfun=cell(1,params.fcLayerSize);
    for k=1:length(actfun)
        switch params.("actFun_"+k)
        case 'gelu'
            actfun{k}=@gelu;
        case 'tanh'
            actfun{k}=@tanh;
        case 'radbas'
            actfun{k}=@radbas;
        end
    end


    tmp=cell(1,params.fcLayerSize+1);
    tmp{1}=actfun{1}(params.inputLayer.Weights*dxdt+params.inputLayer.Bias);

    for k=1:params.fcLayerSize
        tmp{k+1}=actfun{k}(params.("fcLayer"+k+"Weights")*tmp{k}+params.("fcLayer"+k+"Bias"));
    end

    y=params.outputLayer.Weights*tmp{end}+params.outputLayer.Bias;
end

function y=gelu(x)

%#codegen
    y=(x/2).*(1+tanh(sqrt(2/pi)*(x+0.044715*x.^3)));
end

function y=radbas(x)

%#codegen
    y=exp(-x.^2);
end
function layoutforce(H,varargin)

























    iterations=100;
    usedefaultX=true;
    usedefaultY=true;
    weightEffect='none';
    gravity='off';


    nvarargin=length(varargin);
    if rem(nvarargin,2)~=0
        error(message('MATLAB:graphfun:plot:ArgNameValueMismatch'));
    end
    layoutparams=varargin;
    for i=1:2:nvarargin
        name=validatestring(varargin{i},{'Iterations','XStart','YStart','WeightEffect','UseGravity'});
        layoutparams{i}=name;
        switch name
        case 'Iterations'
            iterations=varargin{i+1};
        case 'XStart'
            usedefaultX=false;
            x0=varargin{i+1};
        case 'YStart'
            usedefaultY=false;
            y0=varargin{i+1};
        case 'WeightEffect'
            weightEffect=varargin{i+1};
        case 'UseGravity'
            gravity=varargin{i+1};
        end
    end


    [G,kw]=matlab.internal.graph.forceLayoutReweightAndSimplify(H.BasicGraph_,H.EdgeWeights_,weightEffect);

    if usedefaultX&&usedefaultY

        [x0,y0]=subspaceLayout(G,min(20,numnodes(G)),2);


        x0=double(single(x0));
        y0=double(single(y0));

        [XData,YData,iterations]=forceLayout(G,x0-y0,x0+y0,iterations,kw,gravity);

        if iterations<=0
            XData=H.XData_I;
            YData=H.YData_I;
        end
    elseif~usedefaultX&&~usedefaultY
        [XData,YData,~]=forceLayout(G,x0,y0,iterations,kw,gravity);
    else
        error(message('MATLAB:graphfun:plot:MissingXStartOrYStart'));
    end


    if~all(isfinite(XData))||~all(isfinite(YData))
        error(message('MATLAB:graphfun:graphbuiltin:WEffLayoutFailed'))
    end

    H.Layout_='force';
    H.LayoutParameters_=layoutparams;
    setData(H,XData,YData);

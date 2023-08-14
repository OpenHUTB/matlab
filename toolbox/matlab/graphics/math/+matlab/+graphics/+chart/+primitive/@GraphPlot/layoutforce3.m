function layoutforce3(H,varargin)

























    iterations=100;
    usedefaultX=true;
    usedefaultY=true;
    usedefaultZ=true;
    weightEffect='none';
    gravity='off';


    nvarargin=length(varargin);
    if rem(nvarargin,2)~=0
        error(message('MATLAB:graphfun:plot:ArgNameValueMismatch'));
    end
    layoutparams=varargin;
    for i=1:2:nvarargin
        name=validatestring(varargin{i},{'Iterations','XStart','YStart','ZStart','WeightEffect','UseGravity'});
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
        case 'ZStart'
            usedefaultZ=false;
            z0=varargin{i+1};
        case 'WeightEffect'
            weightEffect=varargin{i+1};
        case 'UseGravity'
            gravity=varargin{i+1};
        end
    end


    [G,kw]=matlab.internal.graph.forceLayoutReweightAndSimplify(H.BasicGraph_,H.EdgeWeights_,weightEffect);

    if usedefaultX&&usedefaultY&&usedefaultZ

        [x0,y0,z0]=subspaceLayout(G,min(20,numnodes(G)),3);


        x0=double(single(x0));
        y0=double(single(y0));
        z0=double(single(z0));

        [XData,YData,ZData,iterations]=forceLayout3(G,x0-y0,x0+y0,z0,iterations,kw,gravity);

        if iterations<=0
            XData=H.XData_I;
            YData=H.YData_I;
            ZData=H.ZData_I;
        end
    elseif~usedefaultX&&~usedefaultY&&~usedefaultZ
        [XData,YData,ZData,~]=forceLayout3(G,x0,y0,z0,iterations,kw,gravity);
    else
        error(message('MATLAB:graphfun:plot:MissingXStartYStartOrZStart'));
    end


    if~all(isfinite(XData))||~all(isfinite(YData))||~all(isfinite(ZData))
        error(message('MATLAB:graphfun:graphbuiltin:WEffLayoutFailed'))
    end

    H.Layout_='force3';
    H.LayoutParameters_=layoutparams;
    setData(H,XData,YData,ZData);

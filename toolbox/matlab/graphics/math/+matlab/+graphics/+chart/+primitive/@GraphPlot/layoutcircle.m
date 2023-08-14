function layoutcircle(H,varargin)















    center=NaN;

    nvarargin=length(varargin);
    if rem(nvarargin,2)~=0
        error(message('MATLAB:graphfun:plot:ArgNameValueMismatch'));
    end
    layoutparams=varargin;
    for i=1:2:nvarargin
        name=validatestring(varargin{i},{'Center'});
        layoutparams{i}=name;

        center=validateNodeIDScalar(H.BasicGraph_,H.NodeNames_,varargin{i+1});
    end

    nn=numnodes(H.BasicGraph_);

    H.Layout_='circle';
    H.LayoutParameters_=layoutparams;

    if~isnan(center)
        A=adjacency(H.BasicGraph_);
        ncids=1:nn;
        ncids(center)=[];


        permnc=symrcm(A(ncids,ncids));

        w=linspace(0,360,nn);
        w(ncids)=w(1:nn-1);
        w(center)=0;
        xData=zeros(1,nn);
        yData=zeros(1,nn);
        xData(ncids(permnc))=cosd(w(ncids));
        yData(ncids(permnc))=sind(w(ncids));

        setData(H,xData,yData);

        H.CirclePerm_=zeros(1,nn);

        H.CirclePerm_(1)=center;
        H.CirclePerm_(2:end)=permnc;
    else
        w=linspace(0,360,nn+1);
        w=w(1:nn).';

        setData(H,cosd(w),sind(w));
        H.CirclePerm_=[];
    end

    function src=validateNodeIDScalar(G,nodeNames,s)


        if isempty(s)
            error(message('MATLAB:graphfun:graphbuiltin:InvalidCenterType'));
        end

        nrNodes=numnodes(G);
        if matlab.internal.datatypes.isCharStrings(s,false,false)||isstring(s)
            s=cellstr(s);
            if length(s(:))>1
                error(message('MATLAB:graphfun:graphbuiltin:InvalidCenterType'));
            end
            if isempty(nodeNames)
                s=s{:};
                error(message('MATLAB:graphfun:graph:UnknownNodeName',s));
            end
            [~,src]=ismember(s(:),nodeNames);
        elseif isnumeric(s)
            s=s(:);
            if length(s)>1
                error(message('MATLAB:graphfun:graphbuiltin:InvalidCenterType'));
            end
            if~isreal(s)||~isfinite(s)||any(fix(s)~=s)||any(s<1)
                error(message('MATLAB:graphfun:graphbuiltin:InvalidCenterNumeric'));
            end
            src=s;
            src(src>nrNodes)=0;
        else
            error(message('MATLAB:graphfun:graphbuiltin:InvalidCenterType'));
        end

        if any(src==0)
            if isnumeric(s)
                error(message('MATLAB:graphfun:graphbuiltin:CenterTooLarge',nrNodes));
            else
                if iscellstr(s)
                    i=find(src==0,1);
                    s=s{i};
                end
                error(message('MATLAB:graphfun:graph:UnknownNodeName',s));
            end
        end
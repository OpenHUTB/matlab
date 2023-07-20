function varargout=FunctionConnectorAction(action,varargin)
    try
        switch action
        case 'Wormhole'
            WormholeToCalledFunction(varargin{1},varargin{2},varargin{3});

        case 'NotFound'


        case 'MulticastLayout'
            assert(nargin==6);
            numNodes=varargin{1};
            x=varargin{2};
            y=varargin{3};
            sources=varargin{4};
            targets=varargin{5};
            useDefaultLayout=true;
            if~isempty(which('sl_customize_connector.m'))
                try %#ok
                    [varargout{1:nargout}]=sl_customize_connector(action,varargin{:});
                    useDefaultLayout=false;
                end
            end
            if useDefaultLayout


                [varargout{1:nargout}]=l_FunctionConnectorLayout1(numNodes,x',y',sources',targets');
            end
        otherwise
            assert(false,['Unhandled action ''',action,''' in FunctionConnectorAction']);
        end
    catch E
        warning(E.message);
    end
end

function WormholeToCalledFunction(fcnPort,calledBlock,fcnName)

    callingBlockPathObj=gcbp;
    bpToOpen={};
    for i=1:(callingBlockPathObj.getLength()-1)
        bpToOpen{i}=callingBlockPathObj.getBlock(i);
    end
    bpToOpen{end+1}=getfullname(calledBlock);
    bp=Simulink.BlockPath(bpToOpen);



    if(strcmp(get_param(calledBlock,'BlockType'),'Inport')&&...
        strcmp(get_param(calledBlock,'IsClientServer'),'on'))
        open_system(get_param(calledBlock,'Parent'));
    end
    bp.open();

end

function[x,y]=l_FunctionConnectorLayout1(numNodes,x,y,sources,targets)

    d=.01;
    iterations=5;
    numConns=length(x)-numNodes;
    x1=zeros(numConns,1);
    y1=zeros(numConns,1);
    counts=zeros(numConns,1);
    for i=1:length(sources)
        src=sources(i);
        tgt=targets(i)-numNodes;

        x1(tgt)=x1(tgt)+x(src);
        y1(tgt)=y1(tgt)+y(src);
        counts(tgt)=counts(tgt)+1;
    end

    x1=x1./counts;
    y1=y1./counts;

    v=zeros(numConns,1);
    w=zeros(numConns,1);

    for i=1:iterations
        [x1,y1,v,w]=solveForceEquation(numNodes,x,y,x1,y1,v,w,d,sources,targets);
        d=d/1.2;
        x(numNodes+1:end)=x1;
        y(numNodes+1:end)=y1;
    end
end

function[x1,y1,v,w]=solveForceEquation(numNodes,x,y,x1,y1,v,w,d,srcs,tgts)

    x1=x1+d*v;
    y1=y1+d*w;
    numConns=length(x)-numNodes;
    Fx=zeros(numConns,1);
    Fy=zeros(numConns,1);
    m=1;
    K=-1;
    K2=2;
    K3=.00001;

    for i=1:length(srcs)
        src=srcs(i);

        tgt=tgts-numNodes;
        Dx=x1(tgt)-x(src);
        Dy=y1(tgt)-y(src);
        Dx(Dx>=0&Dx<1)=1;
        Dx(Dx<0&Dx>-1)=-1;
        Dy(Dy>=0&Dy<1)=1;
        Dy(Dy<0&Dy>-1)=-1;
        D=sqrt(Dx.^2+Dy.^2);

        Fx(tgt)=Fx(tgt)+K*Dx.*abs(Dx)./D;
        Fy(tgt)=Fy(tgt)+K*Dy.*abs(Dy)./D;

    end

    for i=1:length(x)
        if i>numNodes
            j=i-numNodes;
            Fxi=Fx(j);
            Fyi=Fy(j);
        end
        Dx=K3*(x1-x(i));
        Dy=K3*(y1-y(i));
        Dx(Dx>=0&Dx<K3)=K3;
        Dx(Dx<0&Dx>-K3)=-K3;
        Dy(Dy>=0&Dy<K3)=K3;
        Dy(Dy<0&Dy>-K3)=-K3;
        D=sqrt(Dx.^2+Dy.^2);

        Fx=Fx+K2*Dx./(abs(Dx).*D);
        Fy=Fy+K2*Dy./(abs(Dy).*D);
        if i>numNodes
            Fx(j)=Fxi;
            Fy(j)=Fyi;
        end
    end

    v=v+d*Fx/m;
    w=w+d*Fy/m;
end

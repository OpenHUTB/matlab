function[varargout]=autoblksSGFS(varargin)



    block=varargin{1};


    ParamList={'N',[1,1],{'int',0;'gt',0};...
    'F',[1,1],{'int',0;'gt',0};...
    'Ts',[1,1],{'gt',0};...
    };
    Params=autoblkscheckparams(block,'SG Filter',ParamList);

    F=Params.F;
    N=Params.N;

    b=single(fliplr(vander(-(F-1)/2:(F-1)/2)));
    B=single(b(:,1:N+1));
    W=eye(F,'single');
    R=W;
    [~,R]=qr(sqrt(W)*B,0);
    G=single((B/R)*inv(R)');
    varargout{1}=G;
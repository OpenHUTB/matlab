function[varargout]=autoblksSGF(varargin)



    block=varargin{1};


    ParamList={'N',[1,1],{'int',0;'gt',0};...
    'F',[1,1],{'int',0;'gt',0};...
    'div0Tol',[1,1],{'gt',0};...
    };
    Params=autoblkscheckparams(block,'SG Filter',ParamList);

    F=Params.F;
    N=Params.N;

    b=fliplr(vander(-(F-1)/2:(F-1)/2));
    B=b(:,1:N+1);
    W=eye(F,'double');
    [~,R]=qr(sqrt(W)*B,0);
    G=(B/R)*inv(R)';

    varargout{1}=G;
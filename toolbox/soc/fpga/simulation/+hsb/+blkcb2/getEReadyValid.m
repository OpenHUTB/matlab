function r=getEReadyValid(varargin)

%#codegen
    coder.allowpcode('plain');


    emode=varargin{1};
    prob=varargin{2};
    count=varargin{3};
    tlen=varargin{4};

    r=~(emode&&...
    rand(1,1)<prob&&...
    count<(tlen-1));
end

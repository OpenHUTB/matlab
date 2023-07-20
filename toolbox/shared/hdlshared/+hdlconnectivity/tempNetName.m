function name=tempNetName(seed)














    mlock;

    persistent inc;

    if isempty(inc)
        inc=0;
    end

    if nargin==1
        inc=seed;
    end

    name=['connectivityNet_',num2str(inc)];

    inc=inc+1;

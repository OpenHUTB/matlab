function out=CodeGenIntent(input)

    mlock;
    persistent val;
    if isempty(val)
        val=0;
    end

    out=val;

    if nargin>0
        val=input;
    end



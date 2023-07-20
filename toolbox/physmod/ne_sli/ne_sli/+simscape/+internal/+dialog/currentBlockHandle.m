function out=currentBlockHandle(in)




    persistent CURRENT_BLOCK;
    if nargin>0
        CURRENT_BLOCK=in;
    end
    out=CURRENT_BLOCK;

end
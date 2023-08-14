function assert(boolFlag,msg)






    if nargin==1
        assert(boolFlag);
    else
        assert(boolFlag,msg);
    end
end

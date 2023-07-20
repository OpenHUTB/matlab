function singleObj=getInstance(init)






    mlock;
    persistent singleton;
    if isempty(singleton)||~isvalid(singleton)
        if nargin==0||init
            singleton=slreq.data.ReqData();
        end
    end
    singleObj=singleton;
end

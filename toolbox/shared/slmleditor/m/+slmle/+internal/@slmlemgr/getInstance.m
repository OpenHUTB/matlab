function obj=getInstance()



    mlock;
    persistent m;
    if isempty(m)
        m=slmle.internal.slmlemgr();
    end

    obj=m;
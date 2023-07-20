function birun=isrunning(h)












    narginchk(1,1);

    for k=1:length(h)
        birun(k)=(h(k).mIdeModule.IsRunning==1);
    end



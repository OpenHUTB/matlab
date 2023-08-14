function enableListeners(p,state)






    lis=p.hListeners;
    if~isempty(lis)
        if nargin<2
            state=true;
        end
        lis.PropertyChanges.Enabled=state;
        lis.ParentResize.Enabled=state;
    end

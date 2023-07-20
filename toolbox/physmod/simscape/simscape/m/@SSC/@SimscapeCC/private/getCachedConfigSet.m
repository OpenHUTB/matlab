function cs=getCachedConfigSet(mdl,doClear)








    if nargin==1
        doClear=false;
    end


    persistent MAP;









    cs=[];
    if isfield(MAP,mdl)
        cs=MAP.(mdl);
        if doClear
            MAP=rmfield(MAP,mdl);
            cs=[];
        end
    else
        if~doClear
            cs=SSC.SimscapeCC;
            cs.initialize;
            MAP.(mdl)=cs;
        end
    end


end

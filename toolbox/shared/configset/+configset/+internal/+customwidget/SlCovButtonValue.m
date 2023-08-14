function out=SlCovButtonValue(cs,name,direction,~)



    cs=cs.getConfigSet;

    if direction==0
        out={''};
    elseif direction==1
        out=cs.get_param(name);
    end


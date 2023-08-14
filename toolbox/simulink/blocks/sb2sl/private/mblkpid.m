function[xi,xd]=mblkpid(ki,kd,tau,x0)







    if(isempty(x0))
        x0=zeros(1,2);
    end
    if((ki==0)&(kd==0))
        xi=0;
        xd=0;
    elseif(ki==0)
        xi=0;
        xd=-tau*x0(1);
    elseif(kd==0)
        xi=x0(1);
        xd=0;
    else
        xi=x0(1);
        xd=-tau*x0(2);
    end
    return

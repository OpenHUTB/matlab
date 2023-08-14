function[x,amam,ampm]=calcampm(h,fc)





    x=[];
    amam=[];
    ampm=[];


    if haspowerreference(h)
        refobj=getreference(h);
        pdata=get(refobj,'PowerData');
    else
        return
    end


    poutcell=get(pdata,'Pout');
    phasecell=get(pdata,'Phase');
    pincell=get(pdata,'Pin');
    freq=get(pdata,'Freq');
    lenth=length(freq);

    rs=real(pdata.Z0);
    rl=real(pdata.Z0);


    if(lenth==1)||(lenth==0)
        idx=1;
    else
        if fc<=freq(1)
            idx=1;
        elseif fc>=freq(end)
            idx=lenth;
        else
            [~,idx]=min(abs(freq-fc));
        end
    end
    p=poutcell{idx};
    phase=phasecell{idx};
    pin=pincell{idx};
    x=sqrt(rs*pin);
    amam=sqrt(rl*p);
    ampm=unwrap(phase*pi/180);
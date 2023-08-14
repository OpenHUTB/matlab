function[new_bp,min_si,max_si,res]=...
    sldvemlLookupfxp_even_spaced_bps(bp,N,T,maxRes)

    bp_fi=fi(bp,T);
    bp_si=int32(bp_fi.storedInteger);
    min_si=bp_si(1);
    max_si=bp_si(end);


    if(numel(bp)>2)
        res=int32(0);
        deltas=bp_si(2:end)-bp_si(1:end-1);
        while(bitget(deltas,1)==0)
            res=res+1;
            deltas=bitshift(deltas,-1);
        end




        step=bitshift(1,res);
        if((max_si-min_si)/step<=2*N)
            new_si=min_si:step:max_si;
            new_bp=fi(new_si,T);
            new_bp.int=new_si;
            return
        end
    end




















    span=max_si-min_si;
    res=max(0,round(log2(double(span)./double(N))));
    res=min(res,maxRes);
    step=bitsll(int32(1),res);
    mask=step-1;



    span=bitand(span,bitcmp(mask));
    endpoint=min_si+span;
    if(endpoint<max_si)
        endpoint=endpoint+step;
    end

    new_si=min_si:step:endpoint;



    new_si(end)=max_si;


    new_bp=fi(new_si,T);
    new_bp.int=new_si;

end


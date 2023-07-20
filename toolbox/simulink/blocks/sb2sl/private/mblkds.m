function[width,smap]=mblkds(nreg,rind)







    width=nreg+nreg;
    smap=nreg+(1:nreg);
    if(~isempty(rind))
        if(any(rind>nreg))
            error(message('sb2sl_blks:mblkds:OutRangeIndices'));
        else
            smap(rind)=rind;
        end
    end
    return

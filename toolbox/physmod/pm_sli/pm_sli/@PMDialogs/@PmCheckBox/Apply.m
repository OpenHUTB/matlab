function retStatus=Apply(hThis)







    retStatus=true;

    try

        if(hThis.Value)
            strVal='on';
        else
            strVal='off';
        end

        hBlk=pmsl_getdoublehandle(hThis.BlockHandle);
        hThis.setParamCache(hBlk,hThis.ValueBlkParam,strVal);
        retStatus=hThis.applyChildren();

    catch
        retStatus=false;
    end
end


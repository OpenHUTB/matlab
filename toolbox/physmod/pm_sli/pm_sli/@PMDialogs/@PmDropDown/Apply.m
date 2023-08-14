function retStatus=Apply(hThis)






    retStatus=true;

    try




        hBlk=pmsl_getdoublehandle(hThis.BlockHandle);

        conditionalVal=hThis.Value;
        if isprop(hThis,'MapVals')&&~isempty(hThis.MapVals)
            conditionalVal=hThis.MapVals{1};
            bChoice=strcmp(hThis.Value,hThis.Choices);
            if(nnz(bChoice)==1)
                conditionalVal=hThis.MapVals{bChoice};
            end
        end

        hThis.setParamCache(hBlk,hThis.ValueBlkParam,conditionalVal);
        retStatus=hThis.applyChildren();

    catch
        retStatus=false;
    end

end

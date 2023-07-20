function retStatus=Apply(hThis)








    valStr=num2str(hThis.Value);


    hBlk=pmsl_getdoublehandle(hThis.BlockHandle);
    hThis.setParamCache(hBlk,hThis.ValueBlkParam,valStr);
    retStatus=hThis.applyChildren();

end

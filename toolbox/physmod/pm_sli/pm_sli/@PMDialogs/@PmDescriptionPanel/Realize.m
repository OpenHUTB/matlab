function retStatus=Realize(hThis)








    hBlk=pmsl_getdoublehandle(hThis.BlockHandle);

    hThis.DescrText=pm.sli.internal.resolveMessageString(...
    get_param(hBlk,'MaskDescription'));
    hThis.BlockTitle=get_param(hBlk,'MaskType');
    hThis.Need2Realize=false;

    retStatus=true;

end

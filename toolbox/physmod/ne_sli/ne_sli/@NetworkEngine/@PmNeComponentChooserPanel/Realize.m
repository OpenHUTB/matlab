function retStatus=Realize(hThis)




    retStatus=true;

    try
        hBlock=pmsl_getdoublehandle(hThis.BlockHandle);
        hThis.ComponentName=get_param(hBlock,'SourceFile');
    catch
        retStatus=false;
    end

end
function out=getPostponeTermination(modelName)








    tlcDebugOn=get_param(modelName,'TLCDebug');

    outputBool=strcmp(tlcDebugOn,'on');
    if outputBool
        out='on';
    else
        out='off';
    end
end

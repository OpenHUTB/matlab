function[outMin,outMax]=getDataStoreMinMax(blockH,name)

    try
        var=evalin('base',name);
        outMin=num2str(var.Min,'%15.15g');
        outMax=num2str(var.Max,'%15.15g');
        return;
    catch
    end

    mws=get_param(bdroot(blockH),'modelworkspace');
    try
        var=mws.evalin(name);
        outMin=num2str(var.Min,'%15.15g');
        outMax=num2str(var.Max,'%15.15g');
        return
    catch
    end

    outMin=get_param(blockH,'OutMin');
    outMax=get_param(blockH,'OutMax');

end
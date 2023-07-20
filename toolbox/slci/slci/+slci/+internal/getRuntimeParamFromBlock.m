

function out=getRuntimeParamFromBlock(aBlk,param,field)
    out='';
    assert(isa(aBlk,'Simulink.Block'))
    rto=aBlk.('RuntimeObject');
    assert(isa(rto,'Simulink.RunTimeBlock'));
    for i=1:rto.NumRuntimePrm
        if strcmpi(rto.RuntimePrm(i).Name,param)
            try
                out=rto.RuntimePrm(i).(field);
            catch
            end
            break;
        end
    end
end

function dimsStr=getCompiledPortDimsStr(portHandle)




    symbDims=get_param(portHandle,'CompiledPortSymbolicDimensions');
    portDims=get_param(portHandle,'CompiledPortDimensions');
    if contains(symbDims,{'INHERIT','NOSYMBOLIC'})
        dimsStr=getDimensionsStr(portDims);
    else

        dimsStr=symbDims;
    end
end

function dimsStr=getDimensionsStr(compDims)

    if isempty(compDims)
        dimsStr='';
        return;
    end
    nDims=compDims(1);
    if(nDims<2)
        dimsStr=sprintf('%d',compDims(2));
        return;
    end
    dimsStr='';
    spcVal='';
    for k=1:nDims
        if k>1
            spcVal=' ';
        end
        dimsStr=sprintf('%s%s%d',dimsStr,spcVal,compDims(k+1));
    end
    dimsStr=['[',dimsStr,']'];
end



function defaultLib=getDefaultTargetLib

    if~isempty(which('coder.gpuConfig'))

        defaultLib='cudnn';
    else
        defaultLib='mkldnn';
    end


end

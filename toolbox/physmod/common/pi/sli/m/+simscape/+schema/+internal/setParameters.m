function report=setParameters(handle,parameterValuePairs)
    report=string(missing);
    e=[];
    try
        set_param(handle,parameterValuePairs{:});
    catch e
    end
    if(~isempty(e))
        report=getReport(stripStack(e));
    end
end

function mStripped=stripStack(ME)
    mStripped=MException(ME.identifier,ME.message);
    if~isempty(ME.cause)
        for idx=1:numel(ME.cause)
            mStripped=mStripped.addCause(stripStack(ME.cause{idx}));
        end
    end
end

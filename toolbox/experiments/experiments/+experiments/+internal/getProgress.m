function progress=getProgress(info,MaxEpochs,MaxIterations)

    if isinf(MaxIterations)
        progress=max(0,round(100*(info.Epoch-1)/MaxEpochs,1));
    else
        progress=max(0,round(100*(info.Iteration-1)/MaxIterations,1));
    end
end

function bpLabel=getBreakPointsLabel(bpData,maxDim,zeroBasedIndices)


    bpLabel=num2cell(bpData);

    if length(bpLabel)<maxDim
        bpLabelLength=length(bpLabel);
        for i=maxDim:-1:bpLabelLength+1
            bpLabel{i}=sprintf("[%i]",i-zeroBasedIndices);
        end
    elseif length(bpData)>maxDim
        bpLabel=bpLabel(1:maxDim);
    end
end
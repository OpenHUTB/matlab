function string=getStringToDefineStride(breakpointValues)





    numInputs=numel(breakpointValues);
    if numInputs==1
        string='';
    else
        stride=ones(1,numInputs);
        stride(2)=numel(breakpointValues{1});
        for i=3:numInputs
            stride(i)=stride(i-1)*numel(breakpointValues{i-1});
        end
        string=['stride = ',mat2str(stride),';',newline];
    end
end

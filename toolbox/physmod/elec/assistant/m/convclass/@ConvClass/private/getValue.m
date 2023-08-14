
function Value=getValue(in,Name)
    idx=strcmp(Name,{in.InstanceData(:).Name});
    if any(idx)
        Value=in.InstanceData(idx).Value;
    else
        fprintf('Transformation parameter (%s) not found in (%s).\n',Name,strrep(gcb,newline,''));
        Value=0;
    end
end
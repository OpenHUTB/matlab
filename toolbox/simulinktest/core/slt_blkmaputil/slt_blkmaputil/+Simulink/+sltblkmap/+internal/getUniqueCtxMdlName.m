function[uniqueName]=getUniqueCtxMdlName(defaultName)
    idx=1;
    uniqueName=[defaultName,num2str(idx)];
    while exist(uniqueName)>0
        uniqueName=[defaultName,num2str(idx)];
        idx=idx+1;
    end
end
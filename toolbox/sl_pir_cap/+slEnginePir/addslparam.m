function addslparam(name,value,hfile)
    try
        x=Simulink.Parameter;
        x.Value=value;
        x.DataType='int32';
        x.CoderInfo.StorageClass='Custom';
        x.CoderInfo.CustomStorageClass='Define';
        x.CoderInfo.CustomAttributes.Header=hfile;
        assignin('base',name,x);
    catch
    end
end

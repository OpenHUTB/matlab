function ret=isSimulinkTarget(hCS)





    if ischar(hCS)||isnumeric(hCS)
        hCS=getActiveConfigSet(hCS);
    end
    if codertarget.target.isCoderTarget(hCS)
        targetName=codertarget.target.getTargetName(hCS);
        targetType=codertarget.target.getTargetType(targetName);
        ret=isequal(targetType,1);
    else
        ret=isequal(get_param(hCS,'SystemTargetFile'),'realtime.tlc');
    end
end

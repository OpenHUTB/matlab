function retCellArray=getPackageList(refresh)









    retCellArray=coder.internal.getPackageList(refresh,false,false);
    if slfeature('HideBuiltinStorageClasses')>0
        retCellArray{end+1}='SimulinkBuiltin';
    end
end

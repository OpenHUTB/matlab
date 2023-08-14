function value=getLocalMachineRegEntry(regKey,regEntry)





    value='';
    try
        NET.addAssembly('mscorlib');
        localMachineRoot=Microsoft.Win32.Registry.LocalMachine;
        subKey=localMachineRoot.OpenSubKey(regKey);
        if~isempty(subKey)
            value=char(subKey.GetValue(regEntry));
        end
    catch ex
        warning(ex.identifier,ex.message);
    end

end


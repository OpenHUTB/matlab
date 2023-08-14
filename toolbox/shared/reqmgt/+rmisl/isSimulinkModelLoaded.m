function tf=isSimulinkModelLoaded(mdlName)




    mdlName=convertStringsToChars(mdlName);

    if dig.isProductInstalled('Simulink')&&is_simulink_loaded()
        [~,mName]=fileparts(mdlName);
        tf=any(strcmp(find_system('type','block_diagram'),mName));
    else
        tf=false;
    end
end


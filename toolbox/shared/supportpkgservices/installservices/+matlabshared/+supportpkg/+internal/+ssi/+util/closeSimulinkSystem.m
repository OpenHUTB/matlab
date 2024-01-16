function closeSimulinkSystem()
    all_bds=getfullname(Simulink.allBlockDiagrams);
    if(ischar(all_bds))
        all_bds_arr{1}=all_bds;
    else
        all_bds_arr=all_bds;
    end

    for i=1:numel(all_bds_arr)
        bd=all_bds_arr{i};
        if~bdIsLoaded(bd)
            continue;
        end
        filepath=get_param(bd,'FileName');
        if isempty(filepath)

            continue;
        end
        spRoot=matlabshared.supportpkg.internal.getSupportPackageRootNoCreate();
        if(contains(filepath,spRoot))
            close_system(bd,0);
        end
    end
end


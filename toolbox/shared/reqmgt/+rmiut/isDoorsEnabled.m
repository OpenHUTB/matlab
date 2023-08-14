function tf=isDoorsEnabled()




    if~ispc
        tf=false;

    else
        [installed,licensed]=rmi.isInstalled();

        tf=installed&&licensed&&is_doors_installed();
    end
end


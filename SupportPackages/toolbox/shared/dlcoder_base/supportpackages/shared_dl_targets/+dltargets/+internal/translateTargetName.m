function targetpkg=translateTargetName(targetname)


    assert(~isempty(targetname));
    targetname=lower(targetname);
    switch targetname
    case 'arm-compute'
        targetpkg='arm_neon';
    case 'arm-compute-mali'
        targetpkg='arm_mali';
    case 'mkldnn'
        targetpkg='onednn';
    case 'cmsis-nn'
        targetpkg='cmsis_nn';
    otherwise
        targetpkg=targetname;
    end
end

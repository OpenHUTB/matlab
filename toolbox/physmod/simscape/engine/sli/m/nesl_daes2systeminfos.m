function sysInfos=nesl_daes2systeminfos(daes,mp,sp,cp,solver)






















    sysInfos=cell(length(daes),1);
    for idx=1:length(daes)
        sysInfos{idx}=nesl_dae2systeminfo(daes{idx},idx,mp,sp,cp,solver);
    end
end

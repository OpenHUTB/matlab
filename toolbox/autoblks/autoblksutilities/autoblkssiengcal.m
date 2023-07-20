function[varargout]=autoblkssiengcal(varargin)





    varargout={[]};
    block=varargin{1};
    maskMode=varargin{2};
    switch maskMode
    case 'varSwitched'
        varSwitched(block);
    case 'calController'
        calController(block);
    case 'calMapped'
        calMapped(block);
    end
end

function varSwitched(block)
    siEngCntrl='SiEngineController';
    siMapEng='SiMappedEngine';
    if~exist(siEngCntrl,'file')==4||~exist(siMapEng,'file')==4
        return
    end
    coreEngName=get_param([block,'/Dynamic SI Engine'],'ActiveVariant');
    load_system(coreEngName);
    hwsSiCore=get_param(coreEngName,'modelworkspace');
    mdot=getDdData(hwsSiCore,'f_mdot_intk');
    load_system(siEngCntrl);
    hwsc=get_param(siEngCntrl,'modelworkspace');
    saveCal=false;
    if~isequal(getDdData(hwsc,'f_mdot_intk'),mdot)
        saveCal=true;
    end
    if~saveCal
        calEngVar=getDdData(hwsc,'calEngVar');
        calCurr.f_lcmd=getDdData(hwsc,'f_lcmd');
        calCurr.f_tap=getDdData(hwsc,'f_tap');
        calCurr.f_wap=getDdData(hwsc,'f_wap');
        switch coreEngName
        case 'SiEngineCore'
            if~isequal(calCurr,calEngVar.core)
                saveCal=true;
            end
        case 'SiEngineCoreNA'
            if~isequal(calCurr,calEngVar.coreNA)
                saveCal=true;
            end
        case 'SiEngineCoreV'
            if~isequal(calCurr,calEngVar.coreV)
                saveCal=true;
            end
        case 'SiEngineCoreVNA'
            if~isequal(calCurr,calEngVar.coreVNA)
                saveCal=true;
            end
        case 'SiEngineCoreVThr2'
            if~isequal(calCurr,calEngVar.coreV2)
                saveCal=true;
            end
        end
    end

    load_system(siMapEng);
    hwsme=get_param(siMapEng,'modelworkspace');
    mappedTbls=getDdData(hwsSiCore,'mappedTbls');
    MappedTables=mapTables(mappedTbls);
    saveMap=false;

    Vd=getDdData(hwsme,'Vd');
    VdCore=getDdData(hwsSiCore,'Vd');
    if~isequal(Vd,VdCore)
        saveMap=true;
    end

    if~saveMap
        for i=1:size(MappedTables,1)
            f_i=getDdData(hwsme,MappedTables{i,1});
            if~isequal(f_i,MappedTables{i,2})
                saveMap=true;
            end
        end
    end

    if saveCal
        save_system(siEngCntrl);
    end

    if saveMap
        save_system(siMapEng);
    end
end

function calController(block)
    siEngMod='SiEngine';
    siEngPx='SiEnginePx';
    if exist(siEngMod,'file')==4
        siEng=siEngMod;
    elseif exist(siEngPx,'file')==4
        siEng=siEngPx;
    else
        return
    end
    load_system(siEng);
    coreEngName=get_param([siEng,'/Dynamic SI Engine'],'ActiveVariant');
    load_system(coreEngName);
    hwsSiCore=get_param(coreEngName,'modelworkspace');
    mdot=getDdData(hwsSiCore,'f_mdot_intk');
    hwsc=get_param(block,'modelworkspace');
    if~isequal(getDdData(hwsc,'f_mdot_intk'),mdot)
        setDdData(hwsc,'f_mdot_intk',mdot)
    end
    calEngVar=getDdData(hwsc,'calEngVar');
    f_lcmd=getDdData(hwsc,'f_lcmd');
    f_tap=getDdData(hwsc,'f_tap');
    f_wap=getDdData(hwsc,'f_wap');
    switch coreEngName
    case 'SiEngineCore'
        if~isequal(f_lcmd,calEngVar.core.f_lcmd)
            setDdData(hwsc,'f_lcmd',calEngVar.core.f_lcmd)
        end
        if~isequal(f_tap,calEngVar.core.f_tap)
            setDdData(hwsc,'f_tap',calEngVar.core.f_tap);
        end
        if~isequal(f_wap,calEngVar.core.f_wap)
            setDdData(hwsc,'f_wap',calEngVar.core.f_wap);
        end
    case 'SiEngineCoreNA'
        if~isequal(f_lcmd,calEngVar.coreNA.f_lcmd)
            setDdData(hwsc,'f_lcmd',calEngVar.coreNA.f_lcmd);
        end
        if~isequal(f_tap,calEngVar.coreNA.f_tap)
            setDdData(hwsc,'f_tap',calEngVar.coreNA.f_tap);
        end
        if~isequal(f_wap,calEngVar.coreNA.f_wap)
            setDdData(hwsc,'f_wap',calEngVar.coreNA.f_wap);
        end
    case 'SiEngineCoreV'
        if~isequal(f_lcmd,calEngVar.coreV.f_lcmd)
            setDdData(hwsc,'f_lcmd',calEngVar.coreV.f_lcmd);
        end
        if~isequal(f_tap,calEngVar.coreV.f_tap)
            setDdData(hwsc,'f_tap',calEngVar.coreV.f_tap);
        end
        if~isequal(f_wap,calEngVar.coreV.f_wap)
            setDdData(hwsc,'f_wap',calEngVar.coreV.f_wap);
        end
    case 'SiEngineCoreVNA'
        if~isequal(f_lcmd,calEngVar.coreVNA.f_lcmd)
            setDdData(hwsc,'f_lcmd',calEngVar.coreVNA.f_lcmd);
        end
        if~isequal(f_tap,calEngVar.coreVNA.f_tap)
            setDdData(hwsc,'f_tap',calEngVar.coreVNA.f_tap);
        end
        if~isequal(f_wap,calEngVar.coreVNA.f_wap)
            setDdData(hwsc,'f_wap',calEngVar.coreVNA.f_wap);
        end
    case 'SiEngineCoreVThr2'
        if~isequal(f_lcmd,calEngVar.coreV2.f_lcmd)
            setDdData(hwsc,'f_lcmd',calEngVar.coreV2.f_lcmd);
        end
        if~isequal(f_tap,calEngVar.coreV2.f_tap)
            setDdData(hwsc,'f_tap',calEngVar.coreV2.f_tap);
        end
        if~isequal(f_wap,calEngVar.coreV2.f_wap)
            setDdData(hwsc,'f_wap',calEngVar.coreV2.f_wap);
        end
    end
end

function calMapped(block)
    siEngMod='SiEngine';
    siEngPx='SiEnginePx';
    if exist(siEngMod,'file')==4
        siEng=siEngMod;
    elseif exist(siEngPx,'file')==4
        siEng=siEngPx;
    else
        return
    end
    load_system(siEng);
    coreEngName=get_param([siEng,'/Dynamic SI Engine'],'ActiveVariant');
    load_system(coreEngName);
    hwsSiCore=get_param(coreEngName,'modelworkspace');
    hwsme=get_param(block,'modelworkspace');
    mappedTbls=getDdData(hwsSiCore,'mappedTbls');

    MappedTables=mapTables(mappedTbls);

    for i=1:size(MappedTables,1)
        f_i=getDdData(hwsme,MappedTables{i,1});
        if~isequal(f_i,MappedTables{i,2})
            setDdData(hwsme,MappedTables{i,1},MappedTables{i,2})
        end
    end


    Vd=getDdData(hwsme,'Vd');
    VdCore=getDdData(hwsSiCore,'Vd');
    if~isequal(Vd,VdCore)
        setDdData(hwsme,'Vd',VdCore)
    end

end

function MappedTables=mapTables(mappedTbls)

    MappedTables={'f_tbrake',mappedTbls.f_tbrake;
    'f_air',mappedTbls.f_air;
    'f_fuel',mappedTbls.f_fuel;
    'f_texh',mappedTbls.f_texh;
    'f_eff',mappedTbls.f_eff;
    'f_hc',mappedTbls.f_hc;
    'f_co',mappedTbls.f_co;
    'f_nox',mappedTbls.f_nox;
    'f_co2',mappedTbls.f_co2;
    'f_pm',zeros(size(mappedTbls.f_tbrake))};
end

function Value=getDdData(DDobj,DataName)


    Value=getVariable(DDobj,DataName);
    if isa(Value,'Simulink.Parameter')
        Value=Value.Value;
    end
end



function setDdData(DDobj,DataName,DataValue)



    try
        Value=getVariable(DDobj,DataName);
    catch
        Value=DataValue;
    end

    if isa(Value,'Simulink.Parameter')
        Value.Value=DataValue;
    else
        Value=DataValue;
    end

    DDobj.assignin(DataName,Value);

end
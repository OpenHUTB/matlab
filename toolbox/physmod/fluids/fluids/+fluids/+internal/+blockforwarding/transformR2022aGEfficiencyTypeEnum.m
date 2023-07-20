function out=transformR2022aGEfficiencyTypeEnum(in)






    out=in;


    efficiencyType=getValue(out,'efficiencyType');
    efficiencyType_new=strrep(efficiencyType,...
    'fluids.gas.turbomachinery.enum.EfficiencyType.off',...
    'fluids.gas.turbomachinery.enum.EfficiencyType.Analytical');
    efficiencyType_set=strrep(efficiencyType_new,...
    'fluids.gas.turbomachinery.enum.EfficiencyType.on',...
    'fluids.gas.turbomachinery.enum.EfficiencyType.Constant');
    out=setValue(out,'efficiencyType',efficiencyType_set);

end
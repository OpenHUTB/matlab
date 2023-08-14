function[hcOffset,hcDirectionMode]=getBlockInfo(~,hC)


    slbh=hC.SimulinkHandle;
    hcOffset=getResolvedInfo(slbh,'HitCrossingOffset');

    hcDirection=get_param(slbh,'HitCrossingDirection');
    if strcmpi(hcDirection,'rising')
        hcDirectionMode=int8(0);
    elseif strcmpi(hcDirection,'falling')
        hcDirectionMode=int8(1);
    elseif strcmpi(hcDirection,'either')
        hcDirectionMode=int8(2);
    end

end


function val=getResolvedInfo(block,prop)

    prop_val=get_param(block,prop);
    val=slResolve(prop_val,block);
end

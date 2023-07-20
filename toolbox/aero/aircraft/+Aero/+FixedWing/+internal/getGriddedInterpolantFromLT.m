function GI=getGriddedInterpolantFromLT(LT)




    interpValues=LT.Table.Value;
    BPs=arrayfun(@(bp)bp.Value,LT.Breakpoints,'UniformOutput',false);

    GI=griddedInterpolant(BPs,interpValues);

end

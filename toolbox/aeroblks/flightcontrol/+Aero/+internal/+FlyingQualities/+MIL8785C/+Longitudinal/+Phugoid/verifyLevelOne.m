function fqStruct=verifyLevelOne(fqStruct)






    [fqStruct.FlyingQualityLevel]=deal("1");

    if fqStruct(1).zeta>=0.04
        [fqStruct.MILF8785CRequirement]=deal('Satisfies MIL-F-8785C Level 1 Criteria (zeta_ph >= 0.04)');
        [fqStruct.Verified]=deal(true);
    else
        [fqStruct.Verified]=deal(false);
    end
end

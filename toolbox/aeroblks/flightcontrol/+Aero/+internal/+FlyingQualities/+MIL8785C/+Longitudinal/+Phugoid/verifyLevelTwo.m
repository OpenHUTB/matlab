function fqStruct=verifyLevelTwo(fqStruct)






    [fqStruct.FlyingQualityLevel]=deal("2");

    if fqStruct(1).zeta>=0.0
        [fqStruct.MILF8785CRequirement]=deal('Satisfies MIL-F-8785C Level 2 Criteria (zeta_ph >= 0.0)');
        [fqStruct.Verified]=deal(true);
    else
        [fqStruct.Verified]=deal(false);
    end
end

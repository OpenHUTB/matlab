function fqStruct=verifyLevelThree(fqStruct)







    [fqStruct.FlyingQualityLevel]=deal("3");

    if fqStruct(3).Tc<=10
        [fqStruct.MILF8785CRequirement]=deal('Satisfies MIL-F-8785C Level 3 Criteria (T_r <= 10.0)');
        [fqStruct.Verified]=deal(true);
    else
        [fqStruct.Verified]=deal(false);
    end
end

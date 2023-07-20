function fqStruct=verifyLevelTwo(fqStruct)









    [fqStruct.FlyingQualityLevel]=deal("2");

    if(fqStruct(1).T2<0)
        [fqStruct.MILF8785CRequirement]=deal('Satisfies MIL-F-8785C Level 2 Criteria (T_2_s < 0)');
    elseif(fqStruct(1).T2>8.0)
        [fqStruct.MILF8785CRequirement]=deal('Satisfies MIL-F-8785C Level 2 Criteria (T_2_s > 8.0)');
        [fqStruct.Verified]=deal(true);
    else
        [fqStruct.Verified]=deal(false);
    end
end

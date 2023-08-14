function fqStruct=verifyLevelThree(fqStruct)









    [fqStruct.FlyingQualityLevel]=deal("3");

    if(fqStruct(1).T2<0)
        [fqStruct.MILF8785CRequirement]=deal('Satisfies MIL-F-8785C Level 3 Criteria (T_2_s < 0)');
    elseif(fqStruct(1).T2>4.0)
        [fqStruct.MILF8785CRequirement]=deal('Satisfies MIL-F-8785C Level 3 Criteria (T_2_s > 4.0)');
        [fqStruct.Verified]=deal(true);
    else
        [fqStruct.Verified]=deal(false);
    end
end

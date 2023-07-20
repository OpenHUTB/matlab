function fqStruct=verifyLevelThree(fqStruct)






    [fqStruct.FlyingQualityLevel]=deal("3");

    if fqStruct(1).T2>=55
        [fqStruct.MILF8785CRequirement]=deal('Satisfies MIL-F-8785C Level 3 Criteria (T_2_ph >= 55)');
        [fqStruct.Verified]=deal(true);
    else
        [fqStruct.Verified]=deal(false);
    end
end

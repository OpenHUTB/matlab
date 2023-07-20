function fqStruct=verifyLevelTwo(fqStruct)




















    [fqStruct.FlyingQualityLevel]=deal("2");


    if fqStruct(1).Tc<=1.4
        fqStruct(1).MILF8785CRequirement='Satisfies MIL-F-8785C Level 2 Criteria (T_r <= 1.4)';
        fqStruct(1).Verified=true;
    else
        fqStruct(1).Verified=false;
    end


    if fqStruct(2).Tc<=3.0
        fqStruct(2).MILF8785CRequirement='Satisfies MIL-F-8785C Level 2 Criteria (T_r <= 3.0)';
        fqStruct(2).Verified=true;
    else
        fqStruct(2).Verified=false;
    end


    if fqStruct(3).Tc<=3.0
        fqStruct(3).MILF8785CRequirement='Satisfies MIL-F-8785C Level 2 Criteria (T_r <= 3.0)';
        fqStruct(3).Verified=true;
    else
        fqStruct(3).Verified=false;
    end


    if fqStruct(4).Tc<=1.4
        fqStruct(4).MILF8785CRequirement='Satisfies MIL-F-8785C Level 2 Criteria (T_r <= 1.4)';
        fqStruct(4).Verified=true;
    else
        fqStruct(4).Verified=false;
    end


    if fqStruct(5).Tc<=3.0
        fqStruct(5).MILF8785CRequirement='Satisfies MIL-F-8785C Level 2 Criteria (T_r <= 3.0)';
        fqStruct(5).Verified=true;
    else
        fqStruct(5).Verified=false;
    end
end

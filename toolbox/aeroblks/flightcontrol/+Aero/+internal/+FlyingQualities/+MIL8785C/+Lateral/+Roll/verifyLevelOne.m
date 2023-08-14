function fqStruct=verifyLevelOne(fqStruct)




















    [fqStruct.FlyingQualityLevel]=deal("1");


    if fqStruct(1).Tc<=1.0
        fqStruct(1).MILF8785CRequirement='Satisfies MIL-F-8785C Level 1 Criteria (T_r <= 1.0)';
        fqStruct(1).Verified=true;
    else
        fqStruct(1).Verified=false;
    end


    if fqStruct(2).Tc<=1.4
        fqStruct(2).MILF8785CRequirement='Satisfies MIL-F-8785C Level 1 Criteria (T_r <= 1.4)';
        fqStruct(2).Verified=true;
    else
        fqStruct(2).Verified=false;
    end


    if fqStruct(3).Tc<=1.4
        fqStruct(3).MILF8785CRequirement='Satisfies MIL-F-8785C Level 1 Criteria (T_r <= 1.4)';
        fqStruct(3).Verified=true;
    else
        fqStruct(3).Verified=false;
    end


    if fqStruct(4).Tc<=1.0
        fqStruct(4).MILF8785CRequirement='Satisfies MIL-F-8785C Level 1 Criteria (T_r <= 1.0)';
        fqStruct(4).Verified=true;
    else
        fqStruct(4).Verified=false;
    end


    if fqStruct(5).Tc<=1.4
        fqStruct(5).MILF8785CRequirement='Satisfies MIL-F-8785C Level 1 Criteria (T_r <= 1.4)';
        fqStruct(5).Verified=true;
    else
        fqStruct(5).Verified=false;
    end
end

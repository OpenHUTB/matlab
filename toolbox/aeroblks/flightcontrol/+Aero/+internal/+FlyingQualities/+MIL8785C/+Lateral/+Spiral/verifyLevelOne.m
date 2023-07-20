function fqStruct=verifyLevelOne(fqStruct)















    [fqStruct.FlyingQualityLevel]=deal("1");


    if(fqStruct(1).T2<0)
        [fqStruct([1,3]).MILF8785CRequirement]=deal('Satisfies MIL-F-8785C Level 1 Criteria (T_2_s < 0)');
    elseif(fqStruct(1).T2>12.0)
        [fqStruct([1,3]).MILF8785CRequirement]=deal('Satisfies MIL-F-8785C Level 1 Criteria (T_2_s > 20.0)');
        [fqStruct([1,3]).Verified]=deal(true);
    else
        [fqStruct([1,3]).Verified]=deal(false);
    end


    if(fqStruct(2).T2<0)
        fqStruct(2).MILF8785CRequirement='Satisfies MIL-F-8785C Level 1 Criteria (T_2_s < 0)';
    elseif(fqStruct(2).T2>20.0)
        fqStruct(2).MILF8785CRequirement='Satisfies MIL-F-8785C Level 1 Criteria (T_2_s > 20.0)';
        fqStruct(2).Verified=true;
    else
        fqStruct(2).Verified=false;
    end
end

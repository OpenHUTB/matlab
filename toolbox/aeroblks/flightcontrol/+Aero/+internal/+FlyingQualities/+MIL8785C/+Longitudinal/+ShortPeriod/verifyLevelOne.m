function fqStruct=verifyLevelOne(fqStruct)








    [fqStruct.FlyingQualityLevel]=deal("1");


    if((0.35<fqStruct(1).zeta)&&(fqStruct(1).zeta<1.30))
        [fqStruct([1,3]).MILF8785CRequirement]=deal('Satisfies MIL-F-8785C Level 1 Criteria (0.35 < zeta_sp < 1.30)');
        [fqStruct([1,3]).Verified]=deal(true);
    else
        [fqStruct([1,3]).Verified]=deal(false);
    end


    if((0.30<fqStruct(2).zeta)&&(fqStruct(2).zeta<2.0))
        fqStruct(2).MILF8785CRequirement='Satisfies MIL-F-8785C Level 1 Criteria (0.3 < zeta_sp < 2.0)';
        fqStruct(2).Verified=true;
    else
        fqStruct(2).Verified=false;
    end
end

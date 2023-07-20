function fqStruct=verifyLevelTwo(fqStruct)








    [fqStruct.FlyingQualityLevel]=deal("2");


    if((0.25<fqStruct(1).zeta)&&(fqStruct(1).zeta<2.0))
        [fqStruct([1,3]).MILF8785CRequirement]=deal('Satisfies MIL-F-8785C Level 2 Criteria (0.25 < zeta_sp < 2.0)');
        [fqStruct([1,3]).Verified]=deal(true);
    else
        [fqStruct([1,3]).Verified]=deal(false);
    end


    if((0.20<fqStruct(2).zeta)&&(fqStruct(2).zeta<2.0))
        fqStruct(2).MILF8785CRequirement='Satisfies MIL-F-8785C Level 2 Criteria (0.2 < zeta_sp < 2.0)';
        fqStruct(2).Verified=true;
    else
        fqStruct(2).Verified=false;
    end
end

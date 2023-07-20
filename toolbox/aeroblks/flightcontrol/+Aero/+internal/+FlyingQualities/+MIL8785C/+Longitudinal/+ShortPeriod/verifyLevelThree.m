function fqStruct=verifyLevelThree(fqStruct)








    [fqStruct.FlyingQualityLevel]=deal("3");


    if 0.15<fqStruct(1).zeta
        [fqStruct([1,3]).MILF8785CRequirement]=deal('Satisfies MIL-F-8785C Level 3 Criteria (0.15 < zeta_sp)');
        [fqStruct([1,3]).Verified]=deal(true);
    else
        [fqStruct([1,3]).Verified]=deal(false);
    end


    if 0.15<fqStruct(2).zeta
        fqStruct(2).MILF8785CRequirement='Satisfies MIL-F-8785C Level 3 Criteria (0.15 < zeta_sp)';
        fqStruct(2).Verified=true;
    else
        fqStruct(2).Verified=false;
    end
end

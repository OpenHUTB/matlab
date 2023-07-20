function fqStruct=verifyLevelThree(fqStruct)









    [fqStruct.FlyingQualityLevel]=deal("3");

    if(fqStruct(1).zeta>=0.0)&&((fqStruct(1).zeta*fqStruct(1).wn)>=0.0)&&(fqStruct(1).wn>=0.4)
        [fqStruct.MILF8785CRequirement]=deal('Satisfies MIL-F-8785C Level 3 Criteria (zeta_d >= 0.0, omega_n >= 0.4)');
        [fqStruct.Verified]=deal(true);
    else
        [fqStruct.Verified]=deal(false);
    end
end

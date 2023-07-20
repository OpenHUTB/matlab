function fqStruct=verifyLevelTwo(fqStruct)









    [fqStruct.FlyingQualityLevel]=deal("2");

    if(fqStruct(1).zeta>=0.02)&&((fqStruct(1).zeta*fqStruct(1).wn)>=0.05)&&(fqStruct(1).wn>=0.4)
        [fqStruct.MILF8785CRequirement]=deal('Satisfies MIL-F-8785C Level 2 Criteria (zeta_d >= 0.02, omega_n >= 0.4, zeta_d*omega_n_d >= 0.05)');
        [fqStruct.Verified]=deal(true);
    else
        [fqStruct.Verified]=deal(false);
    end
end

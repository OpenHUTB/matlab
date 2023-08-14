function fqStruct=verifyLevelOne(fqStruct)




































    [fqStruct.FlyingQualityLevel]=deal("1");

    if(fqStruct(1).zeta>=0.4)&&(fqStruct(1).wn>=1)
        [fqStruct([1,2]).MILF8785CRequirement]=deal('Satisfies MIL-F-8785C Level 1 Criteria (zeta_d >= 0.4, omega_n >= 1.0)');
        [fqStruct([1,2]).Verified]=deal(true);
    else
        [fqStruct([1,2]).Verified]=deal(false);
    end


    if(fqStruct(3).zeta>=0.16)&&((fqStruct(3).zeta*fqStruct(3).wn)>=0.35)&&(fqStruct(3).wn>=1.0)
        fqStruct(3).MILF8785CRequirement='Satisfies MIL-F-8785C Level 1 Criteria (zeta_d >= 0.16, omega_n >= 1.0, zeta_d*omega_n_d >= 0.35)';
        fqStruct(3).Verified=true;
    else
        fqStruct(3).Verified=false;
    end


    if(fqStruct(4).zeta>=0.16)&&((fqStruct(4).zeta*fqStruct(4).wn)>=0.35)&&(fqStruct(4).wn>=0.4)
        fqStruct(4).MILF8785CRequirement='Satisfies MIL-F-8785C Level 1 Criteria (zeta_d >= 0.16, omega_n >= 0.4, zeta_d*omega_n_d >= 0.35)';
        fqStruct(4).Verified=true;
    else
        fqStruct(4).Verified=false;
    end



    if(fqStruct(5).zeta>=0.08)&&((fqStruct(5).zeta*fqStruct(5).wn)>=0.15)&&(fqStruct(5).wn>=0.4)
        fqStruct(5).MILF8785CRequirement='Satisfies MIL-F-8785C Level 1 Criteria (zeta_d >= 0.08, omega_n >= 0.4, zeta_d*omega_n_d >= 0.15)';
        fqStruct(5).Verified=true;
    else
        fqStruct(5).Verified=false;
    end


    if(fqStruct(6).zeta>=0.08)&&((fqStruct(6).zeta*fqStruct(6).wn)>=0.15)&&(fqStruct(6).wn>=1.0)
        fqStruct(6).MILF8785CRequirement='Satisfies MIL-F-8785C Level 1 Criteria (zeta_d >= 0.08, omega_n >= 1.0, zeta_d*omega_n_d >= 0.15)';
        fqStruct(6).Verified=true;
    else
        fqStruct(6).Verified=false;
    end


    if(fqStruct(7).zeta>=0.08)&&((fqStruct(7).zeta*fqStruct(7).wn)>=0.1)&&(fqStruct(7).wn>=0.4)
        fqStruct(7).MILF8785CRequirement='Satisfies MIL-F-8785C Level 1 Criteria (zeta_d >= 0.08, omega_n >= 0.4, zeta_d*omega_n_d >= 0.1)';
        fqStruct(7).Verified=true;
    else
        fqStruct(7).Verified=false;
    end
end

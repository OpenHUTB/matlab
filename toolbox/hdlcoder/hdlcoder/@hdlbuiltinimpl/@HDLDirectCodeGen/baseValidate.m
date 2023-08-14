function v=baseValidate(this,hC)

















    v_settings=this.get_validate_settings(hC);


    v=hdlvalidatestruct;

    if(v_settings.checkimplparams)
        v=[v,validateImplParams(this,hC)];
    end

    if(v_settings.checkportdatatypes)
        v=[v,validatePortDatatypes(this,hC)];
    end

    if(v_settings.checkcomplex)
        v=[v,validateComplex(this,hC)];
    end

    if(v_settings.checkvectorports)
        v=[v,validateVectorPorts(this,hC)];
    end

    if(v_settings.checkframes)
        v=[v,validateFrames(this,hC)];
    end

    if(v_settings.checkmatrices)
        v=[v,validateMatrices(this,hC,v_settings.maxsupporteddimension)];
    end

    if(v_settings.checkblock)
        v=[v,validateBlock(this,hC)];
    end

    if(v_settings.checkslopebias)
        v=[v,validateSlopeBias(this,hC)];
    end

    hN=hC.Owner;
    if(v_settings.checkenabledsubsystem)
        v=[v,validateEnabledSubsystem(this,hN)];


        v=[v,validateTriggeredSubsystem(this,hN)];
    end

    if(v_settings.checktriggeredsubsystem)
        v=[v,validateTriggeredSubsystem(this,hN)];
    end

    if(v_settings.checkresettablesubsystem)
        v=[v,validateResettableSubsystem(this,hC)];
    end

    if(v_settings.checkretimeincompatibility)
        v=[v,validateRetimingCompatibility(this,hN,hC)];
    end

    if(v_settings.checkretimeblackbox)
        v=[v,validateRetimingBlackbox(this,hN)];
    end

    if(v_settings.checksharing)

        v=[v,validateSharing(this,hN)];
    end

    if(v_settings.checkmulticlock)

        v=[v,validateMulticlock(this,hC)];
    end

    if(v_settings.incompatibleforxilinx)
        v=[v,validateXilinxCoregenCompatibility(this,hC)];
    end

    if(v_settings.incompatibleforaltera)
        v=[v,validateAlteraMegafunctionCompatibility(this,hC)];
    end

    maxOversampling=hdlgetparameter('maxoversampling');
    if(maxOversampling>0&&maxOversampling~=inf&&v_settings.checksingleratesharing)
        v=[v,validateSinglerateSharing(this,hN,hC)];
    end


    v=[v,validateComplexTypesForTargetCodeGen(this,hC)];

    if(v_settings.checknfp)
        v=[v,validateNFP(this,hC)];
    end

    if(v_settings.checknfpdouble&&~v_settings.checknfp)
        v=[v,validateNFPDouble(this,hC)];
    end
end

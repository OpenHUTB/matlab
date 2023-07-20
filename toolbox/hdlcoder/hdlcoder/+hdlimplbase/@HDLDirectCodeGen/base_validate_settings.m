function v_settings=base_validate_settings(~)








    v_settings=struct;

    v_settings.checkimplparams=true;

    v_settings.checkportdatatypes=true;

    v_settings.checkcomplex=true;

    v_settings.checkvectorports=false;

    v_settings.checkframes=false;

    v_settings.checkmatrices=true;

    v_settings.checkblock=true;

    v_settings.checkslopebias=false;


    v_settings.checkenabledsubsystem=false;


    v_settings.checktriggeredsubsystem=false;


    v_settings.checkresettablesubsystem=false;


    v_settings.checkretimeincompatibility=false;

    v_settings.checkretimeblackbox=false;

    v_settings.checkserialization=false;

    v_settings.checksharing=false;

    v_settings.checkmulticlock=false;

    v_settings.incompatibleforxilinx=false;

    v_settings.incompatibleforaltera=false;

    v_settings.checksingleratesharing=false;

    v_settings.checknfp=true;

    v_settings.checknfpdouble=true;

    v_settings.checknfphalf=true;

    v_settings.checkbustypeincompatibility=true;

    v_settings.maxsupporteddimension=1;
end



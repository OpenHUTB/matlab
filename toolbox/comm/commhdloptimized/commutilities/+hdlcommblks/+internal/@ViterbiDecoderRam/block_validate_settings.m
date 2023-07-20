function v_settings=block_validate_settings(~,~)






    v_settings=struct;



    driver=hdlcurrentdriver;
    ramstyle=driver.getCLI.RAMArchitecture;
    if strcmpi(ramstyle,'WithoutClockEnable')

        v_settings.checkenabledsubsystem=true;


        v_settings.checktriggledsubsystem=true;
    end


    v_settings.checkretimeincompatibility=true;


    v_settings.checksharing=true;


    v_settings.checkserialization=true;

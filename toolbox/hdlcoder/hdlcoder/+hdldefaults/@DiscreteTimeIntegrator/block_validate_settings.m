function v_settings=block_validate_settings(~,hC)






    v_settings=struct;



    v_settings.checktriggeredsubsystem=true;


    if~isempty(hC)&&(length(hC.PirOutputSignals)>1)
        v_settings.checkretimeincompatibility=true;
    end

    v_settings.checknfp=false;
    v_settings.checknfpdouble=false;
    v_settings.checkmatrices=true;
    v_settings.maxsupporteddimension=2;

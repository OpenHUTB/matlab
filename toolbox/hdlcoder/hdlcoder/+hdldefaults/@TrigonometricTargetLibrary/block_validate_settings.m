function v_settings=block_validate_settings(this,hC)%#ok<INUSL>






    v_settings=struct;


    v_settings.checkportdatatypes=false;
    v_settings.checknfp=false;


    if((strcmp(get_param(hC.SimulinkHandle,'Function'),'sin')||...
        strcmp(get_param(hC.SimulinkHandle,'Function'),'cos')))
        v_settings.checknfpdouble=false;
    else
        v_settings.checknfpdouble=true;
    end

    v_settings.checkmatrices=false;

    if isempty(hC)
        slbh=-1;
    else
        slbh=hC.SimulinkHandle;
    end

    if(slbh>0)
        Fname=get_param(slbh,'Function');
        if(strcmpi(Fname,'cos + jsin'))
            v_settings.checkcomplex=false;
        end
    end
end

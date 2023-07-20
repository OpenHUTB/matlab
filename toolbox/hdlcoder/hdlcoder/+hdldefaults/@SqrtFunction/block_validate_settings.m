function v_settings=block_validate_settings(this,hC)






    if isempty(hC)
        Fname=[];
        impl=[];
    else
        bfp=hC.SimulinkHandle;
        Fname=get_param(bfp,'Function');
        impl=getFunctionImpl(this,hC);
    end

    isFnImplEmpty=isempty(Fname)&&isempty(impl);


    if~isFnImplEmpty&&(~(strcmpi(Fname,'Sqrt')&&isempty(impl)))
        v_settings=impl.block_validate_settings;
    else
        v_settings=struct;


        v_settings.checkportdatatypes=false;


        v_settings.checknfp=false;
        v_settings.checkmatrices=false;
    end


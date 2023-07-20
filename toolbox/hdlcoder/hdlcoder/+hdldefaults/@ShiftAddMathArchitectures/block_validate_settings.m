function v_settings=block_validate_settings(this,hC)




    impl=getFunctionImpl(this,hC);


    if isempty(impl)


        v_settings=struct;


        v_settings.checkcomplex=false;

        v_settings.checknfp=false;
        v_settings.checknfpdouble=false;
        v_settings.checknfphalf=false;
        v_settings.checkmatrices=false;
    else

        v_settings=impl.block_validate_settings(hC);
    end

end

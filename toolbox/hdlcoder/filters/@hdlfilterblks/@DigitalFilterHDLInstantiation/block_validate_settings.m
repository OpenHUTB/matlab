function v_settings=block_validate_settings(this,hC)%#ok<INUSD>







    v_settings=struct;


    v_settings.checkcomplex=false;

    v_settings.checkenabledsubsystem=false;

    if isa(this,'hdlfilterblks.DiscreteFIRFilterHDLInstantiation')

        v_settings.checknfp=false;
        v_settings.checknfpdouble=false;
    end

    if isa(this,'hdlfilterblks.DiscreteFIRFullyParallel')
        v_settings.incompatibleforxilinx=false;
        v_settings.incompatibleforaltera=false;
    else
        v_settings.incompatibleforxilinx=true;
        v_settings.incompatibleforaltera=true;
    end

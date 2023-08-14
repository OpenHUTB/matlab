function[hdl_arch,entitysigs,cast_result,ce]=emit_firDA(this,entitysigs,ce)






    hdl_arch.functions='';
    hdl_arch.typedefs='';
    hdl_arch.constants='';
    hdl_arch.signals='';
    hdl_arch.body_blocks='';
    hdl_arch.body_output_assignments='';

    switch lower(class(this))
    case 'hdlfilter.dffir'
        internalstructure='fir';
    case 'hdlfilter.dfasymfir'
        internalstructure='antisymmetricfir';
    case 'hdlfilter.dfsymfir'
        internalstructure='symmetricfir';
    end


    [dacompute_arch,last_sum,ce]=emit_dist_arth(this,entitysigs,internalstructure);

    [typeconv_arch,cast_result]=emit_outputtypeconvert(this,last_sum);

    hdl_arch=combinehdlcode(this,hdl_arch,dacompute_arch,typeconv_arch);


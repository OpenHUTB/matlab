function[sections_arch,num_list,den_list,scaled_input]=emit_scaleinput_port(this,sections_arch,current_input,section)





    scales_port=hdlgetparameter('filter_generate_biquad_scale_port');

    num_list=current_input.coeffs(1:3);
    den_list=current_input.coeffs(4:6);

    if scales_port
        scales=this.ScaleValues;
        rmode=this.Roundmode;
        productrounding=rmode;
        omode=this.Overflowmode;
        productsaturation=omode;

        scaleconstant=current_input.coeffs(7);

        mcand_input=current_input.input;

        [scaleResultProdSLType,scaleResultSumSLType]=this.getScaleSLTypes;

        [sz,sbp,ssgn]=hdlgetsizesfromtype(scaleResultProdSLType);
        [scaleresultvtype,scaleresultsltype]=hdlgettypesfromsizes(sz,sbp,ssgn);
        [scaled_input,tempbody,tempsignals,moresignals]=hdlcoeffmultiply(mcand_input,...
        scales(section),...
        scaleconstant,...
        ['scale',num2str(section)],...
        scaleresultvtype,scaleresultsltype,...
        productrounding,productsaturation,scaleResultSumSLType);

        sections_arch.body_blocks=[sections_arch.body_blocks,tempbody];
        sections_arch.signals=[sections_arch.signals,tempsignals,moresignals];
    else
        scaled_input=current_input.input;
    end
function[scaleout_arch,scaled_output]=emit_scaleoutput(this,section_result)





    hN=pirNetworkForFilterComp;
    emitMode=isempty(hN);

    if emitMode
        numChannels=0;
    else
        numChannels=section_result.input.Type.getDimensions;
    end

    scales=this.ScaleValues;
    numsections=this.NumSections;

    scaleout_arch.constants='';
    scaleout_arch.signals='';
    scaleout_arch.body_blocks='';

    rmode=this.Roundmode;
    [outregrounding,productrounding]=deal(rmode);
    omode=this.Overflowmode;
    [outregsaturation,productsaturation]=deal(omode);

    numcoeffall=hdlgetallfromsltype(this.numcoeffSLtype);
    coeffsvsize=numcoeffall.size;
    coeffssigned=numcoeffall.signed;

    scaleall=hdlgetallfromsltype(this.scaleSLtype);
    scalebp=scaleall.bp;
    scalevtype=scaleall.vtype;
    scalesltype=scaleall.sltype;

    outputall=hdlgetallfromsltype(this.outputSLtype,'outputport');
    outregvtype=outputall.vtype;
    outregsltype=outputall.sltype;

    coeffs_internal=strcmpi(hdlgetparameter('filter_coefficient_source'),'internal');

    coeffs_port=hdlgetparameter('filter_generate_coeff_port');
    scales_port=hdlgetparameter('filter_generate_biquad_scale_port');

    if~coeffs_internal



        scales=0.9585*ones(1,(this.NumSections+1));
        indentedcomment=['  ',hdlgetparameter('comment_char'),' '];
        scaleout_arch.signals=[scaleout_arch.signals,indentedcomment,'Last Section Value --','   Processor Interface Signals \n'];
        scaleout_arch.body_blocks=[scaleout_arch.body_blocks,...
        indentedcomment,...
        '  -------- Last Section Value --',' Processor Interface logic------------------\n\n'];

        scale_assigned_name=hdllegalnamersvd([hdlgetparameter('filter_coeff_name'),'_scale',num2str(numsections+1),'_assigned']);
        [uname,scale_assigned]=hdlnewsignal(scale_assigned_name,'filter',-1,0,numChannels,scalevtype,scalesltype);
        scaleout_arch.signals=[scaleout_arch.signals,makehdlsignaldecl(scale_assigned)];

        scale_temp_name=hdllegalnamersvd([hdlgetparameter('filter_coeff_name'),'_scale',num2str(numsections+1),'_temp']);
        [uname,scale_temp]=hdlnewsignal(scale_temp_name,'filter',-1,0,numChannels,scalevtype,scalesltype);
        scaleout_arch.signals=[scaleout_arch.signals,makehdlsignaldecl(scale_temp)];

        scale_reg_name=hdllegalnamersvd([hdlgetparameter('filter_coeff_name'),'_scale',num2str(numsections+1),'_reg']);
        [uname,scale_reg]=hdlnewsignal(scale_reg_name,'filter',-1,0,numChannels,scalevtype,scalesltype);
        hdlregsignal(scale_reg);
        scaleout_arch.signals=[scaleout_arch.signals,makehdlsignaldecl(scale_reg)];

        scale_shadow_reg_name=hdllegalnamersvd([hdlgetparameter('filter_coeff_name'),'_scale',num2str(numsections+1),'_shadow_reg']);
        [uname,scale_shadow_reg]=hdlnewsignal(scale_shadow_reg_name,'filter',-1,0,numChannels,scalevtype,scalesltype);
        hdlregsignal(scale_shadow_reg);
        scaleout_arch.signals=[scaleout_arch.signals,makehdlsignaldecl(scale_shadow_reg)];

        mcand_input=section_result.input;

        [scaled_output,tempbody,tempsignals,moresignals]=hdlcoeffmultiply(mcand_input,...
        scales(numsections+1),...
        scale_shadow_reg,...
        ['scale',num2str(numsections+1)],...
        outregvtype,outregsltype,...
        productrounding,productsaturation);

        scaleout_arch.body_blocks=[scaleout_arch.body_blocks,tempbody];
        scaleout_arch.signals=[scaleout_arch.signals,tempsignals,moresignals];


        s_asgn_mux_bdy=hdlmux([section_result.coeffs,scale_reg],scale_assigned,section_result.wraddr,{'='},7,'when-else');
        scaleout_arch.body_blocks=[scaleout_arch.body_blocks,s_asgn_mux_bdy];

        s_tmp_mux_bdy=hdlmux([scale_assigned,scale_reg],scale_temp,section_result.wrenb,{'='},1,'when-else');
        scaleout_arch.body_blocks=[scaleout_arch.body_blocks,s_tmp_mux_bdy];

        [tempbody,tempsignals]=hdlunitdelay(scale_temp,scale_reg,...
        ['coeff_reg',hdlgetparameter('clock_process_label'),'_Last_ScaleValue'],0);
        scaleout_arch.body_blocks=[scaleout_arch.body_blocks,tempbody];
        scaleout_arch.signals=[scaleout_arch.signals,tempsignals];
        oldce=hdlgetcurrentclockenable;
        hdlsetcurrentclockenable(section_result.wrdone);
        [tempbody,tempsignals]=hdlunitdelay(scale_reg,scale_shadow_reg,...
        ['coeff_shadow_reg',hdlgetparameter('clock_process_label'),'_Last_ScaleValue'],0);
        scaleout_arch.body_blocks=[scaleout_arch.body_blocks,tempbody];
        scaleout_arch.signals=[scaleout_arch.signals,tempsignals];
        hdlsetcurrentclockenable(oldce);

    else
        if coeffs_port
            if scales_port
                scaleconstant=section_result.coeffs(8);
                mcand_input=section_result.input;

                [scaleResultProdSLType,scaleResultSumSLType]=this.getScaleSLTypes;
                [sz,sbp,ssgn]=hdlgetsizesfromtype(scaleResultProdSLType);
                [scaleresultvtype,scaleresultsltype]=hdlgettypesfromsizes(sz,sbp,ssgn);
                [scaled_output,tempbody,tempsignals,moresignals]=hdlcoeffmultiply(mcand_input,...
                scales(numsections+1),...
                scaleconstant,...
                ['scale',num2str(numsections+1)],...
                scaleresultvtype,scaleresultsltype,...
                productrounding,productsaturation,scaleResultSumSLType);

                scaleout_arch.body_blocks=[scaleout_arch.body_blocks,tempbody];
                scaleout_arch.signals=[scaleout_arch.signals,tempsignals,moresignals];

            else
                scaled_output=section_result.input;
            end
        else
            if isempty(scales)||length(scales)<=numsections||scales(end)==1
                scaled_output=section_result.input;
            else
                cplxty_scaleconst=any(imag(scales(numsections+1)));
                [uname,scaleconstant]=hdlnewsignal(['scaleconst',num2str(numsections+1)],'filter',-1,...
                cplxty_scaleconst,numChannels,scalevtype,scalesltype);
                if emitMode
                    if cplxty_scaleconst
                        scaleout_arch.constants=[scaleout_arch.constants,...
                        makehdlconstantdecl(scaleconstant,...
                        hdlconstantvalue(real(scales(numsections+1)),...
                        coeffsvsize,scalebp,coeffssigned))];
                        scaleout_arch.constants=[scaleout_arch.constants,...
                        makehdlconstantdecl(hdlsignalimag(scaleconstant),...
                        hdlconstantvalue(imag(scales(numsections+1)),...
                        coeffsvsize,scalebp,coeffssigned))];
                    else

                        scaleout_arch.constants=[scaleout_arch.constants,...
                        makehdlconstantdecl(scaleconstant,...
                        hdlconstantvalue(scales(numsections+1),...
                        coeffsvsize,scalebp,coeffssigned))];
                    end
                else
                    pirelab.getConstComp(hN,scaleconstant,scales(numsections+1));
                end

                mcand_input=section_result.input;


                [scaleResultProdSLType,scaleResultSumSLType]=this.getScaleSLTypes;
                [sz,sbp,ssgn]=hdlgetsizesfromtype(scaleResultProdSLType);
                [scaleresultvtype,scaleresultsltype]=hdlgettypesfromsizes(sz,sbp,ssgn);
                [scaled_output,tempbody,tempsignals,moresignals]=hdlcoeffmultiply(mcand_input,...
                scales(numsections+1),...
                scaleconstant,...
                ['scale',num2str(numsections+1)],...
                scaleresultvtype,scaleresultsltype,...
                productrounding,productsaturation,scaleResultSumSLType);

                scaleout_arch.body_blocks=[scaleout_arch.body_blocks,tempbody];
                scaleout_arch.signals=[scaleout_arch.signals,tempsignals,moresignals];

            end
        end
    end

    current_input=scaled_output;
    cplxty_outputtc=hdlsignaliscomplex(current_input);
    [mcandname,scaled_output]=hdlnewsignal('output_typeconvert','filter',-1,cplxty_outputtc,numChannels,...
    outregvtype,outregsltype);
    scaleout_arch.signals=[scaleout_arch.signals,...
    makehdlsignaldecl(scaled_output)];

    scaleout_arch.body_blocks=[scaleout_arch.body_blocks,...
    hdldatatypeassignment(current_input,scaled_output,...
    outregrounding,outregsaturation)];



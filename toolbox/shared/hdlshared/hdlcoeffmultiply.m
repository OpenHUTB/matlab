function[optr,body,signals,tempsigs,typedefs]=hdlcoeffmultiply(iptr,coeff,coeffptr,name,vtype,sltype,rounding,sat,accumsltype,forceaccumdtc)













    hN=pirNetworkForFilterComp;
    emitMode=isempty(hN);

    if emitMode
        SimulinkRate=0;
    else
        SimulinkRate=iptr.SimulinkRate;
        if coeffptr.SimulinkRate~=iptr.SimulinkRate
            tempSignal=hN.addSignal(coeffptr.Type,[coeffptr.Name,'_rateConv']);
            tempSignal.SimulinkRate=iptr.SimulinkRate;
            pirelab.getWireComp(hN,coeffptr,tempSignal);
            coeffptr=tempSignal;
        end
    end








    if(nargin<10)
        forceaccumdtc=false;
    end

    typedefs={};


    if~emitMode

        body='';
        tempsigs='';
        signals='';

        if hdlgetparameter('multiplier_input_pipeline')~=0
            iptr2=hN.addSignal(iptr.Type,[hdlsignalname(iptr),'_in_pipe']);
            hWireComp=pirelab.getWireComp(hN,iptr,iptr2,hdlsignalname(iptr));
            hWireComp.setInputPipeline(hdlgetparameter('multiplier_input_pipeline'));
            iptr=iptr2;
            if hdlgetparameter('filter_generate_coeff_port')



                coeffptr2=hN.addSignal(coeffptr.Type,[hdlsignalname(coeffptr),'_in_pipe']);
                hWireComp=pirelab.getWireComp(hN,coeffptr,coeffptr2,hdlsignalname(coeffptr));
                hWireComp.setInputPipeline(hdlgetparameter('multiplier_input_pipeline'));
                coeffptr=coeffptr2;
            end
        end

        output_complexity=~isreal(coeff)||hdlsignaliscomplex(iptr);
        iptr_dims=pirelab.getVectorTypeInfo(iptr,1);
        [~,optr]=hdlnewsignal(name,'filter',-1,output_complexity,iptr_dims,vtype,sltype,SimulinkRate);

        if strcmpi(hdlgetparameter('filter_multipliers'),'csd')
            if coeffptr.Type.getLeafType.isDoubleType||coeffptr.Type.getLeafType.isSingleType
                hGainComp=pirelab.getGainComp(hN,iptr,optr,coeff,1,0,rounding,sat);
            else
                coeff_fi=fi(coeff,coeffptr.Type.getLeafType.Signed,coeffptr.Type.getLeafType.WordLength,-coeffptr.Type.getLeafType.FractionLength);
                hGainComp=pirelab.getGainComp(hN,iptr,optr,coeff_fi,1,1,rounding,sat);
            end
            hGainComp.addComment(coeffptr.Name);
        elseif strcmpi(hdlgetparameter('filter_multipliers'),'factored-csd')
            if coeffptr.Type.getLeafType.isDoubleType||coeffptr.Type.getLeafType.isSingleType
                hGainComp=pirelab.getGainComp(hN,iptr,optr,coeff,1,0,rounding,sat);
            else
                coeff_fi=fi(coeff,coeffptr.Type.getLeafType.Signed,coeffptr.Type.getLeafType.WordLength,-coeffptr.Type.getLeafType.FractionLength);
                hGainComp=pirelab.getGainComp(hN,iptr,optr,coeff_fi,1,2,rounding,sat);
            end
            hGainComp.addComment(coeffptr.Name);
        else


            if hdlispowerof2(coeff)||coeff==0||coeff==1||coeff==-1...
                ||~isreal(coeff)&&((hdlispowerof2(real(coeff))&&hdlispowerof2(imag(coeff)))...
                ||(real(coeff)==0&&imag(coeff)==0)...
                ||(real(coeff)==1&&imag(coeff)==1)...
                ||(real(coeff)==-1&&imag(coeff)==-1))
                if coeffptr.Type.getLeafType.isDoubleType||coeffptr.Type.getLeafType.isSingleType||coeffptr.Type.getLeafType.isHalfType
                    hGainComp=pirelab.getGainComp(hN,iptr,optr,coeff,1,0,rounding,sat);
                else
                    coeff_fi=fi(coeff,coeffptr.Type.getLeafType.Signed,coeffptr.Type.getLeafType.WordLength,-coeffptr.Type.BaseType.FractionLength);
                    hGainComp=pirelab.getGainComp(hN,iptr,optr,coeff_fi,1,0,rounding,sat);
                end
                hGainComp.addComment(coeffptr.Name);
            else
                pirelab.getMulComp(hN,[iptr,coeffptr],optr,rounding,sat);
            end
        end

        if hdlgetparameter('multiplier_output_pipeline')~=0
            optr2=hN.addSignal(optr.Type,[hdlsignalname(optr),'_out_pipe']);
            hWireComp=pirelab.getWireComp(hN,optr,optr2,hdlsignalname(optr));
            hWireComp.setOutputPipeline(hdlgetparameter('multiplier_output_pipeline'));
            optr=optr2;
        end


    else

        if~isreal(coeff)
            complexity=1;
            if hdlsignaliscomplex(iptr)
                body='';
                tempsigs='';
                if hdlgetparameter('multiplier_input_pipeline')>0
                    multIpDelay=hdlgetparameter('multiplier_input_pipeline');
                    sz=hdlsignalsizes(iptr);

                    [vt,slt]=hdlgettypesfromsizes(sz(1),sz(2),sz(3));
                    [~,iptr2]=hdlnewsignal(hdllegalnamersvd([hdlsignalname(iptr),hdlgetparameter('PipelinePostfix')]),...
                    'block',-1,hdlsignaliscomplex(iptr),0,vt,slt);
                    hi=hdl.intdelay('clock',hdlgetcurrentclock,...
                    'clockenable',hdlgetcurrentclockenable,...
                    'reset',hdlgetcurrentreset,...
                    'inputs',iptr,...
                    'outputs',iptr2,...
                    'nDelays',multIpDelay);
                    hdlcode=hi.emit;
                    body=[body,hdlcode.arch_body_blocks];
                    tempsigs=[tempsigs,makehdlsignaldecl(iptr2),hdlcode.arch_signals];
                    iptr=iptr2;

                    sz=hdlsignalsizes(coeffptr);
                    [vt,slt]=hdlgettypesfromsizes(sz(1),sz(2),sz(3));
                    [~,coeffptr2]=hdlnewsignal(hdllegalnamersvd([hdlsignalname(coeffptr),hdlgetparameter('PipelinePostfix')]),...
                    'block',-1,hdlsignaliscomplex(coeffptr),0,vt,slt);
                    hi=hdl.intdelay('clock',hdlgetcurrentclock,...
                    'clockenable',hdlgetcurrentclockenable,...
                    'reset',hdlgetcurrentreset,...
                    'inputs',coeffptr,...
                    'outputs',coeffptr2,...
                    'nDelays',hdlgetparameter('multiplier_input_pipeline'));
                    hdlcode=hi.emit;
                    body=[body,hdlcode.arch_body_blocks];
                    tempsigs=[tempsigs,makehdlsignaldecl(coeffptr2),hdlcode.arch_signals];
                    coeffptr=coeffptr2;
                end


                ccmult=hdl.spblkmultiply(...
                'in1',iptr,...
                'in2',coeffptr,...
                'outname',name,...
                'product_sltype',sltype,...
                'accumulator_sltype',accumsltype,...
                'rounding',rounding,...
                'saturation',sat...
                );

                ccmultcode=ccmult.emit;
                body=[body,ccmultcode.arch_body_blocks];
                optr=ccmult.out;
                signals=[makehdlsignaldecl(ccmult.out),...
                makehdlsignaldecl(ccmult.re1),...
                makehdlsignaldecl(ccmult.re2),...
                makehdlsignaldecl(ccmult.im1),...
                makehdlsignaldecl(ccmult.im2)];
                tempsigs=[tempsigs,ccmultcode.arch_signals];


                if hdlgetparameter('multiplier_output_pipeline')>0
                    sz=hdlsignalsizes(optr);
                    [vt,slt]=hdlgettypesfromsizes(sz(1),sz(2),sz(3));

                    [~,optr2]=hdlnewsignal(hdllegalnamersvd([hdlsignalname(optr),hdlgetparameter('PipelinePostfix')]),...
                    'block',-1,hdlsignaliscomplex(optr),0,vt,slt,SimulinkRate);
                    hi=hdl.intdelay('clock',hdlgetcurrentclock,...
                    'clockenable',hdlgetcurrentclockenable,...
                    'reset',hdlgetcurrentreset,...
                    'inputs',optr,...
                    'outputs',optr2,...
                    'nDelays',hdlgetparameter('multiplier_output_pipeline'));
                    hdlcode=hi.emit;
                    body=[body,hdlcode.arch_body_blocks];
                    tempsigs=[tempsigs,makehdlsignaldecl(optr2),hdlcode.arch_signals];
                    optr=optr2;
                end
            else

                [~,optr]=hdlnewsignal(name,'filter',-1,complexity,...
                0,vtype,sltype,SimulinkRate);

                if real(coeff)==0

                    [~,const_zero]=hdlnewsignal('const_zero','filter',-1,0,0,vtype,sltype,SimulinkRate);

                    [psize,pbp]=hdlgetsizesfromtype(sltype);
                    constsig=makehdlconstantdecl(const_zero,hdlconstantvalue(0,psize,pbp,1));

                    body=hdldatatypeassignment(const_zero,optr,rounding,sat,'','real');
                    coeff=imag(coeff);
                    if coeff==-1
                        [body1,tempsigs]=hdlfilterunaryminus(iptr,hdlsignalimag(optr),rounding,sat);
                    elseif~strcmpi(vtype,'real')&&hdlispowerof2(coeff)
                        [body1,tempsigs]=hdlmultiplypowerof2(iptr,coeff,hdlsignalimag(optr),rounding,sat);

                    elseif~strcmpi(vtype,'real')&&strcmpi(hdlgetparameter('filter_multipliers'),'csd')
                        [body1,tempsigs]=hdlfiltermultiplycsd(iptr,coeff,coeffptr,hdlsignalimag(optr),rounding,sat);

                    elseif~strcmpi(vtype,'real')&&strcmpi(hdlgetparameter('filter_multipliers'),'factored-csd')
                        [body1,tempsigs]=hdlfiltermultiplyfactoredcsd(iptr,coeff,coeffptr,hdlsignalimag(optr),rounding,sat);
                    else
                        [~,body1,tempsigs,typedefs]=hdllocalcoeffmultiply(iptr,coeff,...
                        hdlsignalimag(coeffptr),hdlsignalimag(optr),name,vtype,sltype,...
                        rounding,sat,true);
                    end
                    body=[body,body1];
                    tempsigs=[tempsigs,constsig];
                else
                    [optr,body,tempsigs,typedefs]=hdllocalcoeffmultiply(iptr,real(coeff),...
                    coeffptr,optr,name,vtype,sltype,...
                    rounding,sat,true);
                    [~,body1,tempsigs1,typedefs1]=hdllocalcoeffmultiply(iptr,imag(coeff),...
                    hdlsignalimag(coeffptr),hdlsignalimag(optr),name,vtype,sltype,...
                    rounding,sat,true);
                    body=[body,body1];
                    tempsigs=[tempsigs,tempsigs1];
                    typedefs=[typedefs,typedefs1];
                end
                signals=makehdlsignaldecl(optr);
            end
        else
            if coeff~=0&&hdlsignaliscomplex(iptr)
                complexity=1;
                [~,optr]=hdlnewsignal(name,'filter',-1,complexity,0,vtype,sltype,SimulinkRate);
                [optr,body,tempsigs,typedefs]=hdllocalcoeffmultiply(iptr,coeff,...
                coeffptr,optr,name,vtype,sltype,rounding,sat,false);
                signals=makehdlsignaldecl(optr);


                if forceaccumdtc

                    mult_op=optr;

                    [~,optr]=hdlnewsignal([name,'_dtc'],'filter',-1,complexity,...
                    0,hdlblockdatatype(accumsltype),accumsltype,SimulinkRate);


                    body=[body,hdldatatypeassignment(mult_op,optr,rounding,sat,'','all')];
                    signals=[signals,makehdlsignaldecl(optr)];
                end
            else
                complexity=0;
                if coeff==0
                    optr=0;
                elseif(coeff==1&&~hdlgetparameter('bit_true_to_filter'))
                    optr=iptr;
                else
                    [~,optr]=hdlnewsignal(name,'filter',-1,complexity,0,vtype,sltype,SimulinkRate);
                end
                [optr,body,tempsigs,typedefs]=hdllocalcoeffmultiply(iptr,coeff,coeffptr,optr,name,vtype,sltype,rounding,sat,false);
                if optr==0||optr==iptr
                    signals='';
                else
                    signals=makehdlsignaldecl(optr);
                end
            end
        end
    end

    function[optr,body,tempsigs,typedefs]=hdllocalcoeffmultiply(iptr,coeff,coeffptr,optr,name,vtype,sltype,rounding,sat,realonly)





        body='';
        tempsigs='';
        typedefs={};
        fm=hdlgetparameter('filter_multipliers');

        if coeff==0
            optr=0;
        elseif coeff==1

            [iptr2,body,tempsigs,itypedefs]=handleInputPipeline(iptr,body,tempsigs);
            [optr2,body,tempsigs,otypedefs]=handleOutputPipeline(optr,body,tempsigs);

            typedefs=[itypedefs,otypedefs];
            if hdlgetparameter('bit_true_to_filter')
                if realonly
                    realtag='real';
                else
                    realtag='all';
                end
                body=[body,hdldatatypeassignment(iptr2,optr2,rounding,sat,'',realtag)];
            else
                optr2=iptr2;
            end

            if hdlgetparameter('multiplier_output_pipeline')==0
                optr=optr2;
            end

        elseif coeff==-1

            [iptr2,body,tempsigs,itypedefs]=handleInputPipeline(iptr,body,tempsigs);
            [optr2,body,tempsigs,otypedefs]=handleOutputPipeline(optr,body,tempsigs);

            typedefs=[itypedefs,otypedefs];

            [tbody,tsigs]=hdlfilterunaryminus(iptr2,optr2,rounding,sat,realonly);
            body=[body,tbody];
            tempsigs=[tempsigs,tsigs];

        elseif~strcmpi(vtype,'real')&&isreal(coeff)&&hdlispowerof2(coeff)

            [iptr2,body,tempsigs,itypedefs]=handleInputPipeline(iptr,body,tempsigs);
            [optr2,body,tempsigs,otypedefs]=handleOutputPipeline(optr,body,tempsigs);

            typedefs=[itypedefs,otypedefs];

            [tbody,tsigs]=hdlmultiplypowerof2(iptr2,coeff,optr2,rounding,sat);

            body=[body,tbody];
            tempsigs=[tempsigs,tsigs];

            if hdlsignaliscomplex(iptr2)
                [tbody,tsigs]=hdlmultiplypowerof2(hdlsignalimag(iptr2),coeff,hdlsignalimag(optr2),rounding,sat);
                body=[body,tbody];
                tempsigs=[tempsigs,tsigs];
            end

        elseif~strcmpi(vtype,'real')&&strcmpi(fm,'csd')

            [iptr2,body,tempsigs,itypedefs]=handleInputPipeline(iptr,body,tempsigs);
            [optr2,body,tempsigs,otypedefs]=handleOutputPipeline(optr,body,tempsigs);

            typedefs=[itypedefs,otypedefs];

            [tbody,tsigs]=hdlfiltermultiplycsd(iptr2,coeff,coeffptr,optr2,rounding,sat);
            body=[body,tbody];
            tempsigs=[tempsigs,tsigs];

            if hdlsignaliscomplex(iptr2)
                [tbody,tsigs]=hdlfiltermultiplycsd(hdlsignalimag(iptr2),coeff,coeffptr,hdlsignalimag(optr2),rounding,sat);
                body=[body,tbody];
                tempsigs=[tempsigs,tsigs];
            end


        elseif~strcmpi(vtype,'real')&&strcmpi(fm,'factored-csd')
            [iptr2,body,tempsigs,itypedefs]=handleInputPipeline(iptr,body,tempsigs);
            [optr2,body,tempsigs,otypedefs]=handleOutputPipeline(optr,body,tempsigs);

            typedefs=[itypedefs,otypedefs];

            [tbody,tsigs]=hdlfiltermultiplyfactoredcsd(iptr2,coeff,coeffptr,optr2,rounding,sat);
            body=[body,tbody];
            tempsigs=[tempsigs,tsigs];

            if hdlsignaliscomplex(iptr2)
                [tbody,tsigs]=hdlfiltermultiplyfactoredcsd(hdlsignalimag(iptr2),coeff,coeffptr,hdlsignalimag(optr2),rounding,sat);
                body=[body,tbody];
                tempsigs=[tempsigs,tsigs];
            end

        elseif hdlgetparameter('multiplier_input_pipeline')>0||hdlgetparameter('multiplier_output_pipeline')>0
            h=hdl.pipemul('inputs',[iptr,coeffptr],...
            'outputs',optr,...
            'roundmode',rounding,...
            'saturation',sat,...
            'inputpipelevels',hdlgetparameter('multiplier_input_pipeline'),...
            'outputpipelevels',hdlgetparameter('multiplier_output_pipeline'));
            hdlcode=h.emit;
            body=hdlcode.arch_body_blocks;
            tempsigs=hdlcode.arch_signals;
        else
            [body,tempsigs]=hdlfiltermultiply(iptr,coeffptr,optr,rounding,sat,realonly);
        end

        function[iptr2,body,tempsigs,typedefs]=handleInputPipeline(iptr,body,tempsigs)

            typedefs={};

            if hdlgetparameter('multiplier_input_pipeline')>0
                sz=hdlsignalsizes(iptr);
                [vt,slt]=hdlgettypesfromsizes(sz(1),sz(2),sz(3));
                [~,iptr2]=hdlnewsignal(hdllegalnamersvd([hdlsignalname(iptr),hdlgetparameter('PipelinePostfix')]),...
                'block',-1,hdlsignaliscomplex(iptr),0,...
                vt,slt);
                hi=hdl.intdelay('clock',hdlgetcurrentclock,...
                'clockenable',hdlgetcurrentclockenable,...
                'reset',hdlgetcurrentreset,...
                'inputs',iptr,...
                'outputs',iptr2,...
                'nDelays',hdlgetparameter('multiplier_input_pipeline'));
                hdlcode=hi.emit;
                if strcmpi(hdlgetparameter('target_language'),'vhdl')

                    typedefs=hdlgetparameter('vhdl_package_type_defs');



                    typedefs=hdlUniquifyTypeDefinitions(typedefs);


                    hdlsetparameter('vhdl_package_required',0);
                end
                body=[body,hdlcode.arch_body_blocks];
                tempsigs=[tempsigs,...
                makehdlsignaldecl(iptr2),...
                hdlcode.arch_signals];
            else
                iptr2=iptr;
            end

            function[optr2,body,tempsigs,typedefs]=handleOutputPipeline(optr,body,tempsigs)

                typedefs={};
                if hdlgetparameter('multiplier_output_pipeline')>0
                    sz=hdlsignalsizes(optr);
                    [vt,slt]=hdlgettypesfromsizes(sz(1),sz(2),sz(3));
                    [~,optr2]=hdlnewsignal(hdllegalnamersvd([hdlsignalname(optr),hdlgetparameter('PipelinePostfix')]),...
                    'block',-1,hdlsignaliscomplex(optr),0,...
                    vt,slt);
                    hi=hdl.intdelay('clock',hdlgetcurrentclock,...
                    'clockenable',hdlgetcurrentclockenable,...
                    'reset',hdlgetcurrentreset,...
                    'inputs',optr2,...
                    'outputs',optr,...
                    'nDelays',hdlgetparameter('multiplier_output_pipeline'));
                    hdlcode=hi.emit;
                    if strcmpi(hdlgetparameter('target_language'),'vhdl')

                        typedefs=hdlgetparameter('vhdl_package_type_defs');



                        typedefs=hdlUniquifyTypeDefinitions(typedefs);


                        hdlsetparameter('vhdl_package_required',0);
                    end
                    body=[body,hdlcode.arch_body_blocks];
                    tempsigs=[tempsigs,...
                    makehdlsignaldecl(optr2),...
                    hdlcode.arch_signals];
                else
                    optr2=optr;
                end



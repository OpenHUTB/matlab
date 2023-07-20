function impl=setimplementation(this)







    lpi=this.getHDLParameter('filter_dalutpartition');
    ssi=this.getHDLParameter('filter_serialsegment_inputs');

    final_adder_style=this.getHDLParameter('filter_fir_final_adder');
    if this.getHDLParameter('filter_pipelined')
        final_adder_style='pipelined';
    end

    mult_type=this.getHDLParameter('filter_multipliers');

    if isscalar(ssi)&&ssi==-1
        this.Implementation='parallel';
    else
        this.Implementation='serial';
        sorted_ssi=sort(ssi,'descend');
        ffactor=sorted_ssi(1);
        this.HDLParameters.INI.setProp('foldingfactor',ffactor);
        multpliers=this.getHDLParameter('filter_multipliers');
        if strcmpi(multpliers,'csd')||strcmpi(multpliers,'factored-csd')
            hprop=PersistentHDLPropSet;
            hprop.CLI.CoeffMultipliers='multiplier';
            updateINI(hprop);
            warning(message('HDLShared:hdlfilter:fsnotwithcsd'));
        end

    end

    if~(length(lpi)==1&&lpi==-1)

        this.Implementation='distributedarithmetic';

        if strcmpi(final_adder_style,'linear')






            this.setHDLParameter('FIRAdderStyle','tree');
            this.updateHdlfilterINI;
        end

        if this.getHDLParameter('filter_registered_input')~=1



            this.setHDLParameter('AddInputRegister','on');
            this.updateHdlfilterINI;
            warning(message('HDLShared:hdlfilter:danotwithoutinputreg'));
        end
        if this.getHDLParameter('filter_registered_output')~=1



            this.setHDLParameter('AddOutputRegister','on');
            this.updateHdlfilterINI;
            warning(message('HDLShared:hdlfilter:danotwithoutoutputreg'));
        end
        multpliers=this.getHDLParameter('filter_multipliers');
        if strcmpi(multpliers,'csd')||strcmpi(multpliers,'factored-csd')



            this.setHDLParameter('CoeffMultipliers','multiplier');
            this.updateHdlfilterINI;
            warning(message('HDLShared:hdlfilter:danotwithcsd'));
        end
    end

    impl=this.implementation;



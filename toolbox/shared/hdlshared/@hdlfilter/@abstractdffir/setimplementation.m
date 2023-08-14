function impl=setimplementation(this)





    final_adder_style=this.getHDLParameter('filter_fir_final_adder');
    if this.getHDLParameter('filter_pipelined')
        final_adder_style='pipelined';
    end

    ssi=this.getHDLParameter('filter_serialsegment_inputs');
    lpi=this.getHDLParameter('filter_dalutpartition');
    reuse_acc=this.getHDLParameter('filter_reuseaccum');

    coeffs=this.Coefficients;
    switch lower(class(this))
    case 'hdlfilter.dffir'
        internalstructure='fir';
    case 'hdlfilter.dfasymfir'
        internalstructure='antisymmetricfir';
    case 'hdlfilter.dfsymfir'
        internalstructure='symmetricfir';
    end


    sym=checksymmetry(coeffs,0);

    if strcmp(hdlcodegenmode,'filtercoder')


        if strcmp(internalstructure,'fir')&&strcmp(sym,'symmetric')&&~all(coeffs==0)&&(length(coeffs)>1)

            hdldisp(message('HDLShared:hdlfilter:symmetrywarning'));
        end

        if strcmp(internalstructure,'fir')&&strcmp(sym,'antisymmetric')&&~all(coeffs==0)&&(length(coeffs)>1)

            hdldisp(message('HDLShared:hdlfilter:asymmetrywarning'));
        end
    end



    filterlengths=this.getfilterlengths;

    czero_len=filterlengths.czero_len;




    if isscalar(ssi)
        if ssi==-1
            if reuse_acc



                ssi=hdlcascadedecompose(czero_len,1);
                if filterlengths.czero_len<=3

                    ssi=filterlengths.czero_len;
                    this.implementation='serial';
                else
                    this.Implementation='serialcascade';
                end
                ffactor=ssi(1);
                this.HDLParameters.INI.setProp('foldingfactor',ffactor);
            else
                this.Implementation='parallel';
            end
        else

            this.HDLParameters.INI.setProp('foldingfactor',ssi);


            this.Implementation='serial';
        end
    else
        if reuse_acc
            ssi=[ssi(1:end-1)+1,ssi(end)];
            this.Implementation='serialcascade';
            ffactor=ssi(1);
            this.HDLParameters.INI.setProp('foldingfactor',ffactor);
        else
            if isequal(ones(1,length(ssi)),ssi)
                this.Implementation='parallel';
            else

                this.Implementation='serial';
                sorted_ssi=sort(ssi,'descend');
                if strcmpi(final_adder_style,'pipelined')


                    ffactor=sorted_ssi(1)+ceil(log2(length(ssi)))-1;
                else
                    ffactor=sorted_ssi(1);
                end
                this.HDLParameters.INI.setProp('foldingfactor',ffactor);
            end
        end
    end



    impl=this.Implementation;



    if strcmpi(impl,'serial')||strcmpi(impl,'serialcascade')
        multpliers=this.getHDLParameter('filter_multipliers');
        if strcmpi(multpliers,'csd')||strcmpi(multpliers,'factored-csd')
            this.setHDLParameter('CoeffMultipliers','multiplier');
            this.updateHdlfilterINI;
            warning(message('HDLShared:hdlfilter:fsnotwithcsd'));
        end
    end
    if~(length(lpi)==1&&lpi==-1)


        if strcmpi(impl,'serial')||strcmpi(impl,'serialcascade')



        else
            this.Implementation='distributedarithmetic';
            impl=this.Implementation;
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
    else

    end


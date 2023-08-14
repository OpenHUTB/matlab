function elaborateFrameBased(hN,hC,blockInfo)

    MultiplierInputPipeline=hdlgetparameter('multiplier_input_pipeline');
    MultiplierOutputPipeline=hdlgetparameter('multiplier_output_pipeline');
    AdderPipelineDepth=hdlgetparameter('adder_tree_pipeline');

    rnd=blockInfo.RoundingMethod;
    sat=blockInfo.Saturation;
    inputVectorSize=double(hN.PirInputSignals(1).Type.getDimensions);
    inputFixType=hN.PirInputSignals(1).Type.getLeafType;
    prodFixType=numerictype2pirtype(blockInfo.dataTypes.ProductDataType);
    accumFixType=numerictype2pirtype(blockInfo.dataTypes.AccumulatorDataType);
    outFixType=numerictype2pirtype(blockInfo.dataTypes.OutputDataType);

    rateChangeFactor=blockInfo.rateChangeFactor;
    numbCoeffs=length(blockInfo.Coefficients);
    coeffFixType=numerictype2pirtype(blockInfo.dataTypes.CoefficientsDataType);
    coeffSigned=coeffFixType.Signed;
    coeffWL=coeffFixType.WordLength;
    coeffFL=coeffFixType.FractionLength;
    is_symm=blockInfo.is_symm;
    is_asymm=blockInfo.is_asymm;
    no_symm=blockInfo.no_symm;
    odd_symm=blockInfo.odd_symm;
    outputVectorSize=inputVectorSize*rateChangeFactor;


    incmplx=hdlsignaliscomplex(hN.PirInputSignals(1));
    outcmplx=hdlsignaliscomplex(hN.PirOutputSignals(1));
    coeffcmplx=~isreal(blockInfo.Coefficients);

    if incmplx
        inputFixType=pir_complex_t(inputFixType);
    end

    if outcmplx
        prodFixType=pir_complex_t(prodFixType);
        accumFixType=pir_complex_t(accumFixType);
        outFixType=pir_complex_t(outFixType);
    end

    if coeffcmplx
        coeffFixType=pir_complex_t(coeffFixType);
    end


    input_list=[];
    for i_vect=1:inputVectorSize
        hSig=hN.addSignal(inputFixType,['input_',num2str(i_vect)]);
        input_list=[input_list,hSig];
    end
    pirelab.getDemuxComp(hN,hN.PirInputSignals(1),input_list);


    [m_coeff,m_vect,m_delays]=generate_index_rules(inputVectorSize,rateChangeFactor,numbCoeffs);


    max_delay=max(m_delays(:));

    delayed_input_array(inputVectorSize,max_delay+1)=input_list(1);
    for i_vect=1:inputVectorSize
        for i_delay=1:max_delay+1
            delayed_input_array(i_vect,i_delay)=hN.addSignal(inputFixType,['input_',num2str(i_vect),'_delayed_',num2str(i_delay-1)]);
        end


        delayed_input_array(i_vect,1)=input_list(i_vect);

        for i_delay=2:max_delay+1
            pirelab.getIntDelayComp(hN,delayed_input_array(i_vect,i_delay-1),delayed_input_array(i_vect,i_delay),1,'');
        end
    end



    if~no_symm
        for i_vect=1:outputVectorSize
            for i_coef=1:numbCoeffs
                remap_delays(m_vect(i_vect,i_coef),m_coeff(i_vect,i_coef))=m_delays(i_vect,i_coef);
            end
        end
    end



    prod_matrix(inputVectorSize,numbCoeffs)=input_list(1);




    for i_vect=1:outputVectorSize
        for i_coef=1:numbCoeffs
            prod_matrix(m_vect(i_vect,i_coef),m_coeff(i_vect,i_coef))=hN.addSignal(prodFixType,['product_',num2str(m_vect(i_vect,i_coef)),'_',num2str(i_coef)]);
        end
    end


    if blockInfo.progCoeff
        allCoeffSigs=hN.PirInputSignals(2).split.PirOutputSignals;
    end


    for i_vect=1:outputVectorSize
        symm_offset=odd_symm+1;

        for i_coef=1:numbCoeffs

            hSig=prod_matrix(m_vect(i_vect,i_coef),m_coeff(i_vect,i_coef));




            if no_symm||(i_coef<=ceil(numbCoeffs/2))

                hDelayed=delayed_input_array(m_vect(i_vect,i_coef),m_delays(i_vect,i_coef)+1);

                if~blockInfo.progCoeff

                    coeff_fi=fi(blockInfo.Coefficients(i_coef),coeffSigned,coeffWL,-coeffFL);
                    if coeffcmplx
                        coeff_fi=complex(coeff_fi);
                    end
                    mulcomp=pirelab.getGainComp(hN,hDelayed,hSig,coeff_fi,1,0,rnd,sat,['coef_',num2str(i_coef),'_input_',num2str(m_vect(i_vect,i_coef))]);
                else
                    coeffSig=allCoeffSigs(i_coef);
                    if sat
                        satMode='Saturate';
                    else
                        satMode='Wrap';
                    end
                    mulcomp=pirelab.getMulComp(hN,[hDelayed,coeffSig],hSig,rnd,satMode,['coef_',num2str(i_coef),'_input_',num2str(m_vect(i_vect,i_coef))]);
                end

                mulcomp.setInputPipeline(MultiplierInputPipeline);
                mulcomp.setOutputPipeline(MultiplierOutputPipeline);

            else
                current_design_delay=m_delays(i_vect,i_coef);
                symmetric_design_delay=remap_delays(m_vect(i_vect,i_coef),i_coef-symm_offset);
                delay_difference=current_design_delay-symmetric_design_delay;
                h_symm_prod=prod_matrix(m_vect(i_vect,i_coef),i_coef-symm_offset);

                if delay_difference==0
                    pirelab.getWireComp(hN,h_symm_prod,hSig);
                else
                    pirelab.getIntDelayComp(hN,h_symm_prod,hSig,delay_difference);
                end

                symm_offset=symm_offset+2;
            end
        end
    end




    result_matrix=[];


    for i_vect=1:outputVectorSize

        hOutSig=hN.addSignal(outFixType,['result_',num2str(i_vect)]);
        hOutSig_temp=hN.addSignal(accumFixType,['result_temp',num2str(i_vect)]);

        sum_matrix=[];
        for i_coef=1:numbCoeffs
            hSig=hN.addSignal(accumFixType,['signal_',num2str(i_vect),'_',num2str(i_coef)]);
            hProdMat=prod_matrix(m_vect(i_vect,i_coef),m_coeff(i_vect,i_coef));


            pirelab.getDTCComp(hN,hProdMat,hSig,rnd,sat);

            sum_matrix=[sum_matrix,hSig];
        end


        if is_asymm
            sum_matrix_first=sum_matrix(1:ceil(numbCoeffs/2));
            sum_matrix_last=sum_matrix(floor(numbCoeffs/2)+1:end);
            reshape_sum_matrix=reshape([sum_matrix_first;fliplr(sum_matrix_last)],1,[]);
            sum_matrix=reshape_sum_matrix(1:numbCoeffs);
        end


        elaborateAdderTree(hN,sum_matrix,hOutSig_temp,AdderPipelineDepth,is_asymm,rnd,sat);
        pirelab.getDTCComp(hN,hOutSig_temp,hOutSig,rnd,sat);
        result_matrix=[result_matrix,hOutSig];
    end


    pirelab.getMuxComp(hN,result_matrix,hN.PirOutputSignals);

end






function pirt=numerictype2pirtype(nt)

    pirt=pir_fixpt_t(nt.SignednessBool,nt.WordLength,-nt.FractionLength);
end






function[column,row,delays]=generate_index_rules(input_size,rate_change,n_coefs)

    output_size=input_size*rate_change;
    adds_per_output=ceil(n_coefs/ceil(rate_change));



    column=zeros(output_size,adds_per_output);
    row=zeros(output_size,adds_per_output);
    delays=zeros(output_size,adds_per_output);


    for row_index=1:output_size
        column_val=mod(row_index-1,ceil(rate_change))+1;
        for column_index=1:adds_per_output
            column(row_index,column_index)=column_val;
            column_val=column_val+ceil(rate_change);
        end
    end


    for row_index=1:output_size
        row_val=floor((row_index-1)/rate_change);
        for column_index=1:adds_per_output
            row(row_index,column_index)=row_val+1;
            row_val=mod(row_val-1,input_size);
        end
    end


    for row_index=1:output_size
        delay_val=0;
        delay_count=1+floor((row_index-1)/rate_change);
        for column_index=1:adds_per_output
            delays(row_index,column_index)=delay_val;
            delay_count=mod(delay_count-1,input_size);
            if delay_count==0
                delay_val=delay_val+1;
            end
        end
    end

end





function elaborateAdderTree(hN,terms,sumOut,pipelineDepth,subtractFirstStage,rnd,sat)

    numStages=ceil(log2(length(terms)));


    termsIn=terms;


    for ks=1:numStages

        numTerms=length(termsIn);
        numAdders=floor(numTerms/2);
        spareTerm=mod(numTerms,2);


        termsOut=termsIn(1:numAdders+spareTerm);


        for ka=1:numAdders

            name=['sumStage',num2str(ks-1),'Term',num2str(ka-1)];


            adderOut=hN.addSignal(sumOut.Type,name);


            if subtractFirstStage&&(ks==1)
                pirelab.getAddComp(hN,termsIn(2*ka-1:2*ka),adderOut,...
                'Floor','Wrap','adder',[],'+-');
            else
                pirelab.getAddComp(hN,termsIn(2*ka-1:2*ka),adderOut,rnd,sat);
            end


            termsOut(ka)=hN.addSignal(adderOut.Type,name);

            if pipelineDepth>0
                pirelab.getIntDelayComp(hN,adderOut,termsOut(ka),...
                pipelineDepth,[name,'RegInst']);
            else
                pirelab.getWireComp(hN,adderOut,termsOut(ka));
            end
        end


        if spareTerm


            name=['sumStage',num2str(ks-1),'Term',num2str(numAdders)];
            termsOut(numAdders+1)=hN.addSignal(sumOut.Type,name);

            if pipelineDepth>0
                pirelab.getIntDelayComp(hN,termsIn(numTerms),termsOut(numAdders+1),...
                pipelineDepth,[name,'RegInst']);
            else
                pirelab.getWireComp(hN,termsIn(numTerms),termsOut(numAdders+1));
            end

        end


        termsIn=termsOut;

    end


    pirelab.getWireComp(hN,termsIn(1),sumOut);

end

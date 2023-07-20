function[hNewC,hDs]=getDynamicBitShiftComp(hN,hInSignals,hOutSignals,shift_mode,compName,positiveShiftsLeft)








    if(nargin<6)
        positiveShiftsLeft=false;
    end

    if(nargin<5)
        compName='dynamic_shift';
    end

    if(nargin<4)
        shift_mode='left';
    end


    if strcmpi(shift_mode,'bidi')
        isSignedShift=hInSignals(2).Type.Signed;
        if isSignedShift

            isBidirectional=true;
        else

            isBidirectional=false;
            if positiveShiftsLeft
                shift_mode='left';
            else
                shift_mode='right';
            end
        end
    else
        isBidirectional=false;
    end



    hDs=[];


    in_vector_mode=hInSignals(1).Type.isArrayType;


    has_shift_vector=hInSignals(2).Type.isArrayType;


    if(in_vector_mode)
        input_serialized=pirelab.getDemuxCompOnInput(hN,hInSignals(1));
        input_sig_serialized=input_serialized.PirOutputSignals;

        if has_shift_vector
            shift_serialized=pirelab.getDemuxCompOnInput(hN,hInSignals(2));
            shift_sig_serialized=shift_serialized.PirOutputSignals;
        else
            shift_sig_serialized=hInSignals(2);
        end

        tmp_sig_out=[];
        outType=hOutSignals.Type;
        if outType.BaseType.isComplexType
            outLeafType=pir_complex_t(outType.getLeafType);
        else
            outLeafType=outType.getLeafType;
        end
        for itr=1:numel(input_sig_serialized)
            if has_shift_vector

                shiftItr=itr;
            else

                shiftItr=1;
            end

            tmp_sig_out=[tmp_sig_out,hN.addSignal(outLeafType,sprintf('out_%d',itr))];%#ok<AGROW>

            [newC,newDs1,newDs2]=getScalarDynamicBitShiftComp(hN,[input_sig_serialized(itr),shift_sig_serialized(shiftItr)],tmp_sig_out(end),...
            shift_mode,[compName,'_',int2str(itr)],positiveShiftsLeft);
            if isBidirectional


                hDs=[hDs,newDs1,newDs2];%#ok<AGROW>
            else


                hDs=[hDs,newC];%#ok<AGROW>
            end
        end

        hNewC=pirelab.getMuxComp(hN,tmp_sig_out,hOutSignals);
    else
        [hNewC,hDs1,hDs2]=getScalarDynamicBitShiftComp(hN,hInSignals,hOutSignals,...
        shift_mode,compName,positiveShiftsLeft);
        if isBidirectional
            hDs=[hDs1,hDs2];
        end
    end


    function[hNewC,hDs1,hDs2]=getScalarDynamicBitShiftComp(hN,hInSignals,hOutSignals,shift_mode,compName,positiveShiftsLeft)

        if strcmpi(shift_mode,'bidi')


            sel=hInSignals(2);

            if positiveShiftsLeft
                op='>';
            else
                op='<';
            end

            bidiSig=pirelab.getCompareToZero(hN,sel,op,[compName,'_shift_direction']);


            selType=sel.Type.getLeafType;
            absSel=hN.addSignal(pir_ufixpt_t(selType.WordLength+1,selType.FractionLength),[compName,'_shift_value']);
            pirelab.getAbsComp(hN,sel,absSel,'floor','wrap',[compName,'_abs']);

            right_signal=hN.addSignal(hInSignals(1).Type,[compName,'_right']);
            right_signal.SimulinkRate=hInSignals(1).SimulinkRate;
            left_signal=hN.addSignal(hInSignals(1).Type,[compName,'_left']);
            left_signal.SimulinkRate=hInSignals(1).SimulinkRate;

            hDs1=pircore.getDynamicBitShiftComp(hN,[hInSignals(1),absSel],right_signal,'right','shift_right');
            hDs2=pircore.getDynamicBitShiftComp(hN,[hInSignals(1),absSel],left_signal,'left','shift_left');

            hNewC=pirelab.getSwitchComp(hN,[right_signal,left_signal],hOutSignals,bidiSig,'selector');
        else
            selType=hInSignals(2).Type.getLeafType;
            if(selType.Signed)


                unsignedSel=hN.addSignal(selType,[compName,'_selsig']);
                zero_signal=hN.addSignal(selType,[compName,'_zerosig']);

                unsignedSel.SimulinkRate=hInSignals(2).SimulinkRate;
                zero_signal.SimulinkRate=hInSignals(2).SimulinkRate;
                pirelab.getConstComp(hN,zero_signal,uint8(0));
                pirelab.getMinMaxComp(hN,[hInSignals(2),zero_signal],unsignedSel,[compName,'_nonneg'],'max');
            else
                unsignedSel=hInSignals(2);
            end
            hNewC=pircore.getDynamicBitShiftComp(hN,[hInSignals(1),unsignedSel],hOutSignals,shift_mode,compName);
            hDs1=[];
            hDs2=[];
        end
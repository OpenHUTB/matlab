function pass=checkFilterBlkInitConds(this,hC)






    bfp=hC.SimulinkHandle;
    block=get_param(bfp,'Object');
    pass=true;
    switch block.TypePopup
    case 'IIR (all poles)'
    case 'FIR (all zeros)'
        switch block.FIRFiltStruct
        case{'Direct form',...
            'Direct form symmetric',...
            'Direct form antisymmetric',...
            'Direct form transposed'}
            initconds=hdlslResolve('ic',bfp);
            pass=~any(initconds);
        otherwise

        end
    case 'IIR (poles & zeros)'
        switch block.IIRFiltStruct

        case{'Biquad direct form I (SOS)',...
            'Biquad direct form I transposed (SOS)'}
            initcond_den=hdlslResolve('icden',bfp);
            initcond_num=hdlslResolve('icnum',bfp);
            pass=~any(initcond_den)&&~any(initcond_num);
        case{'Biquad direct form II transposed (SOS)',...
            'Biquad direct form II (SOS)'}
            initconds=hdlslResolve('ic',bfp);
            pass=~any(initconds);
        otherwise

        end
    otherwise

    end




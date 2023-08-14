function v=validateBlock(this,hC)





    v=hdlvalidatestruct();

    bfp=hC.SimulinkHandle;
    block=get_param(bfp,'Object');

    switch block.FilterSource
    case 'Input port(s)'
        v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:coeffviainputports'));
    case 'Specify via dialog'
        switch block.TypePopup
        case 'IIR (all poles)'
            v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:iirallpoles'));
        case 'FIR (all zeros)'
            switch block.FIRFiltStruct
            case 'Direct form'
            case 'Direct form symmetric'
            case 'Direct form antisymmetric'
            case 'Direct form transposed'
            otherwise
                v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:UnsupportedFIRFilterStructure',block.Name));
            end
        case 'IIR (poles & zeros)'
            switch block.IIRFiltStruct
            case 'Biquad direct form I (SOS)'
            case 'Biquad direct form I transposed (SOS)'
            case 'Biquad direct form II (SOS)'
            case 'Biquad direct form II transposed (SOS)'
            otherwise
                v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:UnsupportedIIRFilterStructure',block.Name));
            end
        otherwise
            v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:UnsupportedFilterStructure',block.Name))
        end
    end


    ip=hC.SLInputPorts(1).Signal;
    op=hC.SLOutputPorts(1).Signal;
    if(max(hdlsignalvector(ip))>1)||(max(hdlsignalvector(op)>1))
        msg='HDL code generation for the Digital Filter Block is not supported for vector ports.';
        v(end+1)=hdlvalidatestruct(1,msg,...
        'hdlcoder:validate:vectorport');
    end




    v=[v,validateInitialCondition(this,hC)];




    if any([v.Status])
        return;
    end






    v=[v,validateFilterImplParams(this,hC)];

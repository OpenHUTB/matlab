%#codegen
function phase_out=hdleml_fft_phaselogic(enb,phase_count)





    coder.allowpcode('plain')

    fm=hdlfimath;
    nt=numerictype(0,1,0);

    zero=fi(0,nt,fm);
    one=fi(1,nt,fm);

    persistent phase enb_reg
    if isempty(phase)
        phase=zero;
        enb_reg=zero;
    end


    phase_out=phase;


    if enb==one&&enb_reg==zero
        if phase_count==one
            phase=one;
        else
            phase=zero;
        end
    end


    enb_reg=enb;





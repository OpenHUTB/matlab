function[f0_full_out,f1_full_out]=dnnfpgaInterprocessorfifobaselibFifo_status_state_machine(w_done,w_ptr,T0_done,T1_done)
%#codegen


    coder.allowpcode('plain');

    persistent f0_full;
    if isempty(f0_full)
        f0_full=false;
    end

    persistent f1_full;
    if isempty(f1_full)
        f1_full=false;
    end

    f0_full_out=f0_full;
    f1_full_out=f1_full;

    if w_done&&(~w_ptr)
        f0_full=true;
    elseif T0_done
        f0_full=false;
    end

    if w_done&&w_ptr
        f1_full=true;
    elseif T1_done
        f1_full=false;
    end

end



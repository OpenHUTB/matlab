function[T0_done,T1_done,read_ready_out]=dnnfpgaInterprocessorfifobaselibRead_ready_gen(count0,count1,count_limit,r_done,r_ptr)
%#codegen


    coder.allowpcode('plain');

    persistent read_ready;
    if isempty(read_ready)
        read_ready=false;
    end

    read_ready_out=read_ready;
    T0_done=(count0==count_limit)&(count_limit~=0);
    T1_done=(count1==count_limit)&(count_limit~=0);

    if(T0_done&&(~r_ptr))||(T1_done&&r_ptr)
        read_ready=true;
    elseif r_done
        read_ready=false;
    end

end

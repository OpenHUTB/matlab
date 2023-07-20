function[fc_index,T_valid_out]=dnnfpgaInterprocessorfifobaselibConv_transfer_sim(X_count,Y_count,f_count,thre1,thre2,thre3,offset,T_valid,X,Y)
%#codegen



    coder.allowpcode('plain');



    fc_temp=min(Y_count,Y-1)+min(X_count,X-1)*Y+f_count*X*Y;

    if f_count<thre1
        fc_index=fc_temp;
        T_valid_out=T_valid;
    elseif f_count<thre2
        fc_index(:)=0;
        T_valid_out=false;
    elseif f_count<thre3
        fc_index(:)=fc_temp-offset;
        T_valid_out=T_valid;
    else
        fc_index(:)=0;
        T_valid_out=false;
    end

end

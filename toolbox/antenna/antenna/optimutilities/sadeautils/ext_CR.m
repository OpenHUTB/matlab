function CR_memory_st=ext_CR(CR_memory,iter,LP)



    CR_memory_st=[];

    for i=1:size(CR_memory,1)
        if CR_memory(i,1)>=iter-LP
            CR_memory_st=[CR_memory_st;CR_memory(i,2)];
        end
    end